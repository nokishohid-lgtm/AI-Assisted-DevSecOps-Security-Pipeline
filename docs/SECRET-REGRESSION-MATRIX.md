Secret Regression Matrix
Purpose
This document defines the reusable secret-detection regression matrix for the
AI-Assisted DevSecOps Security Pipeline.
The matrix maps each controlled Gitleaks test case to its expected rule,
expected behavior, and security purpose.
This document provides Phase 6.6 evidence for the Secrets Security Hardening
work.
Scope
The regression matrix covers:
- Clean-content validation
- Phase 3 synthetic-secret validation
- Application-secret validation
- Database-password validation
- Cloud-access-token validation
- API-token validation
- False-positive control
- Allowlist boundaries
- Temporary artifact cleanup
- Local regression validation
- CI secret-scanning validation
No real credential is used by this regression suite.
All secret-like values are controlled synthetic test values assembled at
runtime.
Scanner Baseline
Pinned scanner:
zricethezav/gitleaks:v8.24.3
Configuration:
.gitleaks.toml
Regression script:
security-tests/gitleaks/test-secret-regression.ps1
GitHub Actions workflow:
.github/workflows/gitleaks.yml
The regression suite executes before the full repository Gitleaks scan.
Regression Matrix
Test	Secret Class	Expected Rule ID	Fixture	Expected Result	Security Purpose
1	Clean content	N/A	clean.txt	PASS / no leak	False-positive control
2	Synthetic secret	phase3-synthetic-secret	phase3-synthetic-secret.txt	DETECT	Preserve Phase 3 coverage
3	Application secret	project-generic-app-secret	application-secret.txt	DETECT	Application credential coverage
4	Database password	project-database-password	database-password.txt	DETECT	Database credential coverage
5	Cloud access token	project-cloud-access-token	cloud-token.txt	DETECT	Cloud credential coverage
6	API token	project-api-token	api-token.txt	DETECT	API credential coverage


Test 1 — Clean Content
The clean fixture contains ordinary non-secret text.
Expected behavior:
no leaks found
Expected Gitleaks exit code:
0
This test verifies that safe content is not incorrectly rejected.
Test 2 — Phase 3 Synthetic Secret
Rule ID:
phase3-synthetic-secret
Pattern:
PHASE3_GITLEAKS_TEST_SECRET_[A-Z0-9]{16}
Expected behavior:
Gitleaks must detect the controlled synthetic value.
Security purpose:
This preserves the original Phase 3 secret-gate regression coverage and
prevents later configuration changes from silently removing that protection.
Test 3 — Application Secret
Rule ID:
project-generic-app-secret
Pattern:
PROJECT_APP_SECRET_[A-Z0-9]{24}
Expected behavior:
Gitleaks must detect the application-secret fixture.
Security purpose:
This validates the project-specific application credential rule.
Test 4 — Database Password
Rule ID:
project-database-password
Pattern:
PROJECT_DB_PASSWORD_[A-Za-z0-9]{20}
Expected behavior:
Gitleaks must detect the database-password fixture.
Security purpose:
This validates dedicated regression coverage for database credentials.
Test 5 — Cloud Access Token
Rule ID:
project-cloud-access-token
Pattern:
PROJECT_CLOUD_TOKEN_[A-Z0-9]{28}
Expected behavior:
Gitleaks must detect the cloud-token fixture.
Security purpose:
This validates dedicated regression coverage for cloud-style access tokens.
Test 6 — API Token
Rule ID:
project-api-token
Pattern:
PROJECT_API_TOKEN_[A-Za-z0-9]{32}
Expected behavior:
Gitleaks must detect the API-token fixture.
Security purpose:
This validates dedicated regression coverage for API credentials.
Rule Coverage Matrix
Rule ID	Category	Custom Rule	Regression Tested	Expected Behavior
phase3-synthetic-secret	Synthetic test secret	Yes	Yes	Detect
project-generic-app-secret	Application credential	Yes	Yes	Detect
project-database-password	Database credential	Yes	Yes	Detect
project-cloud-access-token	Cloud credential	Yes	Yes	Detect
project-api-token	API credential	Yes	Yes	Detect
Gitleaks default rules	General secret patterns	No	Repository scan	Detect according to upstream rules


The project extends Gitleaks default protections instead of replacing them.
Allowlist Matrix
The repository contains narrowly scoped allowlist entries for verified
artifacts.
Path	Reason	Expected Behavior
screenshots/phase2-multiservice-security/trivy-reports/api-trivy.json	Verified generated security-report artifact	Ignore only this path
security-tests/gitleaks/synthetic-secret.txt	Controlled historical synthetic test artifact	Ignore only this path
k8s/base/postgres/sealedsecret.yaml	Encrypted SealedSecret material	Ignore only this path


