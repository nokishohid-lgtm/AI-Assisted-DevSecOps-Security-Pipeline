# ADR-005: Use CycloneDX over SPDX for SBOM

**Status:** Accepted
**Date:** 2026-09-18
**Deciders:** Project maintainer

## Context

An SBOM must be generated on every build so that, when a new CVE lands
(e.g. log4shell-class), the team can answer "are we affected?" within 24
hours. Two dominant formats: CycloneDX and SPDX.

## Decision

Use CycloneDX (JSON) as the primary SBOM format.

## Consequences

**Positive:**
- Security-first design: includes vulnerabilities, VEX, and services.
- First-class tooling (Syft, Trivy, cdxgen) and GitHub dependency graph.
- Easier to attach VEX statements for false-positive suppression.
- Native support in Dependency-Track for continuous monitoring.

**Negative:**
- SPDX has stronger legal/licensing pedigree for compliance teams.
- Some enterprise scanners still prefer SPDX.
- Two formats may be needed for full coverage.

## Alternatives Considered

1. **SPDX** - License-centric; weaker vuln/VEX story.
2. **SWID** - Too narrow for full dependency graph.
3. **No SBOM** - Fails the 24-hour CVE response objective outright.
