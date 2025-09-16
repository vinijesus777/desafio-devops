param(
  [int]$Retries = 40,
  [int]$SleepSecs = 3,
  [int]$ProxyPort = 18080,
  [int]$App1Port = 15000,
  [int]$App2Port = 13000
)

function Curl-Retry($Url, $Name) {
  for ($i=1; $i -le $Retries; $i++) {
    try {
      (Invoke-WebRequest -Uri $Url -TimeoutSec 5 -UseBasicParsing) | Out-Null
      Write-Host "[SMOKE] OK -> $Name ($Url)"
      return
    } catch {
      Write-Host "[SMOKE] waiting -> $Name ($Url) [$i/$Retries]"
      Start-Sleep -Seconds $SleepSecs
    }
  }
  Write-Error "[SMOKE] FAIL -> $Name ($Url)"
  throw
}

$proxy = "http://127.0.0.1:$ProxyPort"

Curl-Retry "$proxy/healthz" "proxy health"

Curl-Retry "http://127.0.0.1:$App1Port/hello" "app1 /hello"
Curl-Retry "http://127.0.0.1:$App1Port/time"  "app1 /time"

Curl-Retry "http://127.0.0.1:$App2Port/hello" "app2 /hello"
Curl-Retry "http://127.0.0.1:$App2Port/time"  "app2 /time"

Curl-Retry "$proxy/app1/hello" "proxy /app1/hello"
Curl-Retry "$proxy/app2/hello" "proxy /app2/hello"

Write-Host "[SMOKE] SUCCESS"
