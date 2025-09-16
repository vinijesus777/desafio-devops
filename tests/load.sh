#!/usr/bin/env bash
set -euo pipefail

SECONDS_TOTAL="${1:-60}"
PROXY_BASE="${PROXY_BASE:-http://127.0.0.1:18080}"
PROM="${PROM:-http://127.0.0.1:19090}"

routes=(
  "$PROXY_BASE/app1/hello"
  "$PROXY_BASE/app1/time"
  "$PROXY_BASE/app2/hello"
  "$PROXY_BASE/app2/time"
)

echo ">>> Warm-up..."
for r in "${routes[@]}"; do curl -fsS "$r" >/dev/null || true; done

echo ">>> Load test for ${SECONDS_TOTAL}s..."
end=$(( $(date +%s) + SECONDS_TOTAL ))
ok=0; fail=0
while [ "$(date +%s)" -lt "$end" ]; do
  for r in "${routes[@]}"; do
    if curl -fsS --max-time 5 "$r" >/dev/null; then ok=$((ok+1)); else fail=$((fail+1)); fi
    sleep 0.12
  done
done

echo ">>> Done."
echo "OK: $ok  FAIL: $fail"

echo ">>> Prometheus targets:"
if curl -fsS "$PROM/targets" >/dev/null; then
  echo "Open: $PROM/targets"
else
  echo "Prometheus unreachable at $PROM" >&2
fi

cat <<'PROMQL'

>>> Suggested PromQL quick checks:

sum(app_requests_total)
sum by (service,endpoint) (rate(app_requests_total[5m]))
sum(rate(app_cache_hits_total[5m])) / (sum(rate(app_cache_hits_total[5m])) + sum(rate(app_cache_misses_total[5m])))

PROMQL
