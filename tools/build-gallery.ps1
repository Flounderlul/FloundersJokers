$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$workspace = Split-Path -Parent $PSScriptRoot
$legacy = Get-Content -Raw (Join-Path $workspace 'FloundersJokers.lua')
$suite = Get-Content -Raw (Join-Path $workspace 'modules/dice_suite.lua')
$slugs = @(
    [regex]::Matches($legacy, 'slug\s*=\s*"([^"]+)"') | ForEach-Object { $_.Groups[1].Value }
) + @('loaded_stone','brass_cup','payout_gem','house_edge','double_down','croupier')
$slugs = $slugs | Sort-Object -Unique

$columns = 10
$cardW, $cardH = 142, 190
$cellW, $cellH = 158, 222
$rows = [Math]::Ceiling($slugs.Count / $columns)
$outer = 24
$headerH = 82
$canvas = [System.Drawing.Bitmap]::new($columns * $cellW + $outer * 2, $rows * $cellH + $headerH + $outer * 2)
$graphics = [System.Drawing.Graphics]::FromImage($canvas)
try {
    $graphics.Clear([System.Drawing.Color]::FromArgb(11, 15, 20))
    $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
    $font = [System.Drawing.Font]::new('Consolas', 10, [System.Drawing.FontStyle]::Regular)
    $titleFont = [System.Drawing.Font]::new('Consolas', 24, [System.Drawing.FontStyle]::Bold)
    $subFont = [System.Drawing.Font]::new('Consolas', 11, [System.Drawing.FontStyle]::Regular)
    $brush = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(235, 235, 242))
    $mutedBrush = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(178, 193, 184))
    $panelBrush = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(20, 29, 35))
    $goldPen = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(196, 151, 62), 5)
    $greenPen = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(47, 111, 86), 2)
    $cellPen = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(67, 84, 88), 1)
    try {
        $graphics.FillRectangle($panelBrush, $outer, $outer, $canvas.Width - $outer * 2, $headerH - 8)
        $graphics.DrawRectangle($goldPen, 3, 3, $canvas.Width - 7, $canvas.Height - 7)
        $graphics.DrawRectangle($greenPen, 12, 12, $canvas.Width - 25, $canvas.Height - 25)
        $graphics.DrawString("FLOUNDER'S JOKERS", $titleFont, $brush, $outer + 18, $outer + 8)
        $graphics.DrawString("THE COMPLETE 60-CARD CURIO CATALOGUE  /  NATIVE 2X RUNTIME ART", $subFont, $mutedBrush, $outer + 21, $outer + 45)
        for ($index = 0; $index -lt $slugs.Count; $index++) {
            $slug = $slugs[$index]
            $cellX = $outer + ($index % $columns) * $cellW
            $cellY = $outer + $headerH + [Math]::Floor($index / $columns) * $cellH
            $graphics.FillRectangle($panelBrush, $cellX + 3, $cellY + 3, $cellW - 6, $cellH - 6)
            $graphics.DrawRectangle($cellPen, $cellX + 3, $cellY + 3, $cellW - 7, $cellH - 7)
            $x = $cellX + 8
            $y = $cellY + 7
            $image = [System.Drawing.Image]::FromFile((Join-Path $workspace "assets/2x/j_$slug.png"))
            try { $graphics.DrawImage($image, $x, $y, $cardW, $cardH) }
            finally { $image.Dispose() }
            $graphics.DrawString($slug, $font, $brush, $x, $y + $cardH + 5)
        }
    }
    finally {
        $cellPen.Dispose(); $greenPen.Dispose(); $goldPen.Dispose()
        $panelBrush.Dispose(); $mutedBrush.Dispose(); $brush.Dispose()
        $subFont.Dispose(); $titleFont.Dispose(); $font.Dispose()
    }
}
finally { $graphics.Dispose() }

$output = Join-Path $workspace 'docs/remaster-gallery.png'
try { $canvas.Save($output, [System.Drawing.Imaging.ImageFormat]::Png) }
finally { $canvas.Dispose() }
Write-Output "Wrote $output with $($slugs.Count) Jokers."
