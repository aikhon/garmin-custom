# Creates the original placeholder launcher icon using Windows drawing primitives.
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$bitmap = New-Object System.Drawing.Bitmap 40,40
$canvas = [System.Drawing.Graphics]::FromImage($bitmap)
$canvas.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$canvas.Clear([System.Drawing.Color]::Black)
$pen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(85,221,204)),2
$canvas.DrawEllipse($pen,4,9,32,22)
$canvas.DrawEllipse($pen,9,13,22,14)
$canvas.DrawLine($pen,24,10,24,30)
$bitmap.Save((Join-Path $PSScriptRoot '..\resources\drawables\launcher.png'), [System.Drawing.Imaging.ImageFormat]::Png)
$pen.Dispose()
$canvas.Dispose()
$bitmap.Dispose()
