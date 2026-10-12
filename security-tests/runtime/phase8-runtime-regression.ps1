$ErrorActionPreference = "Stop"

$results = @()
$failed = $false

function Add-Pass {
    param([string]$Message)
    $script:results += "PASS - $Message"
}

function Add-Fail {
    param([string]$Message)
    $script:results += "FAIL - $Message"
    $script:failed = $true
}

$results += "Phase 8.8 - Runtime Security Regression Gate"
$results += "============================================"
$results += ""

# ------------------------------------------------------------
# Container availability
# ------------------------------------------------------------

$runningServices = docker compose ps --services --filter "status=running"

if ($runningServices -contains "api") {
    Add-Pass "API container is running"
} else {
    Add-Fail "API container is not running"
}

if ($runningServices -contains "worker") {
    Add-Pass "Worker container is running"
} else {
    Add-Fail "Worker container is not running"
}

if ($runningServices -contains "postgres") {
    Add-Pass "PostgreSQL container is running"
} else {
    Add-Fail "PostgreSQL container is not running"
}

# ------------------------------------------------------------
# API health
# ------------------------------------------------------------

try {
    $health = Invoke-RestMethod http://127.0.0.1:8081/health

    if ($health.status -eq "healthy" -and $health.service -eq "api") {
        Add-Pass "API health endpoint reports healthy"
    } else {
        Add-Fail "API health endpoint returned unexpected data"
    }
}
catch {
    Add-Fail "API health endpoint is unreachable"
}

# ------------------------------------------------------------
# Non-root execution
# ------------------------------------------------------------

$apiUid = docker compose exec -T api sh -c 'id -u'
$workerUid = docker compose exec -T worker sh -c 'id -u'

if ($apiUid.Trim() -ne "0") {
    Add-Pass "API runs as non-root"
} else {
    Add-Fail "API runs as root"
}

if ($workerUid.Trim() -ne "0") {
    Add-Pass "Worker runs as non-root"
} else {
    Add-Fail "Worker runs as root"
}

$postgresTop = docker top devsecops-postgres -eo uid,pid,comm

if ($postgresTop -match "(?m)^\s*70\s+") {
    Add-Pass "PostgreSQL server process runs as non-root UID 70"
} else {
    Add-Fail "PostgreSQL server process non-root identity was not confirmed"
}

# ------------------------------------------------------------
# Read-only filesystem
# ------------------------------------------------------------

$apiReadOnly = docker inspect devsecops-api --format '{{.HostConfig.ReadonlyRootfs}}'
$workerReadOnly = docker inspect devsecops-worker --format '{{.HostConfig.ReadonlyRootfs}}'

if ($apiReadOnly.Trim() -eq "true") {
    Add-Pass "API root filesystem is read-only"
} else {
    Add-Fail "API root filesystem is not read-only"
}

if ($workerReadOnly.Trim() -eq "true") {
    Add-Pass "Worker root filesystem is read-only"
} else {
    Add-Fail "Worker root filesystem is not read-only"
}

docker compose exec -T api sh -c 'touch /app/phase8-regression-test >/dev/null 2>&1'

if ($LASTEXITCODE -ne 0) {
    Add-Pass "API protected filesystem write is blocked"
} else {
    Add-Fail "API protected filesystem write unexpectedly succeeded"
}

docker compose exec -T worker sh -c 'touch /app/phase8-regression-test >/dev/null 2>&1'

if ($LASTEXITCODE -ne 0) {
    Add-Pass "Worker protected filesystem write is blocked"
} else {
    Add-Fail "Worker protected filesystem write unexpectedly succeeded"
}

docker compose exec -T api sh -c 'touch /tmp/phase8-regression-test && rm /tmp/phase8-regression-test'

if ($LASTEXITCODE -eq 0) {
    Add-Pass "API temporary filesystem remains writable"
} else {
    Add-Fail "API temporary filesystem is not writable"
}

docker compose exec -T worker sh -c 'touch /tmp/phase8-regression-test && rm /tmp/phase8-regression-test'

if ($LASTEXITCODE -eq 0) {
    Add-Pass "Worker temporary filesystem remains writable"
} else {
    Add-Fail "Worker temporary filesystem is not writable"
}

