# Phase 5 - Advanced SAST / CodeQL Hardening

## Objective

Phase 5 expands the project's static application security testing coverage beyond a single CodeQL vulnerability class.

The phase validates multiple security weaknesses using controlled runtime-only vulnerable fixtures while keeping the committed repository fixtures safe.

The goal is to demonstrate:

- broader SAST coverage
- repeatable CodeQL detection
- reusable SARIF validation
- remediation verification
- safe regression testing
- evidence-backed security validation

---

## Advanced SAST Coverage

| Section | Vulnerability Class | CodeQL Rule | Vulnerable State | Remediated State | Status |
|---|---|---|---|---|---|
| 5.1 | Command Injection | `java/command-line-injection` | Detected | 0 findings | Passed |
| 5.1 | SQL Injection | `java/sql-injection` | Detected | 0 findings | Passed |
| 5.2 | Path Injection | `java/path-injection` | Detected | 0 findings | Passed |
| 5.3 | Log Injection | `java/log-injection` | Detected | 0 findings | Passed |

---

## 5.1 - SQL Injection Expansion

Phase 5.1 expanded the existing CodeQL regression harness from command injection to include SQL injection.

The committed SQL fixture uses a parameterized query with `PreparedStatement`.

During the manually triggered regression workflow, the safe fixture is temporarily replaced with a controlled vulnerable form that constructs a SQL query using untrusted input.

Expected CodeQL findings:

- `java/command-line-injection`
- `java/sql-injection`

Relevant files:

- `security-tests/codeql/CodeQLCommandInjectionFixture.java`
- `security-tests/codeql/CodeQLSqlInjectionFixture.java`
- `.github/workflows/codeql-regression.yml`

---

## 5.2 - Path Injection Expansion

Phase 5.2 added path-injection validation.

The committed fixture uses a fixed safe path.

During the regression workflow, it is temporarily replaced with a controlled vulnerable implementation that uses an environment-controlled path directly in a file operation.

Expected CodeQL finding:

- `java/path-injection`

Relevant file:

- `security-tests/codeql/CodeQLPathInjectionFixture.java`

---

## 5.3 - Log Injection Expansion

Phase 5.3 added log-injection validation.

The committed fixture sanitizes carriage-return and newline characters before logging.

During the regression workflow, it is temporarily replaced with a controlled vulnerable implementation that logs untrusted input without line-break sanitization.

Expected CodeQL finding:

- `java/log-injection`

Relevant file:

- `security-tests/codeql/CodeQLLogInjectionFixture.java`

---

## 5.4 - Multi-rule SARIF Assertions

Phase 5.4 replaced duplicated per-rule workflow assertions with a reusable SARIF validation mechanism.

The expected rule list is stored in:

- `security-tests/codeql/expected-sarif-rules.txt`

The reusable validator is:

- `security-tests/codeql/assert-sarif-rules.sh`

The validator confirms that every required CodeQL rule appears at least once in the generated SARIF output.

Expected rule set:

- `java/command-line-injection`
- `java/sql-injection`
- `java/path-injection`
- `java/log-injection`

The regression fails if any expected rule is missing.

---

## 5.5 - Remediation Validation

Phase 5.5 added before-and-after SAST validation.

The workflow now contains two independent jobs.

### Controlled Vulnerable Validation

The safe fixtures are temporarily converted into controlled vulnerable forms.

All four protected CodeQL rules must be detected.

### Remediated Safe-State Validation

The committed safe fixtures are analyzed without modification.

The following protected rules must each return zero findings:

- `java/command-line-injection`
- `java/sql-injection`
- `java/path-injection`
- `java/log-injection`

The reusable remediation validator is:

- `security-tests/codeql/assert-remediated-sarif.sh`

Successful remediation validation demonstrates that the pipeline can distinguish vulnerable and remediated states.

---

## CodeQL Configuration

The project uses:

- Java/Kotlin CodeQL analysis
- manual build mode
- `security-extended`
- local threat modeling
- SARIF output
- manually triggered regression validation

Configuration file:

- `.github/codeql/codeql-config.yml`

Primary workflow:

- `.github/workflows/codeql.yml`

Regression workflow:

- `.github/workflows/codeql-regression.yml`

---

## Evidence

Phase 5 evidence is stored in:

`screenshots/phase5-advanced-sast/`

Evidence includes:

- normal pull-request security checks
- controlled vulnerability detection
- multi-rule SARIF validation
- safe-state remediation validation
- merged pull-request evidence

---

## Phase 5 Result

Phase 5 demonstrates advanced static application security testing across multiple vulnerability classes.

The project now validates:

- command injection
- SQL injection
- path injection
- log injection

The CodeQL regression framework verifies both:

1. controlled vulnerable states are detected
2. committed remediated states produce zero protected findings

This provides repeatable evidence that SAST controls remain effective while the repository itself remains in a secure state.
