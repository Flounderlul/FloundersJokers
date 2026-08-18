$ErrorActionPreference = 'Stop'

$workspace = Split-Path -Parent $PSScriptRoot
& (Join-Path $PSScriptRoot 'qa-release.ps1')
if ($LASTEXITCODE -ne 0) { throw 'Release QA failed; package was not created.' }

$dist = Join-Path $workspace 'dist'
$stage = Join-Path $dist 'FloundersJokers'
$zip = Join-Path $dist 'FloundersJokers-Definitive-3.0.0.zip'
New-Item -ItemType Directory -Force -Path $dist | Out-Null

$distRoot = [System.IO.Path]::GetFullPath($dist).TrimEnd('\') + '\'
foreach ($target in @($stage, $zip)) {
    $resolvedTarget = [System.IO.Path]::GetFullPath($target)
    if (-not $resolvedTarget.StartsWith($distRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Refusing to modify a path outside dist: $resolvedTarget"
    }
}

if (Test-Path -LiteralPath $stage) { Remove-Item -LiteralPath $stage -Recurse -Force }
New-Item -ItemType Directory -Force -Path $stage | Out-Null

$files = @(
    'flounderjokers.json', 'config.lua', 'main.lua', 'FloundersJokers.lua',
    'README.md', 'CHANGELOG.md', 'ART_DIRECTION.md'
)
foreach ($file in $files) { Copy-Item -LiteralPath (Join-Path $workspace $file) -Destination $stage }
foreach ($folder in @('assets','modules','audio','docs','tools','archive')) {
    Copy-Item -LiteralPath (Join-Path $workspace $folder) -Destination (Join-Path $stage $folder) -Recurse
}

if (Test-Path -LiteralPath $zip) { Remove-Item -LiteralPath $zip -Force }
Compress-Archive -LiteralPath $stage -DestinationPath $zip -CompressionLevel Optimal
Remove-Item -LiteralPath $stage -Recurse -Force
Write-Output "Created $zip"