# ------------------------------------------------------------
# Linux capabilities and privilege controls
# ------------------------------------------------------------

$apiCapDrop = docker inspect devsecops-api --format '{{json .HostConfig.CapDrop}}'
$workerCapDrop = docker inspect devsecops-worker --format '{{json .HostConfig.CapDrop}}'

$apiPrivileged = docker inspect devsecops-api --format '{{.HostConfig.Privileged}}'
$workerPrivileged = docker inspect devsecops-worker --format '{{.HostConfig.Privileged}}'

if ($apiCapDrop -match '"ALL"') {
    Add-Pass "API drops all Linux capabilities"
} else {
    Add-Fail "API does not drop all Linux capabilities"
}

if ($workerCapDrop -match '"ALL"') {
    Add-Pass "Worker drops all Linux capabilities"
} else {
    Add-Fail "Worker does not drop all Linux capabilities"
}

if ($apiPrivileged.Trim() -eq "false") {
    Add-Pass "API privileged mode is disabled"
} else {
    Add-Fail "API privileged mode is enabled"
}

if ($workerPrivileged.Trim() -eq "false") {
    Add-Pass "Worker privileged mode is disabled"
} else {
    Add-Fail "Worker privileged mode is enabled"
}

$apiSecurityOpt = docker inspect devsecops-api --format '{{json .HostConfig.SecurityOpt}}'
$workerSecurityOpt = docker inspect devsecops-worker --format '{{json .HostConfig.SecurityOpt}}'

if ($apiSecurityOpt -match "no-new-privileges") {
    Add-Pass "API no-new-privileges is enabled"
} else {
    Add-Fail "API no-new-privileges is not enabled"
}

if ($workerSecurityOpt -match "no-new-privileges") {
    Add-Pass "Worker no-new-privileges is enabled"
} else {
    Add-Fail "Worker no-new-privileges is not enabled"
}

# ------------------------------------------------------------
# Network exposure
# ------------------------------------------------------------

$apiPorts = docker port devsecops-api
$postgresPorts = docker port devsecops-postgres
$workerPorts = docker port devsecops-worker

if ($apiPorts -match "127\.0\.0\.1:8081") {
    Add-Pass "API host exposure is restricted to localhost"
} else {
    Add-Fail "API host exposure is broader than expected"
}

if (-not $postgresPorts) {
    Add-Pass "PostgreSQL is not published to the host"
} else {
    Add-Fail "PostgreSQL is published to the host"
}

if (-not $workerPorts) {
    Add-Pass "Worker is not published to the host"
} else {
    Add-Fail "Worker is published to the host"
}

# ------------------------------------------------------------
# Required database connectivity
# ------------------------------------------------------------

docker compose exec -T api sh -c 'nc -z postgres 5432'

if ($LASTEXITCODE -eq 0) {
    Add-Pass "API can reach PostgreSQL"
} else {
    Add-Fail "API cannot reach PostgreSQL"
}

docker compose exec -T worker sh -c 'nc -z postgres 5432'

if ($LASTEXITCODE -eq 0) {
    Add-Pass "Worker can reach PostgreSQL"
} else {
    Add-Fail "Worker cannot reach PostgreSQL"
}

# ------------------------------------------------------------
# Service-to-service segmentation
# ------------------------------------------------------------

docker compose exec -T api sh -c 'getent hosts worker >/dev/null 2>&1'

if ($LASTEXITCODE -ne 0) {
    Add-Pass "API cannot resolve Worker"
} else {
    Add-Fail "API can resolve Worker"
}

docker compose exec -T worker sh -c 'getent hosts api >/dev/null 2>&1'

if ($LASTEXITCODE -ne 0) {
    Add-Pass "Worker cannot resolve API"
} else {
    Add-Fail "Worker can resolve API"
}

# ------------------------------------------------------------
# Final result
# ------------------------------------------------------------

$results += ""

if ($failed) {
    $results += "FINAL RESULT: FAIL"
    $exitCode = 1
}
else {
    $results += "FINAL RESULT: PASS"
    $exitCode = 0
}

$results | ForEach-Object {
    Write-Host $_
}

exit $exitCode