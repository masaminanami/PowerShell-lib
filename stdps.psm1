#
# PowerShell Standard library
#   This module contains
#       - Bootup: RunMain
#       - Logging: log, logv
#

#
#--- RunMain
# Initialize the log file and start class-based app by calling Run()
#
function RunApp($app, $logfile, $logGens = 3) {
    checkArgs
    initlog $logfile $logGens
    $app.Run()
    closelog
}

function checkArgs() {
    if ($global:Args.count -gt 0) {
        throw "Unknown argument specified: $($global:Args -join(' '))"
    }
}

#
# Logging
#
$logging_LogFileFP = $null
$logging_Encoding = $null
$logging_LockFile = $null
$logging_Verbose = $false
$LogTimeFormat = 'yyyyMMdd-HHmmss'

#
# initlog --- initialize logging parameters (if logfile is specified)
#
function initlog($file, $gens, $encode="utf8") {
    if ($file) {
        $script:logging_LogFileFP = [IO.Path]::GetFullPath($file)
        $script:logging_Encoding = $encode
        $script:logging_LockFile = $script:logging_LogFileFP + ".lock"
        try {
            locklog
        } catch {
            $oPID = Get-Content $logging_LockFile
            $pi = Get-Process -Id $oPID -ErrorAction ignore
            $pi.Keys |%{ write-host "$_ = $($pi.$_)"}
            throw "ERROR! Lock failed. Other process is running (PID=$PID oPID=$oPID)"
        }
        if (-not $script:LogTimeFormat) {
            $script:LogTimeFormat = 'yyyy/MM/dd HH:mm:ss '
        } elseif ($script:LogTimeFormat -notmatch "\s$") {
            $script:LogTimeFormat += ' '
        }
        if ($gens) { rotatelogs $script:logging_LogFileFP $gens }
        Set-Content -Path $script:logging_LogFileFP -Value $null -Encoding $script:logging_Encoding
        log "Logging started: $(Get-Date -Format $script:LogTimeFormat) $($script:logging_LogFileFP)"
    } else {
        Write-Host "initlog: Logging is disabled as no log filename is specified."
    }
}
    
#
# locklog --- try to detect another process is running that uses the same log file
#
function locklog() {
    Write-Debug "Creating lockfile Lock=$($script:logging_LockFile) PID=$PID"
    if ($script:logging_LockFile) {
        if (Test-Path $script:logging_LockFile) {
            $rPID = Get-Content $script:logging_LockFile
            $pi = Get-Process -Id $rPid -ErrorAction SilentlyContinue
            if ($pi -and -not [string]::IsNullOrEmpty($pi.ProcessName)) {
                throw "Lockfile exists and the process is running (PID=$rPID ProcessName=$($pi.ProcessName))."
            } else {
                Write-Debug "lockfile exist but no process ($rPID)"
            }
        }
        $PID |Out-File $script:Logging_LockFile
    }
}

function closelog() {
    if ($script:logging_LockFile) {
        $oPID = Get-Content $logging_LockFile
        Write-Debug "Removing lockfile: $($script:logging_LockFile) PID=$PID oPID=$oPID"
        if ($PID -eq $oPID) {
            Remove-Item $script:logging_LockFile
        }
    }
}

function rotatelogs($f, $n) {
    $rf = getrotatefilename $f $n
    Remove-Item $rf -Force -Confirm:$false -ErrorAction SilentlyContinue
    foreach ($i in (($n-1) .. 0)) {
        $rfpre = getrotatefilename $f $i
        Move-Item $rfpre $rf -Force -ErrorAction SilentlyContinue
        $rf = $rfpre
    }
    Move-Item $f $rfpre -Force -ErrorAction SilentlyContinue
}

function getrotatefilename($f, $n) {
    $ext = [Io.Path]::GetExtension($f)
    $base = $f -replace "$ext$", ""
    $base + "-$n" + $ext
}

#
# logging functions --- write messasge to host and file
#
function log($v) {
    $m = $v -join('')
    Write-Host $m
    if ($script:logging_LogFileFP) { _wrlog $m }
}
function logerror($v) { logcl "red" $v }
function logcl($fg, $v) {
    $m = $v -join('')
    write-host -ForegroundColor $fg $m
    if ($script:logging_LogFileFP) { _wrlog $m }
}
function logv($v) {
    $m = $v -join('')
    if ($script:logging_Verbose) { Write-Host $m }
    if ($script:logging_LogFileFP) { _wrlog $m }
}

function loggingVerbose($f) {
    $script:logging_Verbose = $f
    logv "Logging Verbose set: $f"
}

function _wrlog($m) {
    Add-Content -Path $script:logging_LogFileFP -Value ((Get-Date -format $script:LogTimeFormat) + $m) -Encoding $script:logging_Encoding
}

Export-ModuleMember RunApp,log,logv,logcl,logerror,loggingVerbose,initlog,closelog,rotatelogs
# end of stdps
