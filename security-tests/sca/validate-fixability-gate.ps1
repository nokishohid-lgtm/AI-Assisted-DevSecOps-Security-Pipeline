param(
    [Parameter(Mandatory = $true)]
    [string]$ReportPath
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path $ReportPath)) {
    Write-Host "FIXABILITY GATE: FAIL"
    Write-Host "Reason: Trivy report not found: $ReportPath"
    exit 1
}

$report = Get-Content $ReportPath -Raw | ConvertFrom-Json

$allVulnerabilities = @()

foreach ($result in $report.Results) {
    if ($result.Vulnerabilities) {
        foreach ($vulnerability in $result.Vulnerabilities) {
            $allVulnerabilities += $vulnerability
        }
    }
}

$highCritical = @(
    $allVulnerabilities | Where-Object {
        $_.Severity -in @("HIGH", "CRITICAL")
    }
)

$fixableHighCritical = @(
    $highCritical | Where-Object {
        -not [string]::IsNullOrWhiteSpace($_.FixedVersion)
    }
)

Write-Host ""
Write-Host "Phase 7.4 - Dependency Fixability Gate"
Write-Host "======================================="
Write-Host ""
Write-Host "Total vulnerabilities:" $allVulnerabilities.Count
Write-Host "HIGH/CRITICAL vulnerabilities:" $highCritical.Count
Write-Host "Fixable HIGH/CRITICAL vulnerabilities:" $fixableHighCritical.Count
Write-Host ""

if ($fixableHighCritical.Count -gt 0) {
    Write-Host "Fixable HIGH/CRITICAL findings:"
    Write-Host ""

    foreach ($vulnerability in $fixableHighCritical) {
        Write-Host "Vulnerability:" $vulnerability.VulnerabilityID
        Write-Host "Package:" $vulnerability.PkgName
        Write-Host "Installed Version:" $vulnerability.InstalledVersion
        Write-Host "Fixed Version:" $vulnerability.FixedVersion
        Write-Host "Severity:" $vulnerability.Severity
        Write-Host "---------------------------------------"
    }

    Write-Host ""
    Write-Host "FIXABILITY GATE: FAIL"
    Write-Host "Reason: One or more HIGH/CRITICAL vulnerabilities have known fixes."
    exit 1
}

Write-Host "FIXABILITY GATE: PASS"
Write-Host "No fixable HIGH/CRITICAL vulnerabilities were detected."
exit 0