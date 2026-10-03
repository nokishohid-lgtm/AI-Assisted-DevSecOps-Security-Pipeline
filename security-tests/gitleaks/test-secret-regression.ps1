$ErrorActionPreference = "Stop"

$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
$TempRelative = ".tmp-gitleaks-regression"
$TempDirectory = Join-Path $RepoRoot $TempRelative

$CleanReport = Join-Path $RepoRoot ".tmp-gitleaks-clean-report.json"
$SecretReport = Join-Path $RepoRoot ".tmp-gitleaks-secret-report.json"

$Image = "zricethezav/gitleaks:v8.24.3"

try {
    New-Item -ItemType Directory -Force $TempDirectory | Out-Null

    Write-Host "=== Phase 4 Gitleaks Regression Tests ==="
    Write-Host ""
    Write-Host "[TEST 1] Clean fixture must PASS"

    Set-Content `
        -Path (Join-Path $TempDirectory "clean.txt") `
        -Value "This is a clean regression test file."

    docker run --rm `
        -v "${RepoRoot}:/repo" `
        -w /repo `
        $Image detect `
        --source "/repo/$TempRelative" `
        --config "/repo/.gitleaks.toml" `
        --no-git `
        --redact `
        --report-format json `
        --report-path "/repo/.tmp-gitleaks-clean-report.json" `
        --exit-code 1

    if ($LASTEXITCODE -ne 0) {
        throw "Clean fixture was incorrectly rejected by Gitleaks."
    }

    Write-Host "PASS: Clean fixture was accepted."
    Write-Host ""
    Write-Host "[TEST 2] Synthetic secret must be DETECTED"

    # Construct at runtime so the complete synthetic secret is never
    # committed to repository history.
    $SecretPrefix = "PHASE3_GITLEAKS_TEST_SECRET_"

    $SecretSuffixParts = @(
        "ABCD",
        "EF12",
        "3456",
        "7890"
    )

    $SecretSuffix = $SecretSuffixParts -join ""

    Set-Content `
        -Path (Join-Path $TempDirectory "synthetic-secret.txt") `
        -Value ($SecretPrefix + $SecretSuffix)

    docker run --rm `
        -v "${RepoRoot}:/repo" `
        -w /repo `
        $Image detect `
        --source "/repo/$TempRelative" `
        --config "/repo/.gitleaks.toml" `
        --no-git `
        --redact `
        --report-format json `
        --report-path "/repo/.tmp-gitleaks-secret-report.json" `
        --exit-code 1

    if ($LASTEXITCODE -eq 0) {
        throw "Synthetic secret was incorrectly accepted by Gitleaks."
    }

    if (-not (Test-Path $SecretReport)) {
        throw "Gitleaks did not generate the expected detection report."
    }

    $Findings = Get-Content $SecretReport -Raw | ConvertFrom-Json

    $ExpectedFinding = $Findings |
        Where-Object { $_.RuleID -eq "phase3-synthetic-secret" }

    if (-not $ExpectedFinding) {
        throw "Expected phase3-synthetic-secret rule was not detected."
    }

    Write-Host "PASS: Synthetic secret was correctly detected."
    Write-Host ""
    Write-Host "All Gitleaks regression tests passed."
}
finally {
    Remove-Item $TempDirectory -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item $CleanReport -Force -ErrorAction SilentlyContinue
    Remove-Item $SecretReport -Force -ErrorAction SilentlyContinue
}

exit 0