Allowlist entries must remain narrowly scoped.
A broad rule must not be disabled merely to suppress one false positive.
Local Regression Execution
Run the regression suite from the repository root:
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\security-tests\gitleaks\test-secret-regression.ps1"
Expected final output:
PASS: All Phase 6.1 Gitleaks regression tests passed.
Expected final process exit code:
0
Individual controlled-secret tests intentionally produce Gitleaks detections.
The regression script treats those detections as successful negative tests
only when the expected RuleID is present.
Detection-Test Requirements
A controlled detection test passes only when:
1. Gitleaks returns a detection result.
2. A JSON report is generated.
3. The expected RuleID is present.
4. The temporary fixture is removed.
5. The temporary report is removed.
Temporary Artifact Handling
Temporary test directory:
.tmp-gitleaks-regression
Temporary report pattern:
.tmp-gitleaks-*-report.json
The regression script removes these artifacts automatically.
No controlled synthetic secret should remain in the working tree after the
suite completes.
CI Validation
GitHub Actions runs the regression suite through:
.github/workflows/gitleaks.yml
Job name:
Detect Hardcoded Secrets
The workflow performs:
1. Full Git-history checkout.
2. Gitleaks regression tests.
3. Full repository Gitleaks scan.
The checkout uses:
fetch-depth: 0
persist-credentials: false
The repository scan uses the pinned scanner:
zricethezav/gitleaks:v8.24.3
The scan also uses the project configuration with redacted output and
non-zero failure behavior when a leak is found.
Pass Criteria
Phase 6.6 local regression validation passes when:
- Clean content is accepted.
- Phase 3 synthetic secret is detected.
- Application secret is detected.
- Database password is detected.
- Cloud access token is detected.
- API token is detected.
- Expected RuleIDs are verified.
- Temporary artifacts are removed.
- Final regression exit code is 0.
Fail Criteria
The matrix fails when:
- Clean content is rejected.
- A controlled secret is accepted.
- An expected report is not generated.
- The expected RuleID is missing.
- A regression test throws an exception.
- Temporary test execution cannot complete successfully.
Security Assertions
Assertion	Status
Safe content passes	Tested
Phase 3 synthetic-secret detection works	Tested
Application-secret detection works	Tested
Database-password detection works	Tested
Cloud-token detection works	Tested
API-token detection works	Tested
RuleIDs are verified programmatically	Tested
Test values are temporary	Tested
Detection output is redacted	Tested
Temporary artifacts are cleaned up	Tested
Regression suite executes in CI	Tested
Full repository scanning remains enabled	Tested


Known Boundaries
This matrix does not claim that every possible credential or secret format
can be detected.
Coverage consists of:
- Gitleaks upstream default rules
- Project-specific custom rules
- The deterministic regression classes documented here
A passing matrix confirms that documented security controls remain
functional.
It does not guarantee that an unknown secret format can never enter the
repository.
Change Control
Review this matrix whenever any of these change:
- .gitleaks.toml
- Gitleaks version
- Custom RuleIDs
- Custom regular expressions
- Allowlist paths
- Regression-script logic
- Regression fixtures
- CI secret-scanning workflow
New secret classes should receive deterministic regression coverage before
being considered fully validated.
Evidence Requirements
Phase 6.6 evidence should include:
- Baseline branch state
- Secret regression matrix
- Successful six-test local regression execution
- Exit code 0
- Temporary artifact cleanup
- Commit validation
- Push validation
- Pull request
- Successful Gitleaks CI validation
- All required PR checks
- Merge confirmation
- Final post-merge regression validation
Phase 6.6 Closure Criteria
Phase 6.6 is complete when:
- The regression matrix is documented.
- Every current custom secret class is mapped to a RuleID.
- Positive and negative test behavior is documented.
- Allowlist boundaries are documented.
- The complete local regression suite passes.
- Temporary artifacts are removed.
- Gitleaks CI passes.
- Required PR checks pass.
- The documentation is merged into main.
- Post-merge validation passes.
Related Documentation
- docs/SECRET-REMEDIATION-WORKFLOW.md
- docs/SECRET-REMEDIATION-RECORD.md
- .gitleaks.toml
- .github/workflows/gitleaks.yml
- security-tests/gitleaks/test-secret-regression.ps1