[CmdletBinding()]
param([string]$OpenSsl = 'C:\Program Files\Git\usr\bin\openssl.exe')
$ErrorActionPreference = 'Stop'
$keyDir = Join-Path (Split-Path $PSScriptRoot -Parent) '.secrets'
$keyPath = Join-Path $keyDir 'developer_key.der'
if (Test-Path -LiteralPath $keyPath) { Write-Host 'Existing signing key retained.'; return }
if (!(Test-Path -LiteralPath $OpenSsl)) { throw 'Pass -OpenSsl with the path to openssl.exe, or generate a key using the Monkey C VS Code extension.' }
New-Item -ItemType Directory -Force -Path $keyDir | Out-Null
& $OpenSsl genrsa -out (Join-Path $keyDir 'developer_key.pem') 4096
if ($LASTEXITCODE -ne 0) { throw 'RSA key generation failed.' }
& $OpenSsl pkcs8 -topk8 -inform PEM -outform DER -in (Join-Path $keyDir 'developer_key.pem') -out $keyPath -nocrypt
if ($LASTEXITCODE -ne 0) { throw 'Key conversion failed.' }
Write-Host 'Created local signing key in .secrets. Back it up privately; reuse it for future releases.'
