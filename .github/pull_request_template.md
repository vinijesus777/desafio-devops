# Entrega: Desafio DevOps

## Objetivo
Descrever brevemente o que este PR entrega (stack, observabilidade, CI, etc.).

## Como testar
1. `docker compose up -d --build`
2. Verificar endpoints via proxy: `http://127.0.0.1:18080/app1/hello` e `/app2/hello`
3. Prometheus: `http://127.0.0.1:19090/targets`
4. Grafana: `http://127.0.0.1:13001` → Dashboard **Desafio DevOps — Overview**

## Evidências
- [ ] Print Prometheus Targets (UP)
- [ ] Print Grafana Dashboard com tráfego
- [ ] CI (Actions) verde

## Extras
- [ ] Alertas no Prometheus (AppDown, CacheHitLow)
- [ ] Scripts de verificação e carga em `tests/`
