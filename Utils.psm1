#
# Utils
#

class Utils {
    static [object] GetValue($ht, $key) {
        if ($ht.Contains($key)) { return $ht.$key }
        throw "ERROR! No data for key: $key"
    }

    static [object] GetValue($ht, $key, $def) {
        return $ht.Contains($key) ? $ht.$key : $def
    }
}