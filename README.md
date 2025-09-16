# Desafio DevOps 2025 — Solução

- Duas aplicações (Flask + Express) com `/hello` e `/time`.
- Cache Redis com TTLs distintos (10s / 60s).
- Observabilidade: métricas Prometheus; Grafana com dashboard provisionado.
- Proxy NGINX unificando acesso: `http://localhost:8080/app1/*` e `/app2/*`.
- Healthchecks, usuários não-root, variáveis via `.env`, smoke tests e CI.

## Como rodar
```bash
cp .env.example .env   # opcional
docker compose up --build
# (em outro terminal)
./tests/smoke.sh
```

- App1: http://localhost:5000/hello  
- App2: http://localhost:3000/hello  
- Proxy: http://localhost:8080/app1/hello | /app1/time | /app2/hello | /app2/time  
- Prometheus: http://localhost:9090  
- Grafana: http://localhost:3001  (admin/admin — configure via .env)

## 🔬 Teste rápido (sanity check)

**Windows (PowerShell):**
```powershell
./tests/verify.ps1
```

**Linux/Mac/WSL:**
```bash
./tests/verify.sh
```

## 🚀 Gerar tráfego para observar no Grafana/Prometheus

**Windows (PowerShell) – 60s padrão:**
```powershell
./tests/load.ps1 -Seconds 60
```

**Linux/Mac/WSL – 60s padrão:**
```bash
./tests/load.sh 60
```

Depois, abra:
- Prometheus Targets: `http://127.0.0.1:19090/targets`  
- Grafana: `http://127.0.0.1:13001` → Dashboard **Desafio DevOps — Overview** → *Refresh*

### Queries úteis (PromQL)
- `sum(app_requests_total)`
- `sum by (service,endpoint) (rate(app_requests_total[5m]))`
- `sum(rate(app_cache_hits_total[5m])) / (sum(rate(app_cache_hits_total[5m])) + sum(rate(app_cache_misses_total[5m])))`

## 🏗️ Arquitetura & Trade-offs

### Componentes
- **app1-flask**: API Python/Flask com TTL de cache curto (10s).
- **app2-express**: API Node/Express com TTL de cache longo (60s).
- **Redis**: cache compartilhado entre as apps.
- **Prometheus**: coleta métricas customizadas e de sistema.
- **Grafana**: dashboards prontos (requests, cache hit ratio, latência).
- **Proxy Nginx**: reverse proxy unificado para expor as duas APIs.

### Decisões tomadas
- **Proxy Nginx** para unificar acesso e facilitar TLS/ratelimit/Auth no futuro.
- **Métricas customizadas** via `/metrics` em ambas as apps; scrape pelo Prometheus.
- **TTLs distintos** para simular cenários de frescor vs. performance.
- **Portas altas** por padrão (15000, 13000, 18080, 19090, 13001) para evitar conflitos no host.
- **Healthchecks** configurados (Redis/Flask/Express) para feedback no `docker compose ps`.
- **Scripts de teste** em `tests/` para validação e geração de carga.

### Melhorias futuras
- TLS real no Nginx com certificados montados.
- Alertas no Prometheus (erro rate, disponibilidade).
- Mais painéis (latência P95, Redis ops).
- CI/CD com build multi-stage e testes automatizados.
