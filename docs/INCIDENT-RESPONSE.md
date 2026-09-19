# Incident Response — Runbooks

## Severity Levels

| Level | Definition | Response Time |
|---|---|---|
| SEV-1 | Active exploit, data exfiltration, or public leak | 15 min |
| SEV-2 | Known vulnerable dependency in production | 1 hour |
| SEV-3 | Suspicious activity, failed policy, no exploit | 1 business day |
| SEV-4 | Documentation, drift, minor misconfiguration | 1 week |

## Runbook 1: Secret Leaked to Git History

**Detection:** Gitleaks alert, GitHub secret scanning, or external report

**Steps:**
1. Contain — Rotate the leaked credential immediately (before anything else)
2. Assess — Identify which commits contain the secret: `git log -S "secret_value"`
3. Scope — Confirm whether the secret was used externally (check provider logs)
4. Eradicate — Rewrite history with `git filter-repo` or BFG; force-push
5. Notify — Inform affected parties per policy
6. Recover — Confirm rotated credential works; audit for unauthorized use
7. Post-mortem — Publish 48h after resolution, no blame

**Prevention:** Gitleaks pre-commit hook + branch protection

## Runbook 2: New CVE Affects a Runtime Dependency

**Detection:** Dependabot alert, Trivy nightly scan, or external advisory

**Steps:**
1. Assess — Is the vulnerable package in the SBOM? `grep <pkg> sbom/*.json`
2. Severity — Is it reachable from our code path? Check usage with `mvn dependency:tree`
3. Fix — Bump the dependency (Dependabot PR if available)
4. Test — Run full CI; confirm no breakage
5. Deploy — Merge to main, let container-release rebuild + re-sign
6. Verify — Re-run Trivy on the new image; confirm CVE gone
7. Document — Update `docs/METRICS.md` with time-to-remediate

**Target:** SEV-2 resolved within 24h for fixable HIGH/CRITICAL

## Runbook 3: Container Image Tampered or Unsigned

**Detection:** Cosign verify fails, or registry reports unexpected digest

**Steps:**
1. Stop deploys — Enable admission controller deny-all policy
2. Identify — Compare published digest against signed digest in Rekor
3. Isolate — Pull the affected image from any running environments
4. Rebuild — Re-run container-release on a known-good commit
5. Re-sign — Cosign keyless signing produces a fresh Rekor entry
6. Verify — `cosign verify --certificate-identity <repo> --certificate-oidc-issuer <issuer>`
7. Resume — Re-enable admission; document timeline

**Prevention:** Admission controller + mandatory signature verification

## Evidence Collection

- GitHub Actions logs (retained 90 days)
- Rekor entries (immutable, public log)
- SBOM artifacts per release
- ghcr.io image digests

## Communication

- Internal: GitHub issue labeled `incident`
- External: SECURITY.md contact, 72h disclosure window