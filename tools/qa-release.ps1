param([switch]$AllowMissingGeneratedAudio)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$workspace = Split-Path -Parent $PSScriptRoot
$failures = [System.Collections.Generic.List[string]]::new()
$warnings = [System.Collections.Generic.List[string]]::new()

function Assert-Image {
    param([string]$Path, [int]$Width, [int]$Height)
    if (-not (Test-Path -LiteralPath $Path)) { $failures.Add("Missing image: $Path"); return }
    $image = [System.Drawing.Image]::FromFile($Path)
    try {
        if ($image.Width -ne $Width -or $image.Height -ne $Height) {
            $failures.Add("Wrong dimensions: $Path is $($image.Width)x$($image.Height), expected ${Width}x${Height}")
        }
    }
    finally { $image.Dispose() }
}

function Assert-FrameSheet {
    param([string]$Path, [int]$FrameWidth, [int]$FrameHeight, [int]$Frames)
    if (-not (Test-Path -LiteralPath $Path)) { $failures.Add("Missing frame sheet: $Path"); return }
    $bitmap = [System.Drawing.Bitmap]::FromFile($Path)
    try {
        if ($bitmap.Width -ne $FrameWidth * $Frames -or $bitmap.Height -ne $FrameHeight) {
            $failures.Add("Invalid frame grid: $Path")
            return
        }
        $signatures = [System.Collections.Generic.HashSet[string]]::new()
        $centroidsX = [System.Collections.Generic.List[double]]::new()
        $centroidsY = [System.Collections.Generic.List[double]]::new()
        for ($frame = 0; $frame -lt $Frames; $frame++) {
            $count = 0; $sumX = 0.0; $sumY = 0.0; $sumAlpha = 0L
            $minX = $FrameWidth; $maxX = -1; $minY = $FrameHeight; $maxY = -1
            $edgePixels = 0
            for ($y = 0; $y -lt $FrameHeight; $y++) {
                for ($x = 0; $x -lt $FrameWidth; $x++) {
                    $pixel = $bitmap.GetPixel($frame * $FrameWidth + $x, $y)
                    if ($pixel.A -gt 8) {
                        $count++; $sumX += $x; $sumY += $y; $sumAlpha += $pixel.A
                        $minX = [math]::Min($minX, $x); $maxX = [math]::Max($maxX, $x)
                        $minY = [math]::Min($minY, $y); $maxY = [math]::Max($maxY, $y)
                        if ($x -eq 0 -or $x -eq $FrameWidth - 1) { $edgePixels++ }
                    }
                }
            }
            if ($count -lt 20) { $failures.Add("Frame $frame is effectively empty: $Path"); continue }
            if ($edgePixels -gt 0) { $failures.Add("Frame $frame bleeds across its cell boundary: $Path") }
            $centroidsX.Add($sumX / $count); $centroidsY.Add($sumY / $count)
            [void]$signatures.Add("${count}:${minX}:${maxX}:${minY}:${maxY}:${sumAlpha}")
        }
        if ($signatures.Count -lt [math]::Ceiling($Frames / 2)) {
            $failures.Add("Insufficient frame diversity in $Path; found $($signatures.Count) distinct silhouettes")
        }
        if ($centroidsX.Count -and ((($centroidsX | Measure-Object -Maximum).Maximum - ($centroidsX | Measure-Object -Minimum).Minimum) -gt 3.0 -or (($centroidsY | Measure-Object -Maximum).Maximum - ($centroidsY | Measure-Object -Minimum).Minimum) -gt 3.0)) {
            $failures.Add("Animation centroid drifts too far in $Path")
        }
    }
    finally { $bitmap.Dispose() }
}

