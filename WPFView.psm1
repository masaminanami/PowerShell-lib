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

    [Object] FindByName($n) { return $this.window.FindName($n) }

    Show() {
        $me = "$($this.GetType().Name).Show:"
        log "$me Starting window"
        $this.window.ShowDialog()
    }

    [bool] GetResult() { return $this.window.DialogResult }

    CloseWindow() {
        $this.window.Close()
    }

    #
    # subclass is expected to implement
    #
    SetupControls() {}
    Init($file) { $this.BaseInit($file) }
}

$global:WPFResizableView;
class WPFAutoResizableView : WPFView {
    [ResizeSpec]$ResizeSpec;
    [float]$FixedWidth;

    EnableAutoResize([ResizeSpec]$spec) {
        $global:WPFResizableView = $this
        $this.ResizeSpec = $spec
        $this.FixedWidth = $spec.MarginWidth
        foreach ($e in $this.ResizeSpec.Specs) {
            if (-not ($e.TargetColumn = $this.window.FindName($e.Name))) {
                throw "ERROR! $($this.GetType().Name).EnableAutoResize: Cannot find column name: $($e.Name)"
            }
            if ($e.IsFixed) {
                $this.FixedWidth += $e.Width
            }
        }
        log "$($this.GetType().Name).EnableAutoResize initialized $this $($this.GetHashCode())"

        $this.window.Add_SizeChanged({ $global:WPFResizableView.ResizeColumns()} )
    }

    ResizeColumns() {
        $ww = [Math]::Max($this.window.Width, $this.window.ActualWidth) - $this.FixedWidth
        foreach ($e in $this.ResizeSpec.Specs) {
            $w = $e.IsFixed ? $e.Width : $e.Width * $ww
            $e.TargetColumn.Width = [Math]::Max($w, $e.MinWidth)
        }
    }
}

class ResizeSpec {
    [float]$MarginWidth;
    [ColumnResizeSpec[]]$Specs;

    ResizeSpec($m, $s) {
        $this.MarginWidth = $m
        $this.Specs = $s
    }
}

class ColumnResizeSpec {
    [string]$Name;
    $TargetColumn;
    [bool]$IsFixed;
    [float]$Width;
    [float]$MinWidth;

    ColumnResizeSpec($n, $f, $w) {
        $this.Name = $n
        $this.IsFixed = $f
        $this.Width = $w
        $this.MinWidth = $f ? $w : 0
    }

    ColumnResizeSpec($n, $f, $w, $min) {
        $this.Name = $n
        $this.IsFixed = $f
        $this.Width = $w
        $this.MinWidth = $min
    }
}