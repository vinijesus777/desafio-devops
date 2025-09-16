$proxy = "http://127.0.0.1:18080"
$direct1 = "http://127.0.0.1:15000/hello"
$direct2 = "http://127.0.0.1:13000/hello"

Write-Host "Proxy health:" -ForegroundColor Yellow
Invoke-WebRequest "$proxy/healthz" | Out-Null; "OK"

Write-Host "Proxy routes:" -ForegroundColor Yellow
(Invoke-WebRequest "$proxy/app1/hello").Content
(Invoke-WebRequest "$proxy/app2/hello").Content

Write-Host "Direct apps:" -ForegroundColor Yellow
(Invoke-WebRequest $direct1).Content
(Invoke-WebRequest $direct2).Content
