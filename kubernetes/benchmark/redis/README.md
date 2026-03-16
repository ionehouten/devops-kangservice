# Redis Benchmark — Kubernetes Native

> Kubernetes-native `redis-benchmark` runner used to produce the data in:
> **[Redis + AOF + Distributed Storage: A Cautionary Benchmark](https://dev.to/ionehouten/redis-aof-distributed-storage-a-cautionary-benchmark-4jf0)**

Tests SET, GET, and PING throughput across different Redis persistence configurations and storage backends (local-path SSD vs Longhorn distributed storage).

---

## Files

```
redis/
├── namespace.yaml        # benchmark namespace
├── configmap.yaml        # benchmark script (redis-benchmark wrapper)
├── secret.example.yaml   # connection & test parameters (copy → secret.yaml)
├── job.yaml              # one-shot Job (recommended for benchmarking)
├── deployment.yaml       # long-running runner (for interactive/manual testing)
└── kustomization.yaml    # deploy everything via kustomize
```

---

## Quick Start

**1. Copy and configure the secret**

```bash
cp secret.example.yaml secret.yaml
```

Edit `secret.yaml` with your Redis connection details:

```yaml
stringData:
  REDIS_HOST: "redis-master.default.svc.cluster.local"
  REDIS_PORT: "6379"
  REDIS_PASSWORD: "your-password"
  PAYLOAD: "180000"    # payload size in bytes (~180 KB)
  CONCURRENCY: "20"    # parallel clients
  REQUESTS: "50000"    # total requests per run
```

**2. Deploy via Kustomize**

```bash
kubectl apply -k .
```

**3. Follow the logs**

```bash
kubectl logs -n benchmark -l app=redis-benchmark-runner -f
```

**4. Cleanup**

```bash
kubectl delete -k .
```

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

## Test Parameters

All results in the article used these parameters:

| Parameter | Value |
|---|---|
| Requests | 50,000 |
| Concurrency | 20 clients |
| Payload | 180,000 bytes (~180 KB) |
| Tests | SET, GET, PING |
| Redis version | 7.2 |

The 180 KB payload reflects realistic cache object sizes for the production workload being benchmarked — not the micro-payload tests common in vendor benchmarks.

---

## Key Findings

| Configuration | SET RPS | SET p99 latency |
|---|---|---|
| Local SSD · AOF off | **7,696** | 5.1 ms |
| Local SSD · AOF on | 1,275 | 102.5 ms |
| Longhorn · AOF on | **537** | 201.9 ms |

**14.3× throughput difference** between AOF-off local and AOF-on Longhorn.
Max observed SET latency on Longhorn: **903 ms**.

→ Full analysis and architecture recommendations in the [article](https://dev.to/ionehouten/redis-aof-distributed-storage-a-cautionary-benchmark-4jf0).

---

## Notes

- `secret.yaml` is gitignored — never commit real credentials
- `backoffLimit: 3` on the Job prevents infinite retries on connection failure
- Script mounts via ConfigMap with `defaultMode: 0755` — no custom image needed, uses stock `redis:7.2`
