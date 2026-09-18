# CodeQL repair and configuration cleanup

## Problem

The CodeQL workflow was configured to listen for its own completion.
PR #38 replaced that trigger with push and pull-request events targeting
main, enabled code-scanning uploads, and retained the SARIF artifact.

The analysis completed successfully, but PR #39's separate CodeQL
results check reported "1 configuration not found."

## Investigation

GitHub listed two configurations:

- `codeql-analysis`, last scanned four days before the investigation.
- `language:java-kotlin`, associated with the recent successful scans.

The missing configuration named in the PR warning matched the older entry.

## Cleanup

The older `codeql-analysis` configuration was removed through GitHub's
code-scanning UI. The remaining `language:java-kotlin` configuration
reported that it was working as expected.

## Validation result

After cleanup, PR #40's CodeQL results check succeeded and reported:
"No new alerts in code changed by this pull request."

The missing-configuration warning did not appear on this new check.
PR #39 retained its earlier warning as a historical result.

This confirms successful PR comparison after cleanup. It does not prove
that the application has no vulnerabilities or that the pipeline blocks
a deliberately vulnerable change. Those require separate controlled tests.

## Evidence

- [PR analysis and SARIF artifact upload](01-codeql-pr-analysis-and-artifact-success.png)
- [PR check results](02-codeql-pr-checks-passed.png)
- [Workflow repair merged](03-codeql-repair-pr-merged.png)
- [Successful scan on main](04-codeql-main-run-success.png)
- [Java files scanned](05-codeql-scanned-files-confirmation.png)
- [Configurations before investigation](06-codeql-two-configurations-before-investigation.png)
- [Active configuration after cleanup](07-codeql-active-configuration-after-cleanup.png)
- [Successful PR comparison after cleanup](08-codeql-pr-comparison-after-cleanup.png)

## Related pull requests

- [PR #38: Workflow repair](https://github.com/nokishohid-lgtm/AI-Assisted-DevSecOps-Security-Pipeline/pull/38)
- [PR #39: Initial evidence](https://github.com/nokishohid-lgtm/AI-Assisted-DevSecOps-Security-Pipeline/pull/39)
- [PR #40: Configuration cleanup documentation](https://github.com/nokishohid-lgtm/AI-Assisted-DevSecOps-Security-Pipeline/pull/40)

## Lesson learned

I learned that a successful analysis job and a complete pull-request
security comparison are separate checks. I investigated the configuration
warning and verified the result on a new PR before marking it resolved.
