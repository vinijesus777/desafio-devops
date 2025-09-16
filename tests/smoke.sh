#!/usr/bin/env bash
set -euo pipefail

# =======================
# Config (override via env)
# =======================
PROXY_PORT="${PROXY_PORT:-18080}"
APP1_PORT="${APP1_PORT:-15000}"
APP2_PORT="${APP2_PORT:-13000}"
RETRIES="${RETRIES:-40}"        # tentativas por endpoint
SLEEP_SECS="${SLEEP_SECS:-3}"   # intervalo entre tentativas

PROXY_BASE="http://127.0.0.1:${PROXY_PORT}"

echo "[SMOKE] Config -> proxy:${PROXY_PORT} app1:${APP1_PORT} app2:${APP2_PORT} retries:${RETRIES} wait:${SLEEP_SECS}s"

curl_retry () {
  local url="$1"
  local name="$2"
  local i=1
  while (( i <= RETRIES )); do
    if curl -fsS --max-time 5 "$url" > /dev/null; then
      echo "[SMOKE] OK -> $name ($url)"
      return 0
    fi
    echo "[SMOKE] waiting -> $name ($url) [${i}/${RETRIES}]"
    sleep "$SLEEP_SECS"
    ((i++))
  done
  echo "[SMOKE] FAIL -> $name ($url)"
  # exibe conteúdo/erro para troubleshooting final
  curl -v "$url" || true
  exit 1
}

# --------
# Checks
# --------
curl_retry  "${PROXY_BASE}/healthz"        "proxy health"

curl_retry  "http://127.0.0.1:${APP1_PORT}/hello"  "app1 /hello"
curl_retry  "http://127.0.0.1:${APP1_PORT}/time"   "app1 /time"

curl_retry  "http://127.0.0.1:${APP2_PORT}/hello"  "app2 /hello"
curl_retry  "http://127.0.0.1:${APP2_PORT}/time"   "app2 /time"

curl_retry  "${PROXY_BASE}/app1/hello"     "proxy /app1/hello"
curl_retry  "${PROXY_BASE}/app2/hello"     "proxy /app2/hello"

echo "[SMOKE] SUCCESS ✅"
