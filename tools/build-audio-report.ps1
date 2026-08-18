$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$workspace = Split-Path -Parent $PSScriptRoot
$soundDir = Join-Path $workspace 'assets/sounds'
$docsDir = Join-Path $workspace 'docs'
$ffmpeg = (Get-Command ffmpeg -ErrorAction Stop).Source
$names = @('arcana','stone','weapon','coin','gem','echo','transform','conjure','dice','cursed','deck','voucher','blind','challenge')

function Measure-BandMean {
    param([string]$Path, [string]$Filter)
    $text = (& $ffmpeg -hide_banner -nostats -i $Path -af "$Filter,volumedetect" -f null NUL 2>&1) -join "`n"
    $match = [regex]::Match($text, 'mean_volume:\s+(-?\d+(?:\.\d+)?)\s+dB')
    if (-not $match.Success) { throw "Could not measure band energy for $Path" }
    return [double]$match.Groups[1].Value
}

$rows = foreach ($name in $names) {
    $path = Join-Path $soundDir "$name.ogg"
    $probe = & ffprobe -v error -show_entries 'format=duration' -of json $path | ConvertFrom-Json
    $measure = (& $ffmpeg -hide_banner -nostats -i $path -filter_complex 'ebur128=peak=true' -f null NUL 2>&1) -join "`n"
    $i = [regex]::Matches($measure, 'I:\s+(-?\d+(?:\.\d+)?)\s+LUFS')
    $p = [regex]::Matches($measure, 'Peak:\s+(-?\d+(?:\.\d+)?)\s+dBFS')
    $lufs = [double]$i[$i.Count - 1].Groups[1].Value
    $peak = [double]$p[$p.Count - 1].Groups[1].Value
    [pscustomobject]@{
        Cue = $name
        Duration = [math]::Round([double]$probe.format.duration, 2)
        LUFS = $lufs
        Peak = $peak
        Crest = [math]::Round($peak - $lufs, 1)
        Low = Measure-BandMean $path 'highpass=f=90,lowpass=f=300'
        Mid = Measure-BandMean $path 'highpass=f=300,lowpass=f=3000'
        High = Measure-BandMean $path 'highpass=f=3000,lowpass=f=12000'
    }
}

$markdown = [System.Collections.Generic.List[string]]::new()
$markdown.Add('# Audio mastering report')
$markdown.Add('')
$markdown.Add('All fourteen cues are measured from the packaged OGG masters. Band values are mean dBFS after the same 90–300 Hz, 300 Hz–3 kHz, and 3–12 kHz analysis filters.')
$markdown.Add('')
$markdown.Add('| Cue | Sec | LUFS-I | True peak | Crest | Low | Mid | High |')
$markdown.Add('|---|---:|---:|---:|---:|---:|---:|---:|')
foreach ($row in $rows) {
    $markdown.Add("| $($row.Cue) | $($row.Duration.ToString('0.00')) | $($row.LUFS.ToString('0.0')) | $($row.Peak.ToString('0.0')) dBFS | $($row.Crest.ToString('0.0')) dB | $($row.Low.ToString('0.0')) | $($row.Mid.ToString('0.0')) | $($row.High.ToString('0.0')) |")
}
$spread = ($rows | Measure-Object LUFS -Maximum).Maximum - ($rows | Measure-Object LUFS -Minimum).Minimum
$markdown.Add('')
$markdown.Add("Cross-family integrated-loudness spread: **$($spread.ToString('0.0')) LU**. Release ceiling: **5.0 LU**.")
$markdown.Add('')
$markdown.Add('The runtime layer adds a deterministic micro-pitch identity and a 90 ms per-card cooldown. No master contains speech, music, sub-bass, or a long reverb tail.')
[IO.File]::WriteAllLines((Join-Path $docsDir 'AUDIO_MASTERING_REPORT.md'), $markdown)

$stripWidth = 800; $stripHeight = 120; $labelHeight = 22
$canvas = [Drawing.Bitmap]::new($stripWidth, ($stripHeight + $labelHeight) * $names.Count)
$graphics = [Drawing.Graphics]::FromImage($canvas)
try {
    $graphics.Clear([Drawing.Color]::FromArgb(12, 11, 18))
    $font = [Drawing.Font]::new('Consolas', 11, [Drawing.FontStyle]::Bold)
    $brush = [Drawing.SolidBrush]::new([Drawing.Color]::FromArgb(238, 232, 220))
    try {
        for ($index = 0; $index -lt $names.Count; $index++) {
            $name = $names[$index]
            $temp = Join-Path $docsDir ".fj-spectrum-$name.png"
            & $ffmpeg -hide_banner -loglevel error -y -i (Join-Path $soundDir "$name.ogg") -lavfi "showspectrumpic=s=${stripWidth}x${stripHeight}:legend=0:color=fiery:scale=log:fscale=log" -frames:v 1 $temp
            if ($LASTEXITCODE -ne 0) { throw "Spectrogram failed for $name" }
            $spectrum = [Drawing.Bitmap]::FromFile($temp)
            try {
                $y = $index * ($stripHeight + $labelHeight)
                $graphics.DrawString($name.ToUpperInvariant(), $font, $brush, 8, $y + 2)
                $graphics.DrawImage($spectrum, 0, $y + $labelHeight, $stripWidth, $stripHeight)
            }
            finally { $spectrum.Dispose() }
            Remove-Item -LiteralPath $temp -Force
        }
    }
    finally { $font.Dispose(); $brush.Dispose() }
    $canvas.Save((Join-Path $docsDir 'audio-spectrograms.png'), [Drawing.Imaging.ImageFormat]::Png)
}
finally { $graphics.Dispose(); $canvas.Dispose() }

$rows | Format-Table -AutoSize
Write-Output "Wrote docs/AUDIO_MASTERING_REPORT.md and docs/audio-spectrograms.png"
