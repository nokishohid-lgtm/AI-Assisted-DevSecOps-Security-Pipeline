# Architecture — AI-Assisted DevSecOps Security Pipeline

## High-Level Flow

    Developer
       |
       v
    [Git Push / PR]
       |
       v
    +-------------------------------+
    |   GitHub Actions Pipeline     |
    |-------------------------------|
    |  1. Build & Test (Maven)      |
    |  2. CodeQL SAST               |
    |  3. Gitleaks secret scan      |
    |  4. Trivy container scan      |
    |  5. SBOM (CycloneDX)          |
    |  6. Docker build              |
    |  7. Cosign keyless sign       |
    |  8. Push to GHCR              |
    |  9. ZAP DAST baseline         |
    +-------------------------------+
       |
       v
    [GitHub Container Registry (GHCR)]
       |
       v
    [Render / Kubernetes Runtime]
    [read-only rootfs, cap-drop ALL,
     no-new-privileges, non-root]

## Multi-Service Architecture

As of Phase 1, the application runs as two cooperating services backed by
a shared Postgres database.

    +--------------+        +--------------+
    |  API Service |        |   Worker     |
    |  (ApiMain)   |        |  (WorkerMain)|
    |  :8080       |        |  poll loop   |
    +-------+------+        +-------+------+
            |                        |
            |  INSERT jobs           |  UPDATE jobs SET status='done'
            v                        v
        +----------------------------------+
        |           Postgres 16            |
        |           jobs table             |
        +----------------------------------+

### API Service (`src/main/java/.../api/ApiMain.java`)
- `/health` — liveness probe, returns `{"status":"healthy","service":"api"}`
- `POST /jobs` — inserts a pending job, returns `{"id":N,"status":"pending"}`
- `GET /jobs` — returns job counts by status, e.g. `{"pending":0,"done":2}`

### Worker Service (`src/main/java/.../worker/WorkerMain.java`)
- Polls `jobs` every 2 seconds for `status='pending'`
- Uses `SELECT ... FOR UPDATE SKIP LOCKED` so multiple workers can coexist
- Marks processed jobs as `status='done'`, records `picked_at` and `done_at`
- Graceful shutdown via JVM shutdown hook

### Database (`db/init.sql`)
- Single table `jobs` with status lifecycle: `pending → done`
- Loaded automatically by the Postgres container on first start

### Runtime (`docker-compose.yml`)
All three containers run with hardening applied:
- `read_only: true` (api, worker)
- `cap_drop: [ALL]`
- `security_opt: [no-new-privileges:true]`
- `tmpfs: /tmp` with `noexec,nosuid`
- API port bound to `127.0.0.1:8081` only

### CI Enforcement
The `multi-service-smoke` job in `.github/workflows/ci.yml`:
- Spins up Postgres 16 as a GitHub service container
- Runs `MultiServiceIntegrationTest` with `RUN_DB_TESTS=true`
- Builds both `Dockerfile.api` and `Dockerfile.worker`

## Components

### Application (src/)
- Java 17 REST service
- Two endpoints: `/` (status) and `/health`
- Security headers: CSP, X-Content-Type-Options, CORP, Cache-Control
- Built with Maven, tested with JUnit (4 HTTP tests)

### Container (Dockerfile)
- Multi-stage build (builder + runtime)
- Alpine-based Java runtime
- Non-root `appuser`
- Minimal attack surface

### CI/CD (.github/workflows/)
- `ci.yml` — Maven build and unit tests
- `codeql.yml` — SAST for Java
- `gitleaks.yml` — secret detection
- `trivy.yml` — container CVE scanning
- `zap.yml` — DAST baseline
- `sbom.yml` — CycloneDX generation
- `container-release.yml` — sign + publish

### Supply-Chain Security
- Cosign keyless signing via GitHub OIDC
- Rekor transparency log
- CycloneDX SBOM as build artifact
- Pinned action versions (full SHA)

### Runtime Hardening
- read-only root filesystem
- tmpfs at /tmp with noexec,nosuid
- all Linux capabilities dropped
- no-new-privileges
- CPU and memory limits
- Local-only port binding

## Trust Boundaries

1. Developer workstation -> GitHub (TLS + auth)
2. GitHub Actions -> Sigstore (OIDC + Fulcio + Rekor)
3. GitHub Actions -> GHCR (GITHUB_TOKEN, scoped permissions)
4. GHCR -> Runtime (image pull, signature verification at admission)

## Data Flow

- No PII stored
- No external API calls at runtime
- All scanning data stays in GitHub Actions
- SBOM retained as workflow artifact (90 days default)
