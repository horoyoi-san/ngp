$ErrorActionPreference = 'Stop'

$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProxyDir = Join-Path $Root 'proxy'
$PfxPath = Join-Path $ProxyDir 'certs\l50.update.netease.com.pfx'

if (-not (Test-Path $PfxPath)) {
    throw 'Proxy-Zertifikat fehlt. Einmal SETUP_PROXY_AS_ADMIN.ps1 als Administrator ausfuehren.'
}

$NodeExe = $env:ANANTA_NODE_EXE
if (-not $NodeExe) {
    $cmd = Get-Command node -ErrorAction SilentlyContinue
    if ($cmd) { $NodeExe = $cmd.Source }
}
if (-not $NodeExe) {
    foreach ($candidate in @(
        (Join-Path $Root 'tools\node\node.exe'),
        'C:\Program Files\nodejs\node.exe'
    )) {
        if (Test-Path $candidate) { $NodeExe = $candidate; break }
    }
}
if (-not $NodeExe) {
    throw 'node.exe nicht gefunden. Node.js LTS installieren oder ANANTA_NODE_EXE setzen.'
}

New-Item -ItemType Directory -Force -Path (Join-Path $ProxyDir 'logs') | Out-Null
Set-Location $ProxyDir

Write-Host "Proxy startet mit: $NodeExe"
Write-Host 'Ports: 80, 443, 5801, 5803, 5804, 8013'
& $NodeExe 'server.js'
