param(
  [int]$Seconds = 60,
  [string]$ProxyBase = "http://127.0.0.1:18080",
  [string]$Prom = "http://127.0.0.1:19090"
)

$ErrorActionPreference = "SilentlyContinue"

$routes = @(
  "$ProxyBase/app1/hello",
  "$ProxyBase/app1/time",
  "$ProxyBase/app2/hello",
  "$ProxyBase/app2/time"
)

Write-Host ">>> Warm-up..." -ForegroundColor Cyan
foreach ($r in $routes) { (Invoke-WebRequest $r).StatusCode | Out-Null }

$end = (Get-Date).AddSeconds($Seconds)
$ok = 0; $fail = 0

Write-Host ">>> Load test for $Seconds seconds..." -ForegroundColor Cyan
while ((Get-Date) -lt $end) {
  foreach ($r in $routes) {
    try {
      (Invoke-WebRequest -Uri $r -TimeoutSec 5) | Out-Null
      $ok++
    } catch {
      $fail++
    }
    Start-Sleep -Milliseconds 120
  }
}

Write-Host ">>> Done." -ForegroundColor Green
Write-Host "OK: $ok; FAIL: $fail"

Write-Host ">>> Prometheus targets:" -ForegroundColor Yellow
try {
  (Invoke-WebRequest "$Prom/targets").StatusCode
  Write-Host "Open: $Prom/targets"
} catch {
  Write-Host "Prometheus unreachable at $Prom" -ForegroundColor Red
}

Write-Host ">>> Suggested PromQL quick checks:" -ForegroundColor Yellow
"`n  sum(app_requests_total)"
"`n  sum by (service,endpoint) (rate(app_requests_total[5m]))"
"`n  sum(rate(app_cache_hits_total[5m])) / (sum(rate(app_cache_hits_total[5m])) + sum(rate(app_cache_misses_total[5m])))"
