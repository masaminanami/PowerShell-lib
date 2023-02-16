#
# WPF Window
#

Add-Type -AssemblyName PresentationCore,PresentationFramework

function New-WindowObject($r) { [System.Windows.Markup.XamlReader]::Load($r) }

class WPFView {
    $window;

    BaseInit($file) {
        $this.CreateWindow($file)
        $this.SetupControls()
    }

    CreateWindow($file) {
        [XML]$xaml = Get-Content $file
        $this.EditXamlData($xaml)
        $reader = [System.Xml.XmlNodeReader]::New($xaml)
        $this.window = New-WindowObject $reader
    }

    EditXamlData($xaml) {
        "x:Class","mc:Ignorable" |%{ $xaml.window.RemoveAttribute($_) }
    }

    #
    # subclass is expected to implement
    #
    SetupControls() {}
    Init($file) { $this.BaseInit($file) }
}