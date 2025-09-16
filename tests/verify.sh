#!/usr/bin/env bash
set -euo pipefail
P="${PROXY_BASE:-http://127.0.0.1:18080}"
echo "Proxy health:"; curl -fsS "$P/healthz" && echo
echo "Proxy routes:"
curl -fsS "$P/app1/hello" && echo
curl -fsS "$P/app2/hello" && echo
echo "Direct apps:"
curl -fsS http://127.0.0.1:15000/hello && echo
curl -fsS http://127.0.0.1:13000/hello && echo