function Assert-OpaqueFrameSheet {
    param([string]$Path, [int]$FrameWidth, [int]$FrameHeight, [int]$Frames)
    if (-not (Test-Path -LiteralPath $Path)) { $failures.Add("Missing frame sheet: $Path"); return }
    $bitmap = [System.Drawing.Bitmap]::FromFile($Path)
    try {
        if ($bitmap.Width -ne $FrameWidth * $Frames -or $bitmap.Height -ne $FrameHeight) {
            $failures.Add("Invalid opaque frame grid: $Path"); return
        }
        $signatures = [System.Collections.Generic.HashSet[string]]::new()
        for ($frame = 0; $frame -lt $Frames; $frame++) {
            $sum = 0L
            for ($y = 0; $y -lt $FrameHeight; $y++) {
                for ($x = 0; $x -lt $FrameWidth; $x++) {
                    $p = $bitmap.GetPixel($frame * $FrameWidth + $x, $y)
                    $sum += ($p.R * 3 + $p.G * 5 + $p.B * 7) * (1 + $x + $y * 2)
                }
            }
            [void]$signatures.Add([string]$sum)
        }
        if ($signatures.Count -lt 3) { $failures.Add("Insufficient opaque-frame diversity in $Path") }
    }
    finally { $bitmap.Dispose() }
}

$legacy = Get-Content -Raw (Join-Path $workspace 'FloundersJokers.lua')
$main = Get-Content -Raw (Join-Path $workspace 'main.lua')
$readme = Get-Content -Raw (Join-Path $workspace 'README.md')
$suite = Get-Content -Raw (Join-Path $workspace 'modules/dice_suite.lua')
$dice = Get-Content -Raw (Join-Path $workspace 'modules/dice_seals.lua')
$presentation = Get-Content -Raw (Join-Path $workspace 'modules/presentation.lua')
$sounds = Get-Content -Raw (Join-Path $workspace 'modules/sounds.lua')
$configUi = Get-Content -Raw (Join-Path $workspace 'modules/config_ui.lua')
$configSource = Get-Content -Raw (Join-Path $workspace 'config.lua')
$progression = Get-Content -Raw (Join-Path $workspace 'modules/progression.lua')
$saveCompat = Get-Content -Raw (Join-Path $workspace 'modules/save_compat.lua')
$atlasBindings = Get-Content -Raw (Join-Path $workspace 'modules/atlas_bindings.lua')
$decks = Get-Content -Raw (Join-Path $workspace 'modules/decks.lua')
$vouchers = Get-Content -Raw (Join-Path $workspace 'modules/vouchers.lua')
$blinds = Get-Content -Raw (Join-Path $workspace 'modules/blinds.lua')
$challenges = Get-Content -Raw (Join-Path $workspace 'modules/challenges.lua')
$legacySlugs = [regex]::Matches($legacy, 'slug\s*=\s*"([^"]+)"') | ForEach-Object { $_.Groups[1].Value } | Sort-Object -Unique
$suiteSlugs = [regex]::Matches($suite, "register_atlas\(key\)|'([a-z_]+)'" ) | ForEach-Object { $_.Groups[1].Value } | Where-Object { $_ -in @('loaded_stone','brass_cup','payout_gem','house_edge','double_down','croupier') } | Sort-Object -Unique

if ($legacySlugs.Count -ne 54) { $failures.Add("Expected 54 legacy Jokers; found $($legacySlugs.Count)") }
if ($suiteSlugs.Count -ne 6) { $failures.Add("Expected 6 Dice-suite Jokers; found $($suiteSlugs.Count)") }

foreach ($slug in @($legacySlugs) + @($suiteSlugs)) {
    $mappingCount = [regex]::Matches($presentation, "'$( [regex]::Escape($slug) )'").Count
    if ($mappingCount -ne 1) {
        $failures.Add("Expected exactly one presentation-family mapping for $slug; found $mappingCount")
    }
}

