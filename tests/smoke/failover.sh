#!/usr/bin/env bash
# Failure tests against a LIVE deployment: (1) stop one task, (2) stop every task in one AZ.
# Probes the ALB /health once per second while ECS heals; records user-visible errors and recovery times.
# Sourced by run.sh (needs ROOT, ENV, lib.sh) — can also be run standalone: tests/smoke/failover.sh dev
if [ -z "${ROOT:-}" ]; then ENV="${1:-dev}"; ROOT="$(cd "$(dirname "$0")/../.." && pwd)"; source "$ROOT/tests/smoke/lib.sh"; fi
export AWS_PROFILE="${AWS_PROFILE:-portfolio}" AWS_REGION="${AWS_REGION:-us-west-2}"
CL="$(tf_out cluster_name)"; SVC="$(tf_out service_name)"; TG="$(tf_out target_group_arn)"; URL="$(tf_out site_url)"

running_tasks() { aws ecs list-tasks --cluster "$CL" --service-name "$SVC" --desired-status RUNNING --query 'taskArns' --output text; }
task_azs() { aws ecs describe-tasks --cluster "$CL" --tasks $(running_tasks) --query 'tasks[?lastStatus==`RUNNING`].[availabilityZone,taskArn]' --output text; }
healthy() { aws elbv2 describe-target-health --target-group-arn "$TG" --query 'length(TargetHealthDescriptions[?TargetHealth.State==`healthy`])' --output text; }
svc_counts() { aws ecs describe-services --cluster "$CL" --services "$SVC" --query 'services[0].[runningCount,pendingCount]' --output text; }
wait_stable() { # $1 = expected task count (= healthy targets), $2 = max seconds; requires no pending/extra tasks too
  local end=$((SECONDS+$2)); while [ $SECONDS -lt $end ]; do
    [ "$(healthy)" = "$1" ] && [ "$(svc_counts | tr '\t' ' ')" = "$1 0" ] && return 0; sleep 3; done; return 1; }

# VICTIMS = stopped task ARNs; recovery only counts once they are really STOPPED (the ALB keeps a dying target "healthy" briefly)
victims_stopped() { [ -z "$(aws ecs describe-tasks --cluster "$CL" --tasks $VICTIMS --query 'tasks[?lastStatus!=`STOPPED`].taskArn' --output text)" ]; }
probe_while_healing() {
  local want="$1" t0=$SECONDS; ERRS=0; PROBES=0; RECOVERY_S=-1
  while [ $((SECONDS-t0)) -lt 300 ]; do
    c="$(http_code "$URL/health")"; PROBES=$((PROBES+1)); [ "$c" = 200 ] || ERRS=$((ERRS+1))
    if [ "$(healthy)" = "$want" ] && victims_stopped; then RECOVERY_S=$((SECONDS-t0)); break; fi
    sleep 1
  done
}

echo "--- Failure test 1: stop ONE task"
wait_stable 2 300
echo "[$(ts)] before: $(task_azs | awk '{print $1}' | sort | tr '\n' ' ')"
victim="$(task_azs | head -1 | awk '{print $2}')"
VICTIMS="$victim"
aws ecs stop-task --cluster "$CL" --task "$victim" --reason "failover-test" >/dev/null
echo "[$(ts)] stopped 1 task"
probe_while_healing 2
echo "[$(ts)] test1: back to 2 healthy targets in ${RECOVERY_S}s; ${ERRS}/${PROBES} probes failed (non-200)"
check "site stayed up while 1 task was stopped (<=2 failed probes)" test "$ERRS" -le 2
check "service self-healed to 2 healthy targets within 180s after stopping 1 task" test "$RECOVERY_S" -ge 0 -a "$RECOVERY_S" -le 180
T1="$RECOVERY_S"

echo "--- Failure test 2: stop ALL tasks in one AZ (autoscaling min raised to 4 so each AZ holds 2 tasks)"
# (a manual desired-count change is overridden by autoscaling, so raise the autoscaling MIN instead)
RID="service/$CL/$SVC"
aws application-autoscaling register-scalable-target --service-namespace ecs --scalable-dimension ecs:service:DesiredCount --resource-id "$RID" --min-capacity 4 --max-capacity 4 >/dev/null
wait_stable 4 300
AZ="$(task_azs | awk '{print $1}' | sort | head -1)"
echo "[$(ts)] before: $(task_azs | awk '{print $1}' | sort | uniq -c | tr '\n' ' ')"
check "4 tasks running, 2 per AZ, before the AZ-loss test" test "$(task_azs | awk '{print $1}' | sort | uniq -c | awk '{print $1}' | tr '\n' ,)" = "2,2,"
VICTIMS="$(task_azs | awk -v az="$AZ" '$1==az{print $2}' | tr '\n' ' ')"
for t in $VICTIMS; do aws ecs stop-task --cluster "$CL" --task "$t" --reason "az-failure-test" >/dev/null; done
echo "[$(ts)] stopped every task in one AZ"
probe_while_healing 4
echo "[$(ts)] test2: back to 4 healthy targets in ${RECOVERY_S}s; ${ERRS}/${PROBES} probes failed (non-200)"
check "site stayed up while one AZ lost all its tasks (<=2 failed probes)" test "$ERRS" -le 2
check "service self-healed to 4 healthy targets within 240s after losing a whole AZ" test "$RECOVERY_S" -ge 0 -a "$RECOVERY_S" -le 240
T2="$RECOVERY_S"
echo "[$(ts)] after: $(task_azs | awk '{print $1}' | sort | uniq -c | tr '\n' ' ')"
aws application-autoscaling register-scalable-target --service-namespace ecs --scalable-dimension ecs:service:DesiredCount --resource-id "$RID" --min-capacity 2 --max-capacity 4 >/dev/null
echo "FAILOVER_SUMMARY one_task_recovery_s=$T1 az_loss_recovery_s=$T2"
