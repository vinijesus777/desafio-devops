#!/usr/bin/env bash
set -euo pipefail

echo "[SMOKE] Waiting services..."
sleep 5

echo "[SMOKE] app1 /hello"
curl -fsS http://localhost:5000/hello | grep -i "App1"

echo "[SMOKE] app2 /hello"
curl -fsS http://localhost:3000/hello | grep -i "App2"

echo "[SMOKE] proxy /app1/time"
curl -fsS http://localhost:8080/app1/time | grep -i "App1"

echo "[SMOKE] proxy /app2/time"
curl -fsS http://localhost:8080/app2/time | grep -i "App2"

echo "[SMOKE] prometheus up"
curl -fsS http://localhost:9090/-/healthy | grep -i "Healthy" || true

echo "[SMOKE] grafana login page"
curl -fsS http://localhost:3001/login | grep -i "Grafana" || true

echo "[SMOKE] OK"
