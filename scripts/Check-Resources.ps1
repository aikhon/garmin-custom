[CmdletBinding()]
param([string]$SdkPath = $env:CONNECTIQ_SDK_HOME)
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path $PSScriptRoot -Parent
if (!$SdkPath) { $SdkPath = Join-Path $projectRoot '.tools\connectiq-sdk' }
$schema = Join-Path $SdkPath 'bin\resources.xsd'
if (!(Test-Path -LiteralPath $schema)) { throw 'SDK resources.xsd not found; specify -SdkPath.' }
$files = @(Get-ChildItem -LiteralPath (Join-Path $projectRoot 'resources'), (Join-Path $projectRoot 'resources-amoled') -Filter '*.xml' -Recurse)
foreach ($file in $files) {
    $document = New-Object System.Xml.XmlDocument
    $document.Load($file.FullName)
    $null = $document.Schemas.Add('', $schema)
    $document.Validate($null)
    Write-Host "Valid resource XML: $($file.Name)"
}
$manifest = New-Object System.Xml.XmlDocument
$manifest.Load((Join-Path $projectRoot 'manifest.xml'))
Write-Host 'Manifest is well-formed XML. Device validation still requires installed Garmin profiles.'
