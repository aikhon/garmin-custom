[CmdletBinding()]
param([string]$SdkPath = $env:CONNECTIQ_SDK_HOME)
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path $PSScriptRoot -Parent
if (!$SdkPath) { $SdkPath = Join-Path $projectRoot '.tools\connectiq-sdk' }
$schema = Join-Path $SdkPath 'bin\resources.xsd'
if (!(Test-Path -LiteralPath $schema)) { throw 'SDK resources.xsd not found; specify -SdkPath.' }
$resourceDirectories = @(Get-ChildItem -LiteralPath $projectRoot -Directory | Where-Object { $_.Name -eq 'resources' -or $_.Name -like 'resources-*' } | Select-Object -ExpandProperty FullName)
$files = @(Get-ChildItem -LiteralPath $resourceDirectories -Filter '*.xml' -Recurse)
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
