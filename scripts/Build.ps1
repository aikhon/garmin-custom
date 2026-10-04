[CmdletBinding()]
param(
    [ValidateSet('fr255','fr265','fr965','all')][string]$Device = 'all',
    [string]$SdkPath = $env:CONNECTIQ_SDK_HOME,
    [string]$DeveloperKey = $env:CONNECTIQ_DEVELOPER_KEY,
    [switch]$Release,
    [switch]$TestBuild
)
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path $PSScriptRoot -Parent
if (!$SdkPath) { $SdkPath = Join-Path $projectRoot '.tools\connectiq-sdk' }
$compiler = Join-Path $SdkPath 'bin\monkeyc.bat'
if (!(Test-Path -LiteralPath $compiler)) { throw 'SDK not found. Set CONNECTIQ_SDK_HOME to your SDK directory; see README.md.' }
if (!$DeveloperKey) { $DeveloperKey = Join-Path $projectRoot '.secrets\developer_key.der' }
if (!(Test-Path -LiteralPath $DeveloperKey)) { throw 'Signing key missing. Run scripts/New-DeveloperKey.ps1 or set CONNECTIQ_DEVELOPER_KEY.' }
$devices = if ($Device -eq 'all') { @('fr255','fr265','fr965') } else { @($Device) }
$outDir = Join-Path $projectRoot 'bin'
New-Item -ItemType Directory -Force -Path $outDir | Out-Null
Push-Location $projectRoot
try {
    foreach ($target in $devices) {
        $suffix = if ($TestBuild) { '-tests' } elseif ($Release) { '-release' } else { '' }
        $output = Join-Path $outDir "runclub-$target$suffix.prg"
        $jungle = if ($TestBuild) { 'tests.jungle' } else { 'monkey.jungle' }
        $arguments = @('-f', $jungle, '-d', $target, '-o', $output, '-y', $DeveloperKey, '-w', '-l', '2')
        if ($Release) { $arguments += '-r' }
        if ($TestBuild) { $arguments += '-t' }
        & $compiler @arguments
        if ($LASTEXITCODE -ne 0) { throw "Build failed for $target (exit $LASTEXITCODE)." }
        Write-Host "Built $output"
    }
} finally { Pop-Location }
