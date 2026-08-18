param([switch]$Force)

$ErrorActionPreference = 'Stop'

$apiKey = $env:ELEVENLABS_API_KEY
if (-not $apiKey) {
    $apiKey = [Environment]::GetEnvironmentVariable('ELEVENLABS_API_KEY', 'User')
}
if (-not $apiKey) {
    throw 'Set ELEVENLABS_API_KEY in the environment before running this script.'
}

$ffmpeg = (Get-Command ffmpeg -ErrorAction Stop).Source
$workspace = Split-Path -Parent $PSScriptRoot
$outputDir = Join-Path $workspace 'assets/sounds'
New-Item -ItemType Directory -Force -Path $outputDir | Out-Null

$common = 'Premium polished video-game UI sound, dry close mix, mono-compatible, no speech, no music, no ambience, no sub-bass, no long reverb, no clipping.'
$prompts = [ordered]@{
    arcana = "Short airy playing-card flick followed by one restrained glass glint. $common"
    stone = "Compact smooth mineral knock with a tiny low crystalline tail, weighty but quiet. $common"
    weapon = "Muted fantasy mechanical snap and precise metal tick, deliberately not a realistic gunshot. $common"
    coin = "One soft casino token landing on felt with a clean tiny metallic settle, no cascade. $common"
    gem = "Short faceted gemstone shimmer with a warm tactile body and one clean sparkle. $common"
    echo = "Two quiet identical scoring taps in exact rhythm, the second slightly softer, no delay wash. $common"
    transform = "Very short rising paper-to-glass magical morph sweep ending in a delicate click. $common"
    conjure = "Small dimensional pop with a single playing-card flutter and soft magical settle. $common"
    dice = "One twenty-sided die rolling briefly across casino felt and settling with a satisfying precise click. $common"
    cursed = "One twenty-sided die reverse-rattling on felt with a brief ominous low sting, controlled and subtle. $common"
    deck = "One premium card deck placed on casino felt, a soft leather-and-paper landing with a restrained brass corner tick and no shuffle cascade. $common"
    voucher = "A tactile wax seal pressed into paper followed by one compact precision brass mechanism click, luxurious and restrained. $common"
    blind = "A short boss warning cue: low carved-stone impact, tight brass lock snap, and one dim marquee pulse, tense but not loud. $common"
    challenge = "A concise mastery-complete flourish: one bright glass curio glint, soft casino token settle, and confident paper-card lift, celebratory without melody. $common"
}

$headers = @{ 'xi-api-key' = $apiKey; 'Content-Type' = 'application/json' }
$endpoint = 'https://api.elevenlabs.io/v1/sound-generation?output_format=mp3_44100_128'

foreach ($entry in $prompts.GetEnumerator()) {
    $oggPath = Join-Path $outputDir ($entry.Key + '.ogg')
    if ((Test-Path -LiteralPath $oggPath) -and -not $Force) {
        Write-Output "Keeping existing $($entry.Key).ogg"
        continue
    }
    $tempPath = Join-Path ([System.IO.Path]::GetTempPath()) ("fj-$($entry.Key)-$([guid]::NewGuid().ToString('N')).mp3")
    try {
        $body = @{ text = $entry.Value; duration_seconds = 0.9; prompt_influence = 0.45; model_id = 'eleven_text_to_sound_v2' } | ConvertTo-Json
        Invoke-WebRequest -Uri $endpoint -Method Post -Headers $headers -Body $body -OutFile $tempPath | Out-Null
        & $ffmpeg -hide_banner -loglevel error -y -i $tempPath -af 'highpass=f=90,lowpass=f=12000,loudnorm=I=-22:LRA=5:TP=-2' -ac 2 -ar 44100 $oggPath
        if ($LASTEXITCODE -ne 0) { throw "ffmpeg failed for $($entry.Key)" }

        # Short, high-crest-factor cues can hit the true-peak ceiling before
        # one-pass loudnorm reaches its body-loudness target. Measure the render
        # and lift only those outliers into a non-auto-gaining limiter.
        $measure = (& $ffmpeg -hide_banner -nostats -i $oggPath -filter_complex 'ebur128=peak=true' -f null NUL 2>&1) -join "`n"
        $integratedMatches = [regex]::Matches($measure, 'I:\s+(-?\d+(?:\.\d+)?)\s+LUFS')
        if ($integratedMatches.Count) {
            $integrated = [double]$integratedMatches[$integratedMatches.Count - 1].Groups[1].Value
            if ($integrated -lt -24.5) {
                $gain = [math]::Round(-22.0 - $integrated, 1)
                $repairPath = Join-Path $outputDir ('.fj-' + $entry.Key + '-repair.ogg')
                try {
                    & $ffmpeg -hide_banner -loglevel error -y -i $oggPath -af "volume=${gain}dB,alimiter=limit=0.794:attack=5:release=50:level=false" -ac 2 -ar 44100 $repairPath
                    if ($LASTEXITCODE -ne 0) { throw "short-cue repair failed for $($entry.Key)" }
                    Move-Item -LiteralPath $repairPath -Destination $oggPath -Force
                }
                finally {
                    if (Test-Path -LiteralPath $repairPath) { Remove-Item -LiteralPath $repairPath -Force }
                }
            }
        }
        Write-Output "Generated $($entry.Key).ogg"
    }
    finally {
        if (Test-Path -LiteralPath $tempPath) { Remove-Item -LiteralPath $tempPath -Force }
    }
}
