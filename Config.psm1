#
# Config --- manage Cmd line args, default settings, and config settings
#
# setting priority
#   1. Command line otions (PSBoundParameters)
#   2. Settings in Config
#   3. Default setting in param()
#
class Config {
    Static Init($file) {
        if (-not $file) {
            log "Config: Warning! No Config file specified."
            return
        }

        $fp = [IO.Path]::GetFullPath($file)
        $cf = @{}
        if (Test-Path $fp) {
            $cf = Get-Content $fp | ConvertFrom-Json -AsHashtable
            foreach ($k in $cf.Keys) {
                if ($global:PSBoundParameters.count -eq 0 -or -not $global:PSBoundParameters.Keys.Contains($k)) {
                    <#
                    # Param $k is not set in command line
                    # scope must be globa as scope=script will add vars in this script
                    #>
                    Set-Variable -Scope global -Name $k -Value $cf.$k
                } else {
                    logv "Config: setting overridden by commandline param: $k"
                }
            }
        } else {
            log "Config: Warining! Setting file not found. Skip loading: $fp"
        }
    }
}