# Phase 8 — Container & Runtime Security Coverage

## Status

**COMPLETE — PASS**

Phase 8 hardened the project's Docker container and runtime environment while preserving the API, worker, and PostgreSQL application workflow.

## Coverage Summary

| Section | Control Area | Result |
|---|---|---|
| 8.1 | Dockerfile and runtime baseline review | PASS |
| 8.2 | Runtime image minimization | PASS |
| 8.3 | Non-root enforcement | PASS |
| 8.4 | Linux capability restrictions | PASS |
| 8.5 | Read-only filesystem controls | PASS |
| 8.6 | Network exposure and segmentation | PASS |
| 8.7 | Runtime health and functional validation | PASS |
| 8.8 | Runtime security regression gate | PASS |
| 8.9 | Secret hardening, evidence, and closure | PASS |

## Implemented Controls

### Image Hardening

- Multi-stage Maven build remains in use.
- API and Worker use JRE-only runtime images.
- Unnecessary runtime `apk upgrade` operations were removed.
- Runtime image size was reduced while maintaining functionality.
- Build and runtime responsibilities remain separated.

### Non-Root Execution

- API executes as `appuser`.
- Worker executes as `appuser`.
- PostgreSQL server processes execute as non-root UID 70.
- Application containers do not run in privileged mode.

### Linux Privilege Reduction

API and Worker enforce:

- `cap_drop: ALL`
- `no-new-privileges:true`
- non-privileged execution

Runtime validation confirmed the expected restrictions remain active.

### Filesystem Hardening

API and Worker enforce:

- read-only root filesystems
- blocked writes to protected application paths
- dedicated writable `/tmp` tmpfs
- `noexec`
- `nosuid`
- bounded temporary storage

PostgreSQL retains writable persistent database storage because it is a stateful service.

### Network Segmentation

The original shared application network was replaced with separate networks:

- `api-db`
- `worker-db`

The API connects only to `api-db`.

The Worker connects only to `worker-db`.

PostgreSQL connects to both networks because both application services require database access.

The Worker network is configured as internal.

Validation confirmed:

- API can reach PostgreSQL.
- Worker can reach PostgreSQL.
- API cannot directly resolve Worker.
- Worker cannot directly resolve API.

### Host Exposure

Only the API is published to the host:

`127.0.0.1:8081 -> 8080/tcp`

PostgreSQL is not host-published.

Worker is not host-published.

### Runtime Health Validation

The hardened stack was validated after the runtime controls were applied.

Validation confirmed:

- API running
- Worker running
- PostgreSQL healthy
- API health endpoint healthy
- hardened runtime controls active

### End-to-End Functional Validation

A runtime validation job was submitted through the API.

The job transitioned from:

`pending -> done`

The completed database record confirmed that:

- API job creation succeeded.
- PostgreSQL stored the job.
- Worker retrieved the job.
- Worker completed the job.
- `picked_at` was populated.
- `done_at` was populated.

This demonstrated that the security hardening did not break the application workflow.

### Runtime Security Regression Gate

A reusable regression script was created:

`security-tests/runtime/phase8-runtime-regression.ps1`

The regression gate validates:

- container availability
- API health
- non-root execution
- PostgreSQL non-root server processes
- read-only application filesystems
- blocked protected-path writes
- writable tmpfs
- dropped Linux capabilities
- disabled privileged mode
- no-new-privileges
- restricted host exposure
- database connectivity
- service network isolation

Final regression result:

`FINAL RESULT: PASS`

Exit code:

`0`

### Runtime Secret Hardening

The database password is no longer hard-coded directly in `docker-compose.yml`.

Runtime configuration now uses environment-variable injection.

The real local credential is stored in:

`.env`

The `.env` file is ignored by Git.

A safe committed template is provided:

`.env.example`

No real runtime password is stored in the template.

## Evidence

Phase 8 evidence is stored under:

`evidence/phase8-container-runtime/`

Evidence is organized by section:

- `8.1`
- `8.2`
- `8.3`
- `8.4`
- `8.5`
- `8.6`
- `8.7`
- `8.8`
- `8.9`

Screenshots are stored under:

`screenshots/phase8-container-runtime/`

## Residual Security Considerations

The following image references currently remain tag-based rather than digest-pinned:

- `maven:3.9-eclipse-temurin-17-alpine`
- `eclipse-temurin:17-jre-alpine`
- `postgres:16-alpine`

Immutable digest pinning is therefore documented as future supply-chain hardening work.

Phase 8 does not claim that image digest pinning has been implemented.

## Final Result

**PASS**

Phase 8 — Container & Runtime Security is complete.
