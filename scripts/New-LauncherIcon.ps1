# Creates the original placeholder launcher icon using Windows drawing primitives.
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
foreach ($target in @(
    @{Size=40;Folder='resources'},
    @{Size=60;Folder='resources-fr265'},
    @{Size=65;Folder='resources-fr965'}
)) {
$bitmap = New-Object System.Drawing.Bitmap $target.Size,$target.Size
$canvas = [System.Drawing.Graphics]::FromImage($bitmap)
$canvas.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$canvas.ScaleTransform($target.Size/40.0,$target.Size/40.0)
$canvas.Clear([System.Drawing.Color]::Black)
$pen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(204,252,0)),2
$canvas.DrawEllipse($pen,4,9,32,22)
$canvas.DrawEllipse($pen,9,13,22,14)
$canvas.DrawLine($pen,24,10,24,30)
$bitmap.Save((Join-Path (Split-Path $PSScriptRoot -Parent) ($target.Folder + '\drawables\launcher.png')), [System.Drawing.Imaging.ImageFormat]::Png)
$pen.Dispose()
$canvas.Dispose()
$bitmap.Dispose()
}
