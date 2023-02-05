#
# Utils
#

class Utils {
    static [object] GetValue($ht, [string]$key) {
        if ($ht.Contains($key)) { return $ht.$key }
        throw "ERROR! No data for key: $key"
    }

    static [object] GetValue($ht, [string]$key, $def) {
        return $ht.Contains($key) ? $ht.$key : $def
    }

    #--- for format migration
    static [object] GetValue2($ht, [string]$key, [string]$key2) {
        if ($ht.Contains($key)) { return $ht.$key }
        return [Utils]::GetValue($ht, $key2)
    }

    static [object] GetValue2($ht, [string]$key, [string]$key2, $def) {
        if ($ht.Contains($key)) { return $ht.$key }
        return $ht.Contains($key2) ? $ht.$key2 : $def
    }
}