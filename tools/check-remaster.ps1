$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$workspace = Split-Path -Parent $PSScriptRoot
$luaPath = Join-Path $workspace 'FloundersJokers.lua'
$lua = Get-Content -Raw $luaPath

$slugs = [regex]::Matches($lua, 'slug\s*=\s*"([^"]+)"') |
    ForEach-Object { $_.Groups[1].Value } |
    Sort-Object -Unique

$failures = [System.Collections.Generic.List[string]]::new()

foreach ($scale in @('1x', '2x')) {
    $width = if ($scale -eq '1x') { 71 } else { 142 }
    $height = if ($scale -eq '1x') { 95 } else { 190 }

    foreach ($slug in $slugs) {
        $path = Join-Path $workspace "assets/$scale/j_$slug.png"
        if (-not (Test-Path $path)) {
            $failures.Add("Missing $scale sprite for $slug")
            continue
        }

        $image = [System.Drawing.Image]::FromFile($path)
        try {
            if ($image.Width -ne $width -or $image.Height -ne $height) {
                $failures.Add("Wrong dimensions for ${path}: $($image.Width)x$($image.Height)")
            }
        }
        finally {
            $image.Dispose()
        }
    }
}

if ($lua -match 'next\([^\r\n]+\)\s+do') {
    $failures.Add('Found invalid next(...) do syntax in Lua')
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Error $_ }
    exit 1
}

Write-Output "PASS: $($slugs.Count) Lua slugs have exact 1x and 2x sprites."
Write-Output 'PASS: legacy syntax regression checks are clean.'
