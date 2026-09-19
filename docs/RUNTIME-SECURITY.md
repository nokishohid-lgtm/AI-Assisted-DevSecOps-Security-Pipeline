# Runtime Security — Container and Orchestrator Hardening

## Runtime Threat Model

Assuming the container image is compromised, what limits blast radius?

## Container Hardening Checklist

| Control | Value | Why |
|---|---|---|
| User | Non-root (`appuser`, UID 1000) | Prevent host file ownership issues |
| Filesystem | read-only rootfs | Prevent persistence |
| Writable paths | `/tmp` as tmpfs, noexec, nosuid, size=64m | Allow temp files, block execution |
| Capabilities | `--cap-drop ALL` | Remove all privileged operations |
| Privilege escalation | `--security-opt no-new-privileges:true` | Block setuid binaries |
| Resource limits | `--memory 256m --cpus 1.0` | Contain DoS blast radius |
| Network | Bind to `127.0.0.1` only | Prevent external access |
| Image base | Alpine (musl, minimal) | Reduce attack surface |
| Image content | Multi-stage build | No build tools in runtime |

## Example Run Command

    docker run -d --name app \
      --read-only \
      --tmpfs /tmp:rw,noexec,nosuid,size=64m \
      --cap-drop ALL \
      --security-opt no-new-privileges:true \
      --memory 256m --cpus 1.0 \
      -p 127.0.0.1:8081:8080 \
      devsecops-security-app:local

## What These Controls Do NOT Cover

- Kernel exploits (need seccomp / gVisor / Kata for that)
- Application-level RCE inside the container (need WAF, RASP)
- Supply-chain compromise of the base image (need provenance + SBOM)
- Zero-days in the JVM or Alpine packages

## Kubernetes Equivalents (Phase 2)

| Docker flag | K8s field |
|---|---|
| `--read-only` | `securityContext.readOnlyRootFilesystem: true` |
| `--cap-drop ALL` | `securityContext.capabilities.drop: ["ALL"]` |
| `no-new-privileges` | `securityContext.allowPrivilegeEscalation: false` |
| non-root user | `securityContext.runAsNonRoot: true` |
| `--memory 256m` | `resources.limits.memory: 256Mi` |
| `--cpus 1.0` | `resources.limits.cpu: "1"` |

## Admission Control (Phase 2)

Before a pod starts, verify:
1. Image is signed by our CI workflow (Cosign + Rekor)
2. Signature identity matches expected repo + branch
3. No privileged flags
4. Non-root user

Tools: Kyverno, OPA Gatekeeper, Sigstore Policy Controller.

## Runtime Detection (Phase 3)

Falco rules to detect:
- Shell spawned inside container
- Unexpected outbound network connection
- Write to `/etc`, `/bin`, `/usr`
- `ptrace`, `mount`, `setns` syscalls
- Reads of `/etc/shadow`, `/proc/*/mem`

## Logging and Forensics

- stdout/stderr shipped to centralized logging
- Container runtime events (start/stop/OOM) retained 30 days
- Falco alerts routed to incident channel
