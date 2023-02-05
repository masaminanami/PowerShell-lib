#
# MesaageBox
#
Add-Type -AssemblyName System.Windows.Forms

function MsgBox(
    [string]$text = "??",
    [string]$caption = "Message",
    [System.Windows.Forms.MessageBoxButtons]$buttons = [System.Windows.Forms.MessageBoxDefaultButton]::OK,
    [System.Windows.Forms.MessageBoxIcon]$icon = [System.Windows.Forms.MessageBoxIcon]::Information,
    [System.Windows.Forms.MessageBoxDefaultButton]$defaultButton = [System.Windows.Forms.MessageBoxDefaultButton]::Button1) {
        [System.Windows.Forms.MessageBox]::Show($text, $caption, $buttons, $icon, $defaultButton)
}
