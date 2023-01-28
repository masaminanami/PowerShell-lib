#
# Asset
#

Set-StrictMode -Version latest

class Assert {
    static Test($exp) {
        if (-not ($exp)) {
            throw "Assetion Failed: $($MyInvocation.PSCommandPath):$($MyInvocation.ScriptLineNumber) '$($MyInvocation.Line.trim())'"
        }
    }
}