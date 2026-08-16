$ErrorActionPreference = 'Stop'

function Require-Admin {
    $id = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [System.Security.Principal.WindowsPrincipal]::new($id)
    if (-not $principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)) {
        throw 'Bitte diese Datei als Administrator ausfuehren.'
    }
}

Require-Admin

$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProxyDir = Join-Path $Root 'proxy'
$CertDir = Join-Path $ProxyDir 'certs'
$BackupDir = Join-Path $ProxyDir 'backups'
$HostsPath = Join-Path $env:WINDIR 'System32\drivers\etc\hosts'
$DnsName = 'l50.update.netease.com'
$PassPlain = 'ananta-local-proxy'

$Domains = @(
    'l50.update.netease.com',
    'l50.gph.netease.com',
    'l50.gsgph.netease.com',
    'service.mkey.163.com',
    'qatest.g.mkey.163.com',
    'qatest-1.g.mkey.163.com',
    'qatest-2.g.mkey.163.com',
    'qatest-3.g.mkey.163.com',
    'qatest-4.g.mkey.163.com',
    'qatest-5.g.mkey.163.com',
    'qatest-6.g.mkey.163.com',
    'qatest-7.g.mkey.163.com',
    'qatest-8.g.mkey.163.com',
    'bind-mobile.g.mkey.163.com',
    'bind-mobile-test.g.mkey.163.com',
    'mpay-common-server.g.mkey.163.com',
    'mpay-common-server-test.g.mkey.163.com',
    'mpay-personal-privacy-protection.g.mkey.163.com',
    'mpay-personal-privacy-protection-dev.g.mkey.163.com',
    'whoami.nie.netease.com',
    'whoami.nie.easebar.com',
    'protocol.unisdk.netease.com',
    'tpsl.nie.netease.com',
    'g0.gsf.netease.com',
    'g0.gsf.easebar.com',
    'mcount.easebar.com',
    'analytics.mpay.netease.com',
    'applog.matrix.netease.com',
    'applog.matrix.easebar.com',
    'mgbsdktest.matrix.netease.com',
    'dns.update.netease.com',
    'dns.update.easebar.com',
    'openapi.music.163.com'
)

New-Item -ItemType Directory -Force -Path $CertDir, $BackupDir | Out-Null

Write-Host '[1/3] Erzeuge lokales Proxy-Zertifikat...'
$notBefore = [DateTimeOffset]::Now.AddMinutes(-5)
$notAfter = [DateTimeOffset]::Now.AddDays(30)
$key = [System.Security.Cryptography.RSA]::Create(2048)
$subject = [System.Security.Cryptography.X509Certificates.X500DistinguishedName]::new("CN=$DnsName")
$request = [System.Security.Cryptography.X509Certificates.CertificateRequest]::new(
    $subject,
    $key,
    [System.Security.Cryptography.HashAlgorithmName]::SHA256,
    [System.Security.Cryptography.RSASignaturePadding]::Pkcs1
)

$san = [System.Security.Cryptography.X509Certificates.SubjectAlternativeNameBuilder]::new()
foreach ($domain in ($Domains + 'localhost' | Select-Object -Unique)) {
    $san.AddDnsName($domain)
}
$san.AddIpAddress([System.Net.IPAddress]::Parse('127.0.0.1'))
$request.CertificateExtensions.Add($san.Build())
$request.CertificateExtensions.Add(
    [System.Security.Cryptography.X509Certificates.X509BasicConstraintsExtension]::new($true, $false, 0, $true)
)
$request.CertificateExtensions.Add(
    [System.Security.Cryptography.X509Certificates.X509KeyUsageExtension]::new(
        [System.Security.Cryptography.X509Certificates.X509KeyUsageFlags]::DigitalSignature -bor
        [System.Security.Cryptography.X509Certificates.X509KeyUsageFlags]::KeyEncipherment -bor
        [System.Security.Cryptography.X509Certificates.X509KeyUsageFlags]::KeyCertSign,
        $true
    )
)
$eku = [System.Security.Cryptography.OidCollection]::new()
$null = $eku.Add([System.Security.Cryptography.Oid]::new('1.3.6.1.5.5.7.3.1'))
$request.CertificateExtensions.Add(
    [System.Security.Cryptography.X509Certificates.X509EnhancedKeyUsageExtension]::new($eku, $false)
)
$request.CertificateExtensions.Add(
    [System.Security.Cryptography.X509Certificates.X509SubjectKeyIdentifierExtension]::new($request.PublicKey, $false)
)

$cert = $request.CreateSelfSigned($notBefore, $notAfter)
$cert = [System.Security.Cryptography.X509Certificates.X509Certificate2]::new(
    $cert.Export([System.Security.Cryptography.X509Certificates.X509ContentType]::Pfx, $PassPlain),
    $PassPlain,
    [System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::Exportable
)

$CerPath = Join-Path $CertDir "$DnsName.cer"
$PfxPath = Join-Path $CertDir "$DnsName.pfx"
[System.IO.File]::WriteAllBytes($CerPath, $cert.Export([System.Security.Cryptography.X509Certificates.X509ContentType]::Cert))
[System.IO.File]::WriteAllBytes($PfxPath, $cert.Export([System.Security.Cryptography.X509Certificates.X509ContentType]::Pfx, $PassPlain))
& certutil.exe -addstore -f Root $CerPath | Out-Null

Write-Host '[2/3] Setze hosts-Eintraege auf 127.0.0.1...'
$backup = Join-Path $BackupDir ("hosts-before-ananta-{0}.txt" -f (Get-Date -Format 'yyyyMMdd-HHmmss'))
Copy-Item -LiteralPath $HostsPath -Destination $backup -Force

$lines = @(Get-Content -LiteralPath $HostsPath -ErrorAction SilentlyContinue)
$kept = foreach ($line in $lines) {
    $managed = $false
    foreach ($domain in $Domains) {
        if ($line -match "^\s*#?\s*127\.0\.0\.1\s+$([regex]::Escape($domain))(\s|$)") {
            $managed = $true
            break
        }
    }
    if (-not $managed) { $line }
}

$out = @($kept)
foreach ($domain in $Domains) {
    $out += "127.0.0.1 $domain # Ananta local proxy"
}
Set-Content -LiteralPath $HostsPath -Value $out -Encoding ASCII
ipconfig /flushdns | Out-Null

Write-Host '[3/3] Fertig.'
Write-Host "Zertifikat: $CerPath"
Write-Host "Hosts-Backup: $backup"
Write-Host 'Danach START_ALL.ps1 starten.'
