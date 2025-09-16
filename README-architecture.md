## Arquitetura (Mermaid)

```mermaid
flowchart LR
  subgraph Client
    U[User/CI]
  end

  U -->|HTTP| Nginx[Proxy Nginx (18080)]
  Nginx -->|/app1/*| A1[app1-flask (5000)]
  Nginx -->|/app2/*| A2[app2-express (3000)]

  A1 <-->|GET/SET| R[(Redis 6379)]
  A2 <-->|GET/SET| R

  P[Prometheus (19090)] -->|scrape /metrics| A1
  P -->|scrape /metrics| A2

  G[Grafana (13001)] -->|Prometheus datasource| P
```
