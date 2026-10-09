$ErrorActionPreference = "Stop"

$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
$TempRelative = ".tmp-gitleaks-regression"
$TempDirectory = Join-Path $RepoRoot $TempRelative

$Image = "zricethezav/gitleaks:v8.24.3"

function Invoke-GitleaksDetectionTest {
    param (
        [Parameter(Mandatory = $true)]
        [string]$TestName,

        [Parameter(Mandatory = $true)]
        [string]$FileName,

        [Parameter(Mandatory = $true)]
        [string]$Content,

        [Parameter(Mandatory = $true)]
        [string]$ExpectedRuleId,

        [Parameter(Mandatory = $true)]
        [string]$ReportName
    )

    $FixturePath = Join-Path $TempDirectory $FileName
    $ReportPath = Join-Path $RepoRoot $ReportName

    Set-Content `
        -Path $FixturePath `
        -Value $Content

    Write-Host $TestName

    docker run --rm `
        -v "${RepoRoot}:/repo" `
        -w /repo `
        $Image detect `
        --source "/repo/$TempRelative" `
        --config "/repo/.gitleaks.toml" `
        --no-git `
        --redact `
        --report-format json `
        --report-path "/repo/$ReportName" `
        --exit-code 1

    if ($LASTEXITCODE -eq 0) {
        throw "$ExpectedRuleId test value was incorrectly accepted by Gitleaks."
    }

    if (-not (Test-Path $ReportPath)) {
        throw "Gitleaks did not generate the expected report for $ExpectedRuleId."
    }

    $Findings = Get-Content $ReportPath -Raw | ConvertFrom-Json

    $ExpectedFinding = $Findings |
        Where-Object { $_.RuleID -eq $ExpectedRuleId }

    if (-not $ExpectedFinding) {
        throw "Expected rule '$ExpectedRuleId' was not detected."
    }

    Write-Host "PASS: $ExpectedRuleId was correctly detected."
    Write-Host ""

    Remove-Item $FixturePath -Force -ErrorAction SilentlyContinue
    Remove-Item $ReportPath -Force -ErrorAction SilentlyContinue
}

try {
    New-Item -ItemType Directory -Force $TempDirectory | Out-Null

    Write-Host "=== Phase 6.1 Gitleaks Hardening Regression Tests ==="
    Write-Host ""

    # ---------------------------------------------------------------
    # TEST 1
    # Verify that ordinary non-secret content is accepted.
    # ---------------------------------------------------------------

    Write-Host "[TEST 1] Clean fixture must PASS"

    $CleanFile = Join-Path $TempDirectory "clean.txt"
    $CleanReportName = ".tmp-gitleaks-clean-report.json"
    $CleanReport = Join-Path $RepoRoot $CleanReportName

    Set-Content `
        -Path $CleanFile `
        -Value "This is a clean regression test file with no credentials."

    docker run --rm `
        -v "${RepoRoot}:/repo" `
        -w /repo `
        $Image detect `
        --source "/repo/$TempRelative" `
        --config "/repo/.gitleaks.toml" `
        --no-git `
        --redact `
        --report-format json `
        --report-path "/repo/$CleanReportName" `
        --exit-code 1

    if ($LASTEXITCODE -ne 0) {
        throw "Clean fixture was incorrectly rejected by Gitleaks."
    }

    Write-Host "PASS: Clean fixture was accepted."
    Write-Host ""

    Remove-Item $CleanFile -Force -ErrorAction SilentlyContinue
    Remove-Item $CleanReport -Force -ErrorAction SilentlyContinue

    # ---------------------------------------------------------------
    # TEST 2
    # Preserve the original Phase 3 synthetic-secret validation.
    # The complete test value is assembled only at runtime.
    # ---------------------------------------------------------------

    $Phase3Prefix = "PHASE3_GITLEAKS_TEST_SECRET_"
    $Phase3Suffix = @(
        "ABCD",
        "EF12",
        "3456",
        "7890"
    ) -join ""

    Invoke-GitleaksDetectionTest `
        -TestName "[TEST 2] Phase 3 synthetic secret must be DETECTED" `
        -FileName "phase3-synthetic-secret.txt" `
        -Content ($Phase3Prefix + $Phase3Suffix) `
        -ExpectedRuleId "phase3-synthetic-secret" `
        -ReportName ".tmp-gitleaks-phase3-report.json"

    # ---------------------------------------------------------------
    # TEST 3
    # Generic application-secret regression coverage.
    # ---------------------------------------------------------------

    $AppPrefix = "PROJECT_APP_SECRET_"
    $AppSuffix = @(
        "ABCD12",
        "EFGH34",
        "IJKL56",
        "MNOP78"
    ) -join ""

    Invoke-GitleaksDetectionTest `
        -TestName "[TEST 3] Application secret must be DETECTED" `
        -FileName "application-secret.txt" `
        -Content ($AppPrefix + $AppSuffix) `
        -ExpectedRuleId "project-generic-app-secret" `
        -ReportName ".tmp-gitleaks-app-report.json"

    # ---------------------------------------------------------------
    # TEST 4
    # Database-password regression coverage.
    # ---------------------------------------------------------------

    $DatabasePrefix = "PROJECT_DB_PASSWORD_"
    $DatabaseSuffix = @(
        "Ab12E",
        "f34Gh",
        "56IjK",
        "l78Mn"
    ) -join ""

    Invoke-GitleaksDetectionTest `
        -TestName "[TEST 4] Database password must be DETECTED" `
        -FileName "database-password.txt" `
        -Content ($DatabasePrefix + $DatabaseSuffix) `
        -ExpectedRuleId "project-database-password" `
        -ReportName ".tmp-gitleaks-database-report.json"

    # ---------------------------------------------------------------
    # TEST 5
    # Cloud-style token regression coverage.
    # ---------------------------------------------------------------

    $CloudPrefix = "PROJECT_CLOUD_TOKEN_"
    $CloudSuffix = @(
        "ABCD123",
        "EFGH456",
        "IJKL789",
        "MNOP012"
    ) -join ""

    Invoke-GitleaksDetectionTest `
        -TestName "[TEST 5] Cloud access token must be DETECTED" `
        -FileName "cloud-token.txt" `
        -Content ($CloudPrefix + $CloudSuffix) `
        -ExpectedRuleId "project-cloud-access-token" `
        -ReportName ".tmp-gitleaks-cloud-report.json"

    # ---------------------------------------------------------------
    # TEST 6
    # API-token regression coverage.
    # ---------------------------------------------------------------

    $ApiPrefix = "PROJECT_API_TOKEN_"
    $ApiSuffix = @(
        "AbCd1234",
        "EfGh5678",
        "IjKl9012",
        "MnOp3456"
    ) -join ""

    Invoke-GitleaksDetectionTest `
        -TestName "[TEST 6] API token must be DETECTED" `
        -FileName "api-token.txt" `
        -Content ($ApiPrefix + $ApiSuffix) `
        -ExpectedRuleId "project-api-token" `
        -ReportName ".tmp-gitleaks-api-report.json"

    Write-Host "=============================================="
    Write-Host "PASS: All Phase 6.1 Gitleaks regression tests passed."
    Write-Host "=============================================="
}
finally {
    Remove-Item $TempDirectory -Recurse -Force -ErrorAction SilentlyContinue

    Get-ChildItem `
        -Path $RepoRoot `
        -Filter ".tmp-gitleaks-*-report.json" `
        -File `
        -ErrorAction SilentlyContinue |
        Remove-Item -Force -ErrorAction SilentlyContinue
}

exit 0
