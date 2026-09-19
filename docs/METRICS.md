# Metrics — Security and Delivery KPIs

## Why Metrics Matter

You cannot improve what you do not measure. This document defines the
metrics this pipeline tracks, their targets, and how they are collected.

## DORA Metrics (Delivery Health)

| Metric | Definition | Target | Source |
|---|---|---|---|
| Deployment Frequency | Merges to main / week | Daily | Git log |
| Lead Time for Changes | Commit -> deployed | < 1 day | GitHub Actions timestamps |
| Change Failure Rate | Reverted merges / total | < 15% | Git revert history |
| Time to Restore | Incident start -> fix merged | < 4 hours | Incident labels |

## Security Metrics

| Metric | Definition | Target | Source |
|---|---|---|---|
| MTTR-CVE | CVE detected -> fix deployed | < 30 days (HIGH/CRITICAL < 7 days) | Trivy + Dependabot |
| Secret Detection Rate | Secrets caught pre-merge / total | 100% | Gitleaks logs |
| SAST Findings per PR | New CodeQL alerts per PR | 0 for HIGH/CRITICAL | CodeQL results |
| Signed Image Coverage | Signed images / published images | 100% | Cosign verify |
| SBOM Coverage | Builds with SBOM / total builds | 100% | sbom workflow |
| Policy Violation Rate | Blocked PRs / total PRs | < 10% | Conftest logs |
| Mean Time to Detect | Breach -> detection | < 1 hour | Runtime detection (Phase 3) |

## Pipeline Health

| Metric | Target |
|---|---|
| CI pipeline duration | < 8 minutes (excluding ZAP) |
| ZAP scan duration | < 3 minutes |
| Trivy scan duration | < 2 minutes |
| Total PR check time | < 15 minutes |
| CI success rate | > 95% |

## Reporting Cadence

- Weekly: PR count, MTTR-CVE, failed checks
- Monthly: DORA metrics, top 5 recurring CVEs, policy exceptions
- Quarterly: Trend analysis, target adjustment, tooling review

## Anti-Metrics (do NOT optimize for these)

- Number of security tools installed (vanity)
- Raw CVE count (ignores reachability)
- Number of policies written (ignores enforcement)
- Lines of security code (meaningless)
