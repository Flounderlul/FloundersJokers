param(
    [Parameter(Mandatory = $true)][string]$SourceName,
    [Parameter(Mandatory = $true)][string]$OutputName
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$workspace = Split-Path -Parent $PSScriptRoot
$scales = @(
    @{ Folder = '1x'; Width = 71; Height = 95 },
    @{ Folder = '2x'; Width = 142; Height = 190 }
)
$scaleX = @(0.96, 0.98, 1.00, 1.02, 1.04, 1.03, 1.01, 0.99, 0.97, 0.96, 0.96, 0.97)
$scaleY = @(1.02, 1.01, 1.00, 0.99, 0.98, 0.99, 1.00, 1.01, 1.02, 1.03, 1.02, 1.02)
$shiftY = @(1, 1, 0, 0, 0, 0, 0, 1, 1, 0, 0, 1)
$glint = @(0, 0, 35, 90, 170, 255, 170, 75, 20, 0, 0, 0)

foreach ($scale in $scales) {
    $sourcePath = Join-Path $workspace "assets/$($scale.Folder)/$SourceName"
    $outputPath = Join-Path $workspace "assets/$($scale.Folder)/$OutputName"
    $source = [System.Drawing.Bitmap]::FromFile($sourcePath)
    try {
        $sheet = [System.Drawing.Bitmap]::new($scale.Width * $scaleX.Count, $scale.Height)
        $graphics = [System.Drawing.Graphics]::FromImage($sheet)
        try {
            $graphics.Clear([System.Drawing.Color]::Transparent)
            $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
            $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::Half
            $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::None
            for ($frame = 0; $frame -lt $scaleX.Count; $frame++) {
                $w = [int][Math]::Round($scale.Width * $scaleX[$frame])
                $h = [int][Math]::Round($scale.Height * $scaleY[$frame])
                $x = $frame * $scale.Width + [int][Math]::Round(($scale.Width - $w) / 2)
                $y = [int][Math]::Round(($scale.Height - $h) / 2) + $shiftY[$frame] * ($scale.Width / 71)
                $graphics.DrawImage($source, $x, $y, $w, $h)

                if ($glint[$frame] -gt 0) {
                    $unit = [int]($scale.Width / 71)
                    $cx = $frame * $scale.Width + [int]($scale.Width * 0.58)
                    $cy = [int]($scale.Height * 0.42)
                    $colour = [System.Drawing.Color]::FromArgb($glint[$frame], 255, 248, 205)
                    $pen = [System.Drawing.Pen]::new($colour, [Math]::Max(1, $unit))
                    try {
                        $arm = 2 * $unit
                        $graphics.DrawLine($pen, $cx - $arm, $cy, $cx + $arm, $cy)
                        $graphics.DrawLine($pen, $cx, $cy - $arm, $cx, $cy + $arm)
                    }
                    finally { $pen.Dispose() }
                }
            }
        }
        finally { $graphics.Dispose() }
        try { $sheet.Save($outputPath, [System.Drawing.Imaging.ImageFormat]::Png) }
        finally { $sheet.Dispose() }
    }
    finally { $source.Dispose() }
    Write-Output "Wrote animated sheet $outputPath"
}
