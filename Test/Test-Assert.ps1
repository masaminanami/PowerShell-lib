using module ..\Assert.psm1

function log($v) {Write-Host ($v -join('')) }

try {
    [Assert]::Test($true)
    log "Asset test-true: Pass"
} catch {
    og "Asset test-true: FAILED!!"
}

try {
    [Assert]::Test($false)
    log "Asset Test-False: FAILED"
} catch {
    $m = $_
    log "Asset Test-False: Pass $m"
}