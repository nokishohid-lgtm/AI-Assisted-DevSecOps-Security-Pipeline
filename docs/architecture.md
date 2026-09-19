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
