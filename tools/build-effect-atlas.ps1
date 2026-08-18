param(
    [string]$SourcePath = (Join-Path (Split-Path -Parent $PSScriptRoot) 'archive/remaster-sources/fj-effect-motes-source.png')
)

$ErrorActionPreference = 'Stop'
$workspace = Split-Path -Parent $PSScriptRoot
$ffmpeg = (Get-Command ffmpeg -ErrorAction Stop).Source
$oneX = Join-Path $workspace 'assets/1x/fj_effect_motes.png'
$twoX = Join-Path $workspace 'assets/2x/fj_effect_motes.png'

if (-not (Test-Path -LiteralPath $SourcePath)) { throw "Missing effect source: $SourcePath" }

# The generated source is a precise 2x2 grid. Each quadrant becomes one 16px
# semantic mote: gold glint, Dice spark, cursed shard, arcane ring.
$filter = @"
[0:v]crop=iw/2:ih/2:0:0,scale=16:16:flags=lanczos[a];
[0:v]crop=iw/2:ih/2:iw/2:0,scale=16:16:flags=lanczos[b];
[0:v]crop=iw/2:ih/2:0:ih/2,scale=16:16:flags=lanczos[c];
[0:v]crop=iw/2:ih/2:iw/2:ih/2,scale=16:16:flags=lanczos[d];
[a][b][c][d]hstack=inputs=4,format=rgba[out]
"@ -replace "`r|`n", ''

& $ffmpeg -hide_banner -loglevel error -y -i $SourcePath -filter_complex $filter -map '[out]' -frames:v 1 $oneX
if ($LASTEXITCODE -ne 0) { throw 'Failed to build 1x effect atlas.' }
& $ffmpeg -hide_banner -loglevel error -y -i $oneX -vf 'scale=128:32:flags=neighbor' -frames:v 1 $twoX
if ($LASTEXITCODE -ne 0) { throw 'Failed to build 2x effect atlas.' }

Write-Output "Wrote $oneX and $twoX"
