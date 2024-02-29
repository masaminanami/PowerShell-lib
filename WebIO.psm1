#
# WebIO
#

Set-StrictMode -version latest

class WebIO {
    static $CacheDir;
    static $Expire;
    $PerfMon;

    static Init($dir, $exp) {
        [WebIO]::CacheDir = [System.IO.Path]::GetFullPath($dir)
        [WebIO]::Expire = $exp
        log "WebIO: Expire set: $($exp.tostring('yyyy/MM/dd HH:mm'))"
    }

    EnablePerfMon() { $this.EnablePerfMon($true) }
    EnablePerfMon($f) {
        $this.PerfMon = $f
        log "WebIO: PerfornceMonitoring set: $($f ? 'Enabled' : 'Disabled')"
    }

    Purge($limitDateTime) {
        log "WebIO purging old cache: $($limitDateTime)"
        Get-ChildItem -Path [WebIO]::CacheDir -File |? {$_.LastWriteTime -lt $limitDateTime } |Remove-Item -Force -Verbose:1
    }

    [string] Load($url) {
        $fp = Join-Path ([WebIO]::CacheDir) $this.getCacheFilename($url)
        if (Test-Path $fp) {
            $fd = Get-Item $fp
            if ($fd.LastWriteTime -gt [WebIO]::Expire) {
                logv "Loading from cache: $url $fp (LWT=$($fd.LastWriteTime.ToString('yyyyMMdd.HHmm')), Expire=$([WebIO]::Expire.ToString('yyyyMMdd.HHmm')))"
                return (Get-Content $fp) -join(' ')
            } else {
                logv "Cache exist but old: LWT=$($fd.LastWriteTime) $fp"
            }
        } else {
            logv "Cache does not exist: $url $fp"
        }

        $retry = 3
        while ($retry) {
            try {
                --$retry
                logcl "Cyan" "Loading Web content: $url"
                $res = $null
                $pmon = Measure-Command -Expression { $res = Invoke-WebRequest $url }
                if ($this.PerfMon) { log "WebIO Elapsted time: $($pmon)" }

                if ($res.StatusCode -eq 200) {
                    $res.Content |Out-File $fp -Encoding utf8
                    log "Cache saved: $fp, size=$($res.Content.Length)"
                    return $res.Content -join(' ')
                } else {
                    logerror "Web access error: $($res.StatusCode)"
                }
            } catch {
                logerror "Web access failed $error (retry=$retry)"
            }
        }
        return $null
    }

    [string] getCacheFilename($url) {
        return $url -replace '^[^:]+://','' -replace '/$','' -replace '[\./\?\&]','_'
    }

    [DateTime] GetLastUpdated($url) {
        $fp = Join-Path ([WebIO]::CacheDir) $this.getCacheFilename($url)
        return (Get-Item -LiteralPath $fp).LastWriteTime
    }
 }