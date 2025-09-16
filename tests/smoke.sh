#!/usr/bin/env bash
set -euo pipefail

echo "[SMOKE] Waiting services..."

# healthcheck simples do proxy
for i in {1..40}; do
  if curl -fsS http://127.0.0.1:18080/healthz > /dev/null; then
    echo "[SMOKE] Proxy is healthy"
    break
  fi
  echo "[SMOKE] Waiting proxy..."
  sleep 3
done

echo "[SMOKE] app1 /hello"
curl -fsS http://127.0.0.1:15000/hello

echo "[SMOKE] app2 /hello"
curl -fsS http://127.0.0.1:13000/hello

echo "[SMOKE] proxy /app1/hello"
curl -fsS http://127.0.0.1:18080/app1/hello

echo "[SMOKE] proxy /app2/hello"
curl -fsS http://127.0.0.1:18080/app2/hello

echo "[SMOKE] SUCCESS"