$effectHooks = [regex]::Matches($legacy, 'FJ_EFFECT\(self\)').Count
if ($effectHooks -ne 25) { $failures.Add("Expected 25 creator probability-effect hooks; found $effectHooks") }
if ([regex]::Matches($suite, 'SMODS\.Joker\s*\{').Count -ne 6) { $failures.Add('Dice suite must register exactly 6 native Jokers') }
if ([regex]::Matches($dice, 'SMODS\.Seal\s*\{').Count -ne 2) { $failures.Add('Canonical Dice module must register exactly 2 native Seals') }
if ([regex]::Matches($dice, 'SMODS\.Consumable\s*\{').Count -ne 2) { $failures.Add('Canonical Dice module must register exactly 2 native Consumables') }
if ([regex]::Matches($decks, 'SMODS\.Back\s*\{').Count -ne 3) { $failures.Add('Progression chapter must register exactly 3 native Decks') }
if ([regex]::Matches($vouchers, 'SMODS\.Voucher\s*\{').Count -ne 4) { $failures.Add('Progression chapter must register exactly 4 native Vouchers') }
if ([regex]::Matches($blinds, 'SMODS\.Blind\s*\{').Count -ne 4) { $failures.Add('Progression chapter must register exactly 4 native Blinds') }
if ([regex]::Matches($challenges, "challenge\('").Count -ne 6) { $failures.Add('Progression chapter must register exactly 6 native Challenges') }
if ($progression -notmatch 'G\.GAME\.fj_progression' -or $progression -match '^\s*function\s+(create_card|poll_edition|Tag:|Blind:)') {
    $failures.Add('Progression state is not namespaced or introduces a forbidden global override')
}
if ($progression -notmatch 'fj_workshop_start' -or $vouchers -notmatch 'modify_joker_weights' -or $vouchers -notmatch 'no_negative\s*=\s*true') {
    $failures.Add('Deterministic deck selection, native weighting, or non-Negative edition safeguards are missing')
}
if ($blinds -notmatch 'house_probability_original' -or $blinds -notmatch 'restore_house' -or $challenges -notmatch 'unlocked\s*=\s*function\(\) return true') {
    $failures.Add('Blind restoration or immediately available challenge guarantees are missing')
}
if ($dice -notmatch 'G\.SETTINGS\.reduced_motion' -or $suite -notmatch 'G\.SETTINGS\.reduced_motion' -or $presentation -notmatch 'G\.SETTINGS\.reduced_motion') {
    $failures.Add('Added animation and card juice must respect Reduced Motion')
}
if ([regex]::Matches($presentation, 'SMODS\.DrawStep\s*\{').Count -ne 2 -or $presentation -notmatch "order\s*=\s*21" -or $presentation -notmatch "order\s*=\s*22") {
    $failures.Add('Expected layered native trigger DrawSteps at orders 21 and 22')
}
if ($presentation -notmatch 'fj_effect_until\s*=\s*now\s*\+\s*0\.32') {
    $failures.Add('Trigger presentation must remain bounded to 320 ms')
}
if ([regex]::Matches($configUi, 'create_toggle\s*\{').Count -ne 2 -or $configUi -notmatch 'mod\.config_tab\s*=') {
    $failures.Add('Expected a two-control Steamodded presentation config tab')
}
foreach ($setting in @('sfx_enabled','sfx_volume','kinetic_effects')) {
    if ($configSource -notmatch "\b$setting\s*=") { $failures.Add("Missing saved config default: $setting") }
}
if ($sounds -notmatch 'config\.sfx_enabled\s*==\s*false' -or $presentation -notmatch 'config\.kinetic_effects\s*==\s*false') {
    $failures.Add('Presentation config controls are not wired to runtime effects')
}
if ($sounds -notmatch 'mix_window\s*=\s*0\.18' -or $sounds -notmatch 'family_trim\s*=' -or $sounds -notmatch 'math\.min\(\s*0\.45') {
    $failures.Add('Measured family trims or the bounded 180 ms audio voice budget are missing')
}

