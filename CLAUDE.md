# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Install dependencies
cd src && npm ci --only=production

# Run locally (requires PostgreSQL)
cd src && npm start

# Run with live reload (dev mode)
cd src && node --watch server.js

# Docker Compose (app + postgres)
docker-compose up

# Build and push image to DOCR
docker build -t registry.digitalocean.com/kube-news-rafael/kube-news:latest .
docker push registry.digitalocean.com/kube-news-rafael/kube-news:latest

# Deploy to Kubernetes
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/

# Check deploy status
kubectl get pods -n kube-news
kubectl get svc kube-news-service -n kube-news
```

## Architecture

The app is a Node.js/Express news portal with server-rendered EJS templates and a PostgreSQL backend via Sequelize.

**Request flow:** every request passes through two middlewares before reaching routes:
1. `middleware.js` — increments a Prometheus counter (`http_requests_total`)
2. `system-life.js#healthMid` — returns 500 for all requests if `PUT /unhealth` was called (in-memory flag, resets on pod restart)

**`system-life.js`** serves dual purposes: it exports both the health/readiness router (`/health`, `/ready`, `/unhealth`, `/unreadyfor/:seconds`) and the `healthMid` middleware. The chaos endpoints are intentional — used to test Kubernetes liveness/readiness probe behavior.

**`models/post.js`** holds all database config (read from env vars with defaults) and calls `seque.sync({ alter: true })` on startup, so the schema auto-migrates on each deploy. There are no migration files.

**Single model:** `Post` (title ≤30, summary ≤50, content ≤2000 chars, publishDate).

**Metrics:** `express-prom-bundle` auto-instruments all routes at `/metrics`. The custom counter in `middleware.js` adds `http_requests_total` with `method` and `path` labels.

## Environment Variables

All defined in `src/models/post.js` with fallback defaults:

| Variable | Default |
|---|---|
| `DB_HOST` | `localhost` |
| `DB_PORT` | `5432` |
| `DB_DATABASE` | `kubedevnews` |
| `DB_USERNAME` | `kubedevnews` |
| `DB_PASSWORD` | `Pg#123` |
| `DB_SSL_REQUIRE` | `false` |

## Kubernetes (DOKS)

Manifests live in `k8s/`. The cluster is `k8s-aula` (NYC1) on DigitalOcean with 2 nodes `s-2vcpu-2gb`.

**Critical:** the PostgreSQL PVC uses `storageClassName: do-block-storage`. DigitalOcean block volumes are initialized with a `lost+found` directory, so the postgres container requires `PGDATA=/var/lib/postgresql/data/pgdata` (a subdirectory) — otherwise `initdb` fails.

**Image registry:** `registry.digitalocean.com/kube-news-rafael`  
**Pull secret in cluster:** `registry-kube-news` (namespace `kube-news`)  
**App LoadBalancer IP:** `137.184.240.203`

To re-authenticate doctl:
```bash
doctl auth init --access-token <token>
doctl kubernetes cluster kubeconfig save k8s-aula
```

## Seed Data

Use `popula-dados.http` with VS Code REST Client or curl to bulk-insert posts via `POST /api/post` with a JSON body `{ "artigos": [...] }`.
