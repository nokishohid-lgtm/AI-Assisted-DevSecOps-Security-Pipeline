# Synthetic SCA Risk Acceptance Example

## Vulnerability Information

- Vulnerability ID: CVE-2099-0002
- Dependency: synthetic-demo-library
- Installed Version: 1.0.0
- Severity: HIGH
- Fixed Version: None Available
- Detection Tool: OWASP Dependency-Check / Trivy

## Risk Analysis

- Vulnerability Description: Synthetic vulnerability used only to demonstrate the risk acceptance process.
- Application Exposure: Not applicable to production.
- Exploitability: Synthetic test case only.
- Business / Technical Impact: No real application impact.

## Remediation Status

- Immediate Fix Available: No
- Reason Fix Is Not Applied: No synthetic fixed version is available.
- Planned Remediation: Remove the test exception after Phase 7 validation.

## Compensating Controls

- Control 1: SCA severity gate remains enabled.
- Control 2: Exception is explicitly documented.
- Control 3: Exception is time-limited.

## Approval

- Risk Owner: Project Maintainer
- Approval Status: Approved for synthetic test only
- Approval Date: 2026-10-11
- Expiration Date: 2026-10-18

## Review

- Review Date: 2026-10-11
- Review Result: Synthetic validation only
- Exception Removed: Pending Phase 7 completion