$expectedJokerAssets = @($legacySlugs) + @($suiteSlugs) | ForEach-Object { "j_$_.png" } | Sort-Object -Unique
foreach ($scale in @('1x','2x')) {
    $actualJokerAssets = Get-ChildItem -LiteralPath (Join-Path $workspace "assets/$scale") -Filter 'j_*.png' -File | ForEach-Object Name | Sort-Object -Unique
    $unexpected = @(Compare-Object $expectedJokerAssets $actualJokerAssets | Where-Object SideIndicator -eq '=>' | ForEach-Object InputObject)
    if ($unexpected.Count) { $failures.Add("Unexpected runtime Joker assets at ${scale}: $($unexpected -join ', ')") }
    $hashes = @{}
    foreach ($name in $actualJokerAssets) {
        $hash = (Get-FileHash -LiteralPath (Join-Path $workspace "assets/$scale/$name") -Algorithm SHA256).Hash
        if ($hashes.ContainsKey($hash)) { $failures.Add("Duplicate ${scale} Joker art: $name and $($hashes[$hash])") }
        else { $hashes[$hash] = $name }
    }
}

foreach ($slug in @($legacySlugs) + @($suiteSlugs)) {
    Assert-Image (Join-Path $workspace "assets/1x/j_$slug.png") 71 95
    Assert-Image (Join-Path $workspace "assets/2x/j_$slug.png") 142 190
}

foreach ($asset in @('c_oops_all_20s.png','c_oops_no_20s.png','dice_seal.png','cursed_dice_seal.png','modicon.png')) {
    Assert-Image (Join-Path $workspace "assets/1x/$asset") 71 95
    Assert-Image (Join-Path $workspace "assets/2x/$asset") 142 190
}
Assert-Image (Join-Path $workspace 'assets/1x/fj_effect_motes.png') 64 16
Assert-Image (Join-Path $workspace 'assets/2x/fj_effect_motes.png') 128 32
Assert-FrameSheet (Join-Path $workspace 'assets/1x/dice_seal_animated.png') 71 95 12
Assert-FrameSheet (Join-Path $workspace 'assets/2x/dice_seal_animated.png') 142 190 12
Assert-FrameSheet (Join-Path $workspace 'assets/1x/cursed_dice_seal_animated.png') 71 95 12
Assert-FrameSheet (Join-Path $workspace 'assets/2x/cursed_dice_seal_animated.png') 142 190 12
foreach ($asset in @('b_loaded.png','b_workshop.png','b_curator.png','v_wax_stamp.png','v_sealing_press.png','v_display_case.png','v_private_collection.png')) {
    Assert-OpaqueFrameSheet (Join-Path $workspace "assets/1x/$asset") 71 95 6
    Assert-OpaqueFrameSheet (Join-Path $workspace "assets/2x/$asset") 142 190 6
}
foreach ($asset in @('bl_quarry.png','bl_lock.png','bl_house.png','bl_mirror.png')) {
    Assert-OpaqueFrameSheet (Join-Path $workspace "assets/1x/$asset") 34 34 6
    Assert-OpaqueFrameSheet (Join-Path $workspace "assets/2x/$asset") 68 68 6
}

