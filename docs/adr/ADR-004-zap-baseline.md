# ADR-004: Use OWASP ZAP Baseline over Full Scan

**Status:** Accepted
**Date:** 2026-09-18
**Deciders:** Project maintainer

## Context

Dynamic analysis is required to catch runtime misconfigurations and
missing security headers that SAST cannot see. ZAP offers a baseline
(passive) scan and a full (active) scan.

## Decision

Use the ZAP baseline scan as the default gate; full active scan is
opt-in for scheduled nightly runs.

## Consequences

**Positive:**
- Passive scan is safe against the running app (no destructive payloads).
- Runs in ~1-2 minutes; suitable for every PR.
- Catches missing headers, cookie flags, and obvious misconfig.
- Zero false-positive blocking if rules are tuned via `.zap/rules.tsv`.

**Negative:**
- Does not detect injection-class bugs (requires active scan).
- Sparse JS-heavy SPA coverage without a spider/AJAX setup.
- Business-logic flaws remain out of reach entirely.

## Alternatives Considered

1. **ZAP full active scan on every PR** - Too slow, risky against prod-like env.
2. **Burp Suite Enterprise** - Strong, but commercial and overkill here.
3. **No DAST (SAST only)** - Leaves runtime misconfig undetected.
