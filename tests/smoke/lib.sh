#!/usr/bin/env bash
# Tiny smoke-test harness. Source from tests/smoke/run.sh.
#   check "description" <command...>     pass if command exits 0
#   expect_eq "description" <actual> <expected>
#   retry <attempts> <sleep-seconds> <command...>
#   http_code <url>                      prints HTTP status code
#   tf_out <name>                        terraform output -raw <name> for $ENV (non-sensitive outputs only)
PASS=0; FAIL=0; RESULTS=()
ts() { date -u +%H:%M:%SZ; }
check() {
  local desc="$1"; shift
  if "$@" >/dev/null 2>&1; then PASS=$((PASS+1)); RESULTS+=("PASS  $desc"); echo "[$(ts)] PASS  $desc"
  else FAIL=$((FAIL+1)); RESULTS+=("FAIL  $desc"); echo "[$(ts)] FAIL  $desc"; fi
}
expect_eq() {
  local desc="$1" actual="$2" expected="$3"
  if [ "$actual" = "$expected" ]; then PASS=$((PASS+1)); RESULTS+=("PASS  $desc"); echo "[$(ts)] PASS  $desc ($actual)"
  else FAIL=$((FAIL+1)); RESULTS+=("FAIL  $desc"); echo "[$(ts)] FAIL  $desc (got '$actual', want '$expected')"; fi
}
retry() { local n="$1" s="$2"; shift 2; for ((i=1;i<=n;i++)); do "$@" && return 0; sleep "$s"; done; return 1; }
http_code() { curl -s -o /dev/null -w '%{http_code}' --max-time 15 "$1"; }
export -f http_code
tf_out() { terraform -chdir="$ROOT/envs/$ENV" output -raw "$1" 2>/dev/null; }
summary() {
  echo; echo "Smoke tests ($ENV): $PASS passed, $FAIL failed — $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  [ "$FAIL" -eq 0 ]
}
