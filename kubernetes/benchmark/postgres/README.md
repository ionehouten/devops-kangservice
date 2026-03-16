# PostgreSQL Benchmark — Kubernetes Native

> Kubernetes-native `pgbench` runner used to produce the data in:
> **[Bare Metal vs. AWS RDS: A Deep Dive into NUMA-Aware Tuning and PostgreSQL Performance](https://dev.to/ionehouten/bare-metal-vs-aws-rds-a-deep-dive-into-numa-aware-tuning-and-postgresql-performance-1fil)**

Runs a full benchmark matrix (Read-Only, Read-Write, TPC-B) across multiple client/thread combinations against any PostgreSQL-compatible endpoint — CloudNativePG, AWS RDS, Aurora, or standalone PostgreSQL.

---

## Files

```
postgres/
├── namespace.yaml          # benchmark namespace
├── configmap.yaml          # all benchmark scripts (see Scripts section)
├── secret.example.yaml     # connection & test parameters (copy → secret.yaml)
├── job.yaml                # one-shot Job (recommended for benchmarking)
├── deployment.yaml         # long-running runner (for interactive/manual testing)
```

---

## Scripts (inside ConfigMap)

| Script | Description |
|---|---|
| `run-benchmark-job.sh` | Main entrypoint — orchestrates all scripts below |
| `benchmark.sh` | Core pgbench runner — READ-ONLY, READ-WRITE, TPC-B, latency tests |
| `monitor.sh` | Background monitor — collects pg_stat_activity, cache hit ratio, locks to CSV |
| `query-test.sh` | Supplementary query tests — SELECT, JOIN, aggregation, EXPLAIN ANALYZE |
| `analyze-results.sh` | Post-run analysis — extracts TPS values, calculates averages, generates summary |

---

## Quick Start

**1. Copy and configure the secret**

```bash
cp secret.example.yaml secret.yaml
```

Edit `secret.yaml` with your target database:

```yaml
stringData:
  DB_HOST: "postgres.production.svc.cluster.local"  # or RDS endpoint
  DB_PORT: "5432"
  DB_USER: "postgres"
  DB_PASSWORD: "your-password"
  DB_NAME: "benchmark_db"
  SCALE_FACTOR: "100"    # 100 = ~10M rows, ~1.5GB table
  DURATION: "300"        # seconds per test run
  MAX_CLIENTS: "100"
  WARMUP_TIME: "30"
```

**2. Deploy via Kustomize**

```bash
kubectl apply -k .
```

**3. Follow the logs**

```bash
kubectl logs -n benchmark -l app=pgbench -f
```

**4. Cleanup**

```bash
kubectl delete -k .
```

---

## Test Matrix

The benchmark runs every combination of clients × threads:

```
Clients: 1, 10, 25, 50, 100
Threads: 1, 4, 8
Test types: READ-ONLY (-S), READ-WRITE (-N), TPC-B (tpcb-like)
```

Total: **39 test runs** per environment (13 combinations × 3 workload types).

---

## Two Run Modes

| Mode | File | Use Case |
|---|---|---|
| **Job** (default) | `job.yaml` | One-shot benchmark run, auto-completes |
| **Deployment** | `deployment.yaml` | Interactive testing, stays alive after run |

To switch to Deployment mode, edit `kustomization.yaml`:

```yaml
resources:
  # - job.yaml
  - deployment.yaml   # ← uncomment this
```

---

## Persisting Results

By default results are written to an `emptyDir` volume (lost when pod terminates).

Results will be written to `/benchmark-results/` inside the pod, including:
- `cnpg_benchmark_report_<timestamp>.txt` — full pgbench output
- `monitoring_<timestamp>.csv` — pg_stat metrics over time
- `summary_<timestamp>.txt` — extracted TPS averages

---

## Key Findings (Scale Factor 100, 2 vCPU / 8 GB RAM)

| Environment | Avg TPS (all tests) | Peak Read TPS | Peak Write TPS |
|---|---|---|---|
| AWS RDS (t3.large) | **4,826** | 13,955 | 2,839 |
| AWS Aurora IO-Prov. | 3,480 | 10,928 | 1,622 |
| **CNPG Bare Metal ③** | **3,351** | 8,325 | 1,954 |
| CNPG Bare Metal ② | 3,214 | 8,065 | 1,908 |
| AWS Aurora Standard | 3,326 | 10,020 | 1,557 |
| CNPG + Longhorn | 1,655 | 6,165 | 1,318 |

**56% latency reduction** from Tuning ① → ③ on the same hardware, purely from config changes.

→ Full analysis in the [article](https://dev.to/ionehouten/bare-metal-vs-aws-rds-a-deep-dive-into-numa-aware-tuning-and-postgresql-performance-1fil).

---

## Notes

- `secret.yaml` is gitignored — never commit real credentials
- `backoffLimit: 3` prevents infinite retries on connection failure
- No custom image needed — uses stock `postgres:17-alpine`
- To benchmark against CNPG, set `DB_HOST` to the cluster's `-rw` service (e.g. `my-cluster-rw.default.svc.cluster.local`)
- `COLLECT_PG_STAT: "true"` enables additional pg_stat collection via `monitor.sh`
