[CmdletBinding()]
param(
    [ValidateSet('fr55','fr165','fr255','fr255sm','fr265','fr965','fr970')][string]$Device = 'fr265',
    [string]$SdkPath = $env:CONNECTIQ_SDK_HOME,
    [switch]$Tests
)
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path $PSScriptRoot -Parent
if (!$SdkPath) { $SdkPath = Join-Path $projectRoot '.tools\connectiq-sdk' }
$suffix = if ($Tests) { '-tests' } else { '' }
$program = Join-Path $projectRoot "bin\runclub-$Device$suffix.prg"
if (!(Test-Path -LiteralPath $program)) { throw 'Build this target first using scripts/Build.ps1.' }
if (!(Get-Process -Name simulator -ErrorAction SilentlyContinue)) {
    # This is an interactive simulator explicitly requested by this command.
    Start-Process -FilePath (Join-Path $SdkPath 'bin\simulator.exe')
    Start-Sleep -Seconds 3
}
$arguments = @($program, $Device)
if ($Tests) { $arguments += '/t' }
& (Join-Path $SdkPath 'bin\monkeydo.bat') @arguments
if ($LASTEXITCODE -ne 0) { throw "Simulator exited with code $LASTEXITCODE." }
