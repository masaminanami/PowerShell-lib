#
#
#
using module ..\Config.psm1

param(
[string]$P1 = "",
[string]$P2 = "def-value",
[string]$Config = ".config.json"
)

function log($v) { Write-Host ($v -join('')) }
function logv($v) { Write-debug ($v -join('')) }

[Main]::New().Run()
return;

class Main {
    Run() {
        [Config]::Init($script:Config)
        log "P1 = $($script:P1)"
        log "P2 = $($script:P2)"
        log "Config = $($script:Config)"
    }
}