if ($legacy -match "pseudorandom\('lucky_money'\)") { $failures.Add('Shared lucky_money RNG stream remains') }
if ($legacy -match 'function\s+Tag:init') { $failures.Add('Global Tag:init override remains') }
if ([regex]::Matches($legacy, 'SMODS\.Sprite:new\(\s*"j_"\s*\.\.').Count -ne 0) { $failures.Add('Legacy Joker atlas keys still use the incompatible j_ prefix') }
if ([regex]::Matches($legacy, '(?m)([A-Za-z_]\w*)\.eternal_compat,\s*nil,\s*\1\.slug').Count -ne 54) { $failures.Add('All 54 legacy Joker constructors must explicitly bind their matching atlas') }
if ($main -notmatch "modules/atlas_bindings\.lua" -or $atlasBindings -notmatch 'bound\s*>=\s*33\s+and\s+bound\s*<=\s*60' -or $atlasBindings -notmatch 'center\.atlas\s*=\s*atlas_key') { $failures.Add('The fail-closed registered-Joker runtime atlas audit is missing') }
if ([regex]::Matches($legacy, '(?<!context\.other_card and )context\.other_card:is_suit').Count -ne 0) { $failures.Add('An unsafe legacy context.other_card suit access remains') }
if ($main -notmatch "modules/save_compat\.lua" -or $saveCompat -notmatch 'save\.SCORING_CALC' -or $saveCompat -notmatch 'card_limits' -or $saveCompat -notmatch 'played_this_ante') { $failures.Add('Packaged legacy-save migration is missing or incomplete') }
if ($legacy -match 'SMODS\.Jokers\.') { $failures.Add('Obsolete pre-1.0 SMODS.Jokers registry lookup remains') }
if ($legacy -match 'SMODS\.INIT\.(CodexArcanum|MoreFluff|Reverie|MusicalSuit|CrownsSuit|SixSuit)') { $failures.Add('Legacy optional-mod detection remains') }
if ($legacy -match '^--- STEAMODDED HEADER') { $failures.Add('Legacy Lua file still advertises a second mod header') }
if (-not (Test-Path -LiteralPath (Join-Path $workspace 'docs/RELEASE_CERTIFICATION.md'))) { $failures.Add('Release certification is missing') }
foreach ($readmeAsset in @('docs/readme-hero.png','docs/readme-progression.png')) {
    if (-not (Test-Path -LiteralPath (Join-Path $workspace $readmeAsset))) { $failures.Add("README showcase asset missing: $readmeAsset") }
    elseif ((Get-Item -LiteralPath (Join-Path $workspace $readmeAsset)).Length -lt 100000) { $failures.Add("README showcase asset is unexpectedly small: $readmeAsset") }
    if ($readme -notmatch [regex]::Escape($readmeAsset)) { $failures.Add("README does not reference showcase asset: $readmeAsset") }
}

$metadataPath = Join-Path $workspace 'flounderjokers.json'
try { $metadata = Get-Content -Raw $metadataPath | ConvertFrom-Json }
catch { $failures.Add("Invalid metadata JSON: $($_.Exception.Message)") }
if ($metadata.id -ne 'flounderjokers' -or $metadata.main_file -ne 'main.lua' -or $metadata.config_file -ne 'config.lua' -or $metadata.version -ne '3.0.0') { $failures.Add('Metadata ID, files, or 3.0.0 version is incorrect') }
if (-not $metadata.optional_features.object_weights) { $failures.Add('Native object weighting feature is not declared') }

