#!/usr/bin/env bash
# Smoke tests: prove the project's CORE CLAIM against a LIVE deployment (e.g. "traffic fails over",
# "policy blocks a non-compliant deploy", "remediation fixes drift within 5 minutes").
# Usage: tests/smoke/run.sh <env>   (or `make verify ENV=dev`)
# Output is redacted and saved to docs/evidence/smoke-<env>.txt.
set -uo pipefail
ENV="${1:-dev}"
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
REDACT="$HOME/.claude/skills/screenshots/scripts/redact.py"
OUT="$ROOT/docs/evidence/smoke-$ENV.txt"
mkdir -p "$(dirname "$OUT")"
source "$ROOT/tests/smoke/lib.sh"

run() {
  echo "Smoke tests for ecs-web-platform ($ENV) — $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  export AWS_PROFILE="${AWS_PROFILE:-portfolio}" AWS_REGION="${AWS_REGION:-us-west-2}"
  url="$(tf_out site_url)"; CL="$(tf_out cluster_name)"; SVC="$(tf_out service_name)"; TG="$(tf_out target_group_arn)"
  check "ALB /health answers 200" retry 20 10 bash -c "[ \"\$(http_code '$url/health')\" = 200 ]"
  check "home page serves the app" bash -c "curl -s --max-time 10 '$url/' | grep -q 'Contoso Harbor Supply'"
  for _ in $(seq 40); do [ "$(aws elbv2 describe-target-health --target-group-arn "$TG" --query 'length(TargetHealthDescriptions[?TargetHealth.State==`healthy`])' --output text)" = 2 ] && break; sleep 3; done # let any draining target leave
  expect_eq "2 targets healthy in the ALB target group" "$(aws elbv2 describe-target-health --target-group-arn "$TG" --query 'length(TargetHealthDescriptions[?TargetHealth.State==`healthy`])' --output text)" "2"
  azs="$(aws ecs describe-tasks --cluster "$CL" --tasks $(aws ecs list-tasks --cluster "$CL" --service-name "$SVC" --query taskArns --output text) --query 'tasks[].availabilityZone' --output text | tr '\t' '\n' | sort -u | wc -l)"
  expect_eq "tasks run in 2 distinct AZs" "$azs" "2"
  check "ECR scan-on-push is enabled" bash -c "[ \"\$(aws ecr describe-repositories --repository-names '$(tf_out ecr_repository)' --query 'repositories[0].imageScanningConfiguration.scanOnPush' --output text)\" = True ]"
  source "$ROOT/tests/smoke/failover.sh"
  summary
}

run 2>&1 | python3 "$REDACT" | tee "$OUT"
exit "${PIPESTATUS[0]}"
