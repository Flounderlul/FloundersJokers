param(
    [Parameter(Mandatory = $true)]
    [string]$InputPath,

    [Parameter(Mandatory = $true)]
    [string]$Slug,

    [string]$OutputName
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$workspace = Split-Path -Parent $PSScriptRoot
$assetName = if ($OutputName) { $OutputName } else { "j_$Slug.png" }
$oneXPath = Join-Path $workspace "assets/1x/$assetName"
$twoXPath = Join-Path $workspace "assets/2x/$assetName"

function New-RemasterBitmap {
    param(
        [System.Drawing.Image]$Source,
        [int]$Width,
        [int]$Height
    )

    $bitmap = [System.Drawing.Bitmap]::new($Width, $Height)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    try {
        $graphics.CompositingMode = [System.Drawing.Drawing2D.CompositingMode]::SourceCopy
        $graphics.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
        $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
        $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::None
        $graphics.DrawImage($Source, 0, 0, $Width, $Height)
    }
    finally {
        $graphics.Dispose()
    }

    # Collapse near-identical generated shades into deliberate pixel-art clusters.
    for ($y = 0; $y -lt $Height; $y++) {
        for ($x = 0; $x -lt $Width; $x++) {
            $pixel = $bitmap.GetPixel($x, $y)
            $red = [Math]::Min(255, [Math]::Round($pixel.R / 17) * 17)
            $green = [Math]::Min(255, [Math]::Round($pixel.G / 17) * 17)
            $blue = [Math]::Min(255, [Math]::Round($pixel.B / 17) * 17)
            $bitmap.SetPixel($x, $y, [System.Drawing.Color]::FromArgb($pixel.A, $red, $green, $blue))
        }
    }

    return $bitmap
}

$source = [System.Drawing.Image]::FromFile((Resolve-Path $InputPath))
try {
    $oneX = New-RemasterBitmap -Source $source -Width 71 -Height 95
    try {
        $oneX.Save($oneXPath, [System.Drawing.Imaging.ImageFormat]::Png)

        $twoX = [System.Drawing.Bitmap]::new(142, 190)
        $graphics = [System.Drawing.Graphics]::FromImage($twoX)
        try {
            $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
            $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::Half
            $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::None
            $graphics.DrawImage($oneX, 0, 0, 142, 190)
        }
        finally {
            $graphics.Dispose()
        }

        try {
            $twoX.Save($twoXPath, [System.Drawing.Imaging.ImageFormat]::Png)
        }
        finally {
            $twoX.Dispose()
        }
    }
    finally {
        $oneX.Dispose()
    }
}
finally {
    $source.Dispose()
}

Write-Output "Wrote $oneXPath and $twoXPath"
