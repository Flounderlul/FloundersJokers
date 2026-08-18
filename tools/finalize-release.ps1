$ErrorActionPreference = 'Stop'

$secureKey = Read-Host 'ElevenLabs API key (input hidden)' -AsSecureString
$keyPointer = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureKey)

try {
    $env:ELEVENLABS_API_KEY = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($keyPointer)
    if (-not $env:ELEVENLABS_API_KEY) { throw 'No API key was entered.' }

    & (Join-Path $PSScriptRoot 'generate-elevenlabs-sfx.ps1') -Force
    if ($LASTEXITCODE -ne 0) { throw 'Sound generation failed.' }

    & (Join-Path $PSScriptRoot 'qa-release.ps1')
    if ($LASTEXITCODE -ne 0) { throw 'Strict release QA failed.' }

    & (Join-Path $PSScriptRoot 'package-release.ps1')
    if ($LASTEXITCODE -ne 0) { throw 'Packaging failed.' }
}
finally {
    Remove-Item Env:ELEVENLABS_API_KEY -ErrorAction SilentlyContinue
    [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($keyPointer)
    $secureKey = $null
}
