\# Phase 4 — Detection Remediation and Regression



\## Objective



Phase 4 validates that previously tested DevSecOps security controls continue to detect known failure conditions after remediation.



The goal is to demonstrate:



\- controlled security failure

\- automated detection

\- remediation validation

\- regression protection

\- evidence preservation



\---



\## Regression Coverage



| Control | Regression Method | Expected Result | Status |

|---|---|---|---|

| Trivy | Safe and vulnerable JSON fixtures | Fixable HIGH/CRITICAL vulnerability is blocked | Passed |

| Gitleaks | Runtime-generated synthetic secret | Synthetic secret is detected while clean fixture passes | Passed |

| CodeQL | Controlled command-injection fixture | `java/command-line-injection` is detected | Passed |

| OWASP ZAP | Temporarily remove `X-Content-Type-Options: nosniff` | Missing security header is detected | Passed |

| Policy-as-Code | Controlled Dockerfile fixtures | Insecure Dockerfile configurations are blocked | Passed |



\---



\## 4.1 — Trivy Regression



The Trivy vulnerability gate was converted into a repeatable regression test.



Validation includes:



\- safe fixture accepted

\- non-fixable HIGH vulnerability accepted by the current gate logic

\- fixable HIGH vulnerability blocked

\- CI execution of the same regression harness



Relevant files:



\- `security-tests/trivy/validate-gate.sh`

\- `security-tests/trivy/test-gate-regression.sh`

\- `security-tests/trivy/fixtures/pass.json`

\- `security-tests/trivy/fixtures/fail.json`

\- `.github/workflows/trivy.yml`



\---



\## 4.2 — Gitleaks Regression



The Gitleaks regression test validates both clean and controlled-secret conditions.



The synthetic secret is constructed only at runtime so a complete secret value is not committed to repository history.



Relevant files:



\- `security-tests/gitleaks/test-secret-regression.ps1`

\- `.gitleaks.toml`

\- `.github/workflows/gitleaks.yml`



\---



\## 4.3 — CodeQL Regression



The CodeQL regression harness validates Java command-injection detection.



The committed Java fixture is safe. During the regression run, it is temporarily modified into a controlled vulnerable state using:



\- `System.getenv("SCRIPTNAME")`

\- `Runtime.getRuntime().exec(...)`



The regression asserts detection of:



\- `java/command-line-injection`



The safe fixture is restored after testing.



Relevant files:



\- `security-tests/codeql/CodeQLCommandInjectionFixture.java`

\- `.github/workflows/codeql-regression.yml`

\- `.github/codeql/codeql-config.yml`



The dedicated CodeQL regression workflow is manually triggered so that the intentionally vulnerable regression harness does not interfere with unrelated pull requests.



\---



\## 4.4 — OWASP ZAP Regression



The ZAP regression test validates detection of a missing HTTP security header.



During CI, the secure application is temporarily modified by removing:



`X-Content-Type-Options: nosniff`



The isolated application stack is rebuilt and scanned using the project's OpenAPI definition.



The regression asserts that ZAP detects the controlled missing security-header condition.



Relevant files:



\- `.github/workflows/zap-regression.yml`

\- `.github/workflows/zap.yml`

\- `security/openapi.yaml`

\- `src/main/java/com/nokishohid/devsecops/api/ApiMain.java`



\---



\## 4.5 — Policy-as-Code Regression



The Dockerfile security policies were updated to use the current Conftest Dockerfile parser structure.



Regression fixtures validate that:



\- a secure Dockerfile passes

\- `USER root` is blocked

\- `:latest` base images are blocked

\- a missing non-root `USER` is blocked

\- remote `ADD` URLs are blocked



Relevant files:



\- `policy/docker.rego`

\- `.github/workflows/policy.yml`

\- `security-tests/policy/test-docker-policy-regression.sh`

\- `security-tests/policy/fixtures/`



\---



\## Phase 4 Result



Phase 4 demonstrates that the DevSecOps pipeline does more than detect security issues once.



The repository now contains repeatable regression validation showing that previously tested security controls continue to detect known insecure conditions after remediation.



Regression protection now covers:



\- vulnerability management

\- secret detection

\- static application security testing

\- dynamic application security testing

\- Policy-as-Code



Phase 4 is considered complete after the closure evidence is merged into the main branch.



