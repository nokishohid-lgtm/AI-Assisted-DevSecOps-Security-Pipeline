# ADR-001: Use GitHub Actions over Jenkins/GitLab CI

**Status:** Accepted
**Date:** 2026-09-18
**Deciders:** Project maintainer

## Context

The pipeline must run SAST, DAST, container scanning, SBOM generation, and
image signing on every push and PR. Candidate CI systems: GitHub Actions,
Jenkins, GitLab CI.

## Decision

Use GitHub Actions.

## Consequences

**Positive:**
- Native OIDC integration with Sigstore (Cosign keyless) and GHCR.
- Zero infrastructure to host; free tier covers this project.
- Marketplace actions for CodeQL, Trivy, ZAP, CycloneDX.
- Required-status-check integration with branch protection is first-class.

**Negative:**
- Vendor lock-in to GitHub.
- Debugging complex workflows is harder than local Jenkins.
- Action pinning discipline required (supply-chain risk).

## Alternatives Considered

1. **Jenkins** - Self-hosted, flexible, but needs a server + maintenance.
2. **GitLab CI** - Strong product, but repo already lives on GitHub.
3. **CircleCI / Buildkite** - Viable; less native Sigstore support.
