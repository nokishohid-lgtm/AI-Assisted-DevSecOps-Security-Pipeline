$ErrorActionPreference = "Stop"

$gateScript = "security-tests\sca\validate-fixability-gate.ps1"

$cleanReport = "evidence\phase7-sca\7.4\trivy-fs-report.json"
$failReport = "security-tests\sca\fixtures\fixable-high-vulnerability.json"
$invalidReport = "security-tests\sca\fixtures\invalid-report.json"

Write-Host ""
Write-Host "Phase 7.8 - SCA Regression Test"
Write-Host "================================"
Write-Host ""

$allPassed = $true

Write-Host "Test 1 - Clean baseline should PASS"
Write-Host "------------------------------------"

powershell -ExecutionPolicy Bypass `
    -File $gateScript `
    -ReportPath $cleanReport

$cleanExitCode = $LASTEXITCODE

if ($cleanExitCode -eq 0) {
    Write-Host "TEST 1 RESULT: PASS"
} else {
    Write-Host "TEST 1 RESULT: FAIL"
    $allPassed = $false
}

Write-Host ""
Write-Host "Test 2 - Fixable HIGH vulnerability should FAIL"
Write-Host "------------------------------------------------"

powershell -ExecutionPolicy Bypass `
    -File $gateScript `
    -ReportPath $failReport

$failExitCode = $LASTEXITCODE

if ($failExitCode -eq 1) {
    Write-Host "TEST 2 RESULT: PASS"
} else {
    Write-Host "TEST 2 RESULT: FAIL"
    $allPassed = $false
}

Write-Host ""
Write-Host "Test 3 - Invalid report should FAIL"
Write-Host "-----------------------------------"

powershell -ExecutionPolicy Bypass `
    -File $gateScript `
    -ReportPath $invalidReport

$invalidExitCode = $LASTEXITCODE

if ($invalidExitCode -ne 0) {
    Write-Host "TEST 3 RESULT: PASS"
} else {
    Write-Host "TEST 3 RESULT: FAIL"
    $allPassed = $false
}

Write-Host ""
Write-Host "Regression Summary"
Write-Host "=================="
Write-Host "Clean baseline exit code:" $cleanExitCode
Write-Host "Fixable vulnerability exit code:" $failExitCode
Write-Host "Invalid report exit code:" $invalidExitCode
Write-Host ""

if ($allPassed) {
    Write-Host "SCA REGRESSION TEST: PASS"
    exit 0
}

Write-Host "SCA REGRESSION TEST: FAIL"
exit 1