$audio = @('arcana','stone','weapon','coin','gem','echo','transform','conjure','dice','cursed','deck','voucher','blind','challenge')
$audioHashes = @{}
$integratedLevels = [System.Collections.Generic.List[double]]::new()
foreach ($name in $audio) {
    $path = Join-Path $workspace "assets/sounds/$name.ogg"
    if (-not (Test-Path -LiteralPath $path)) {
        if ($AllowMissingGeneratedAudio) { $warnings.Add("Pending ElevenLabs asset: $name.ogg") }
        else { $failures.Add("Missing canonical audio asset: $name.ogg") }
        continue
    }

    try {
        $probe = & ffprobe -v error -show_entries 'format=duration:stream=codec_name,sample_rate,channels' -of json $path | ConvertFrom-Json
        $stream = @($probe.streams)[0]
        $duration = [double]$probe.format.duration
        if ($stream.codec_name -ne 'vorbis') { $failures.Add("$name.ogg must use Vorbis; found $($stream.codec_name)") }
        if ([int]$stream.sample_rate -ne 44100) { $failures.Add("$name.ogg must be 44.1 kHz; found $($stream.sample_rate)") }
        if ([int]$stream.channels -ne 2) { $failures.Add("$name.ogg must be stereo; found $($stream.channels) channels") }
        if ($duration -lt 0.75 -or $duration -gt 1.05) { $failures.Add("$name.ogg duration $duration is outside 0.75-1.05 seconds") }

        # FFmpeg writes its probe report to stderr even on a successful exit.
        # Keep that expected native stderr from becoming a terminating
        # PowerShell error when the release script runs with Stop semantics.
        $previousErrorAction = $ErrorActionPreference
        try {
            $ErrorActionPreference = 'Continue'
            $measure = (& ffmpeg -hide_banner -nostats -i $path -filter_complex 'ebur128=peak=true' -f null NUL 2>&1) -join "`n"
        }
        finally {
            $ErrorActionPreference = $previousErrorAction
        }
        $integratedMatches = [regex]::Matches($measure, 'I:\s+(-?\d+(?:\.\d+)?)\s+LUFS')
        $peakMatches = [regex]::Matches($measure, 'Peak:\s+(-?\d+(?:\.\d+)?)\s+dBFS')
        if (-not $integratedMatches.Count -or -not $peakMatches.Count) {
            $failures.Add("Could not measure loudness for $name.ogg")
        }
        else {
            $integrated = [double]$integratedMatches[$integratedMatches.Count - 1].Groups[1].Value
            $peak = [double]$peakMatches[$peakMatches.Count - 1].Groups[1].Value
            $integratedLevels.Add($integrated)
            if ($integrated -lt -24.5 -or $integrated -gt -19.5) { $failures.Add("$name.ogg loudness $integrated LUFS is outside -24.5 to -19.5") }
            if ($peak -gt -1.0) { $failures.Add("$name.ogg true peak $peak dBFS exceeds -1.0 dBFS") }
        }

        $hash = (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash
        if ($audioHashes.ContainsKey($hash)) { $failures.Add("$name.ogg duplicates $($audioHashes[$hash]) byte-for-byte") }
        else { $audioHashes[$hash] = "$name.ogg" }
    }
    catch {
        $failures.Add("Audio probe failed for $name.ogg: $($_.Exception.Message)")
    }
}
if ($integratedLevels.Count -eq $audio.Count) {
    $spread = ($integratedLevels | Measure-Object -Maximum).Maximum - ($integratedLevels | Measure-Object -Minimum).Minimum
    if ($spread -gt 5.0) { $failures.Add("Cross-family loudness spread $spread LU exceeds 5.0 LU") }
}

$luaFiles = @('config.lua','main.lua','FloundersJokers.lua','modules/dice_seals.lua','modules/dice_suite.lua','modules/progression.lua','modules/decks.lua','modules/vouchers.lua','modules/blinds.lua','modules/challenges.lua','modules/sounds.lua','modules/presentation.lua','modules/config_ui.lua')
try {
    $script = "const fs = require('fs'); const lp = require('luaparse'); process.argv.slice(1).forEach(f => lp.parse(fs.readFileSync(f, 'utf8')));"
    $nodeArgs = @('-e', $script) + ($luaFiles | ForEach-Object { Join-Path $workspace $_ })
    & node @nodeArgs
    if ($LASTEXITCODE -ne 0) { $failures.Add("Lua syntax validation failed.") }
} catch {
    $failures.Add("Lua parse error: $($_.Exception.Message)")
}

if ($warnings.Count) { $warnings | ForEach-Object { Write-Warning $_ } }
if ($failures.Count) { $failures | ForEach-Object { Write-Error $_ }; exit 1 }

Write-Output "PASS: $($legacySlugs.Count + $suiteSlugs.Count) Jokers have exact 1x/2x assets."
Write-Output 'PASS: 2 measured twelve-frame seal animations, a four-motif FX atlas, and 4 canonical Dice objects are present.'
Write-Output 'PASS: all 60 presentation mappings, 25 probability hooks, layered bounded DrawStep physics, and Reduced Motion gates are present.'
Write-Output 'PASS: 3 Decks, 4 Boss Blinds, 4 Vouchers, and 6 immediately available mastery Challenges pass progression QA.'
Write-Output 'PASS: unique runtime art, saved presentation controls, metadata, RNG isolation, override safety, and Lua syntax checks are clean.'
if ($AllowMissingGeneratedAudio -and $warnings.Count) { Write-Output "PENDING: $($warnings.Count) ElevenLabs masters; runtime fallbacks remain active." }
else { Write-Output 'PASS: all 14 mastered audio families are present.' }
