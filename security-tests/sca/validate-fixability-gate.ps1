param(
    [Parameter(Mandatory = $true)]
    [string]$ReportPath
)

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "Phase 7.4 - Dependency Fixability Gate"
Write-Host "======================================="
Write-Host ""

# ------------------------------------------------------------
# Validate report existence
# ------------------------------------------------------------

if (-not (Test-Path $ReportPath)) {
    Write-Host "FIXABILITY GATE: FAIL"
    Write-Host "Reason: Trivy report not found: $ReportPath"
    exit 2
}

# ------------------------------------------------------------
# Parse JSON safely
# ------------------------------------------------------------

try {
    $reportContent = Get-Content $ReportPath -Raw

    if ([string]::IsNullOrWhiteSpace($reportContent)) {
        Write-Host "FIXABILITY GATE: FAIL"
        Write-Host "Reason: Trivy report is empty."
        exit 2
    }

    $report = $reportContent | ConvertFrom-Json
}
catch {
    Write-Host "FIXABILITY GATE: FAIL"
    Write-Host "Reason: Trivy report contains invalid JSON."
    Write-Host "Details:" $_.Exception.Message
    exit 2
}

# ------------------------------------------------------------
# Validate Trivy report structure
# ------------------------------------------------------------

if ($null -eq $report) {
    Write-Host "FIXABILITY GATE: FAIL"
    Write-Host "Reason: Trivy report could not be parsed."
    exit 2
}

$resultsProperty = $report.PSObject.Properties["Results"]

if ($null -eq $resultsProperty) {
    Write-Host "FIXABILITY GATE: FAIL"
    Write-Host "Reason: Invalid Trivy report structure. Required 'Results' field is missing."
    exit 2
}

if ($null -eq $report.Results) {
    Write-Host "FIXABILITY GATE: FAIL"
    Write-Host "Reason: Invalid Trivy report structure. 'Results' field is null."
    exit 2
}

# ------------------------------------------------------------
# Collect vulnerabilities
# ------------------------------------------------------------

$allVulnerabilities = @()

foreach ($result in @($report.Results)) {

    if ($null -eq $result) {
        continue
    }

    if ($result.Vulnerabilities) {
        foreach ($vulnerability in @($result.Vulnerabilities)) {

            if ($null -ne $vulnerability) {
                $allVulnerabilities += $vulnerability
            }
        }
    }
}

# ------------------------------------------------------------
# Identify HIGH / CRITICAL findings
# ------------------------------------------------------------

$highCritical = @(
    $allVulnerabilities | Where-Object {
        $_.Severity -in @("HIGH", "CRITICAL")
    }
)

# ------------------------------------------------------------
# Identify fixable HIGH / CRITICAL findings
# ------------------------------------------------------------

$fixableHighCritical = @(
    $highCritical | Where-Object {
        -not [string]::IsNullOrWhiteSpace($_.FixedVersion)
    }
)

# ------------------------------------------------------------
# Display results
# ------------------------------------------------------------

Write-Host "Total vulnerabilities:" $allVulnerabilities.Count
Write-Host "HIGH/CRITICAL vulnerabilities:" $highCritical.Count
Write-Host "Fixable HIGH/CRITICAL vulnerabilities:" $fixableHighCritical.Count
Write-Host ""

# ------------------------------------------------------------
# Enforce fixability gate
# ------------------------------------------------------------

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

# ------------------------------------------------------------
# Successful gate result
# ------------------------------------------------------------

Write-Host "FIXABILITY GATE: PASS"
Write-Host "No fixable HIGH/CRITICAL vulnerabilities were detected."

exit 0