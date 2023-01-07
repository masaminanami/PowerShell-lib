#
# test config
#
#
#
#
param(
[string]$LogFile = "log.txt",
[int]$LogGenerations = 3,
[string]$LibPath = "..\",
[switch]$Hep
)

<#
 # Logfile locator
 #>
function getLogFilePath() {
    $fp = $script:LogFile
    if ($fp) {
        if (-not ([System.IO.Path]::IsPathRooted($fp))) {
            $fp = Join-Path $MyInvocation.PSScriptRoot $fp
        }
    }
    $fp
}

<#
 # Library Loader
 #>
function getLibPath($lib) {
    $paths = @('.\')
    if ($script:LibPath) { $paths += $script:LibPath }
    @($myInvocation.ScriptName,
     $myInvocation.PSCommandPath,
     $myInvocation.InvocationName) |? {$_} |% {
        $d = (Test-Path -PathType Leaf $_) ? (Split-Path -Parent $_) : $_;
        $paths += $d;
        if ($script:LibPath) { $paths += Join-Path $d $script:LibPath }
     }

    foreach ($e in $paths) {
        write-host "Searching in $e"
        $fp = Join-Path $e $lib; if (test-Path $fp) { return $fp }
    }
    throw "Library not found: $lib"
}

Import-Module (getLibPath "stdps.psm1")

$ErrorActionPreference = "stop"
Set-StrictMode -Version latest

RunApp ([Main]::New()) (getLogfilePath) $script:LogGenerations
return;

class Main {
    Run() {
        $prog = ".\test-configsub.ps1"
        
        
        #---no param
        $testcnt = 1
        $testmsg = "No parameter with .config.json"
        $expected = "P1 = P2 = helloConfig = .config.json"
        $res = & pwsh $prog
        $this.showResult($testcnt, $testmsg, $res, $expected)

        # change P1
        $testcnt++
        $testmsg = "P1 parameter with .config.json"
        $expected = "P1 = p1newvalueP2 = helloConfig = .config.json"
        $res = & pwsh $prog -P1 p1newvalue
        $this.showResult($testcnt, $testmsg, $res, $expected)

        # change P2
        $testcnt++
        $testmsg = "P2 parameter with .config.json"
        $expected = "P1 = P2 = worldConfig = .config.json"
        $res = & pwsh $prog -P2 world
        $this.showResult($testcnt, $testmsg, $res, $expected)

        # No Config
        $testcnt++
        $testmsg = "P2 parameter without .config.json"
        $expected = "Config: Warining! Setting file not found. Skip loading: $(Get-Location)\notexistP1 = P2 = def-valueConfig = notexist"
        $res = & pwsh $prog -Config notexist
        $this.showResult($testcnt, $testmsg, $res, $expected)
    }
    
    showResult($cnt, $msg, $res, $expected) {
        $res = $res -join('')
        if ($res -eq $expected) {
            log "Test $cnt PASS $msg"
        } else {
            log "Test $cnt FAIL $msg Result=$res"
            $s = $expected; $m = (0..($s.Length-1) |%{ "$($s[$_])($([Convert]::ToByte($s[$_])))"}) -join('')
            log "expected: $m"
            $s = $res; $m = (0..($s.Length-1) |%{ "$($s[$_])($([Convert]::ToByte($s[$_])))"}) -join('')
            log "response: $m"
        }
    }
}

