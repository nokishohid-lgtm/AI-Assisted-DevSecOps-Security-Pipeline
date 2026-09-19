# ADR-003: Use Trivy over Grype/Snyk for Container Scanning

**Status:** Accepted
**Date:** 2026-09-18
**Deciders:** Project maintainer

## Context

The pipeline needs to scan container images for known-vulnerable
dependencies and fail the build on fixable HIGH/CRITICAL CVEs within a
30-day remediation window.

## Decision

Use Aqua Security's Trivy.

## Consequences

**Positive:**
- Single binary, no account or API key required.
- Covers OS packages, language deps, IaC misconfig, and secrets.
- Native GitHub Actions integration and SARIF output for code scanning.
- Fast enough for CI without caching tricks.

**Negative:**
- Advisory DB lag vs. commercial feeds (Snyk).
- Less accurate reachability analysis than Snyk.
- Occasional false positives on unfixed upstream packages.

## Alternatives Considered

1. **Grype** - Excellent, but narrower (vuln-only, no IaC/secrets).
2. **Snyk** - Best UX/accuracy, but requires token + paid tier for CI scale.
3. **Clair** - Heavier to operate; better suited to registry-side scanning.
