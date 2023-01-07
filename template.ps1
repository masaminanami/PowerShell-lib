#
#
#
param(
[string]$LogFile = "log.txt",
[int]$LogGenerations = 3,
[string]$LibPath = ".\",
[switch]$Hep
)

$ErrorActionPreference = "stop"
Set-StrictMode -Version latest

$ScriptRoot = $MyInvocation.PSScriptRoot ? $MyInvocation.PSScriptRoot : $myInvocation.InvocationName -match '\.ps1$' ? (Split-Path -Parent $MyInvocation.InvocationName) : (Get-Location).Path

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
    }
}
