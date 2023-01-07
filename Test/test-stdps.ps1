#
#
#
param(
[string]$LogFile = "log.txt",
[int]$LogGenerations = 3,
[string]$LibPath = "..\",
[switch]$Hep
)

$ErrorActionPreference = "stop"
Set-StrictMode -Version latest

$ScriptRoot = $MyInvocation.PSScriptRoot ? $MyInvocation.PSScriptRoot : (Split-Path -Parent $MyInvocation.InvocationName)

Import-Module (Join-Path $script:ScriptRoot $script:LibPath "stdps.psm1")

<#
 # Logfile locator
 #>
function getLogFilePath() {
    if ($fp = $script:LogFile) {
        if (-not ([System.IO.Path]::IsPathRooted($fp))) {
            $fp = Join-Path $script:ScriptRoot $fp
        }
    }
    $fp
}



RunApp ([Main]::New()) (getLogfilePath) $script:LogGenerations
return;

class Main {
    Run() {
        log "Logging test"
        logv "logging verbose test"
        logcl "cyan" "logging in cyan"
        logerror "logging in red but continue"
        log "Run test-stdps.ps1 in another command prompt window to see lock is working"
        $res = ""
        do {
            $res = Read-Host -Prompt "Type Y to continue"
        } until ($res -eq "Y")
        log "test end! check if logfile (log.txt) is generated in the folder"
    }
}

