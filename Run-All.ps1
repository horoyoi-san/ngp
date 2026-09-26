$ErrorActionPreference = 'Stop'
$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$ConfigPath = Join-Path $Root 'config\private-server.json'
$ProxyRoot = Join-Path $Root 'Ananta.Proxy'
$ProxyDir = Join-Path $ProxyRoot 'proxy'
$ServerProject = Join-Path $Root 'Ananta.Server\Ananta.App\Ananta.App.csproj'
$HostsPath = Join-Path $env:WINDIR 'System32\drivers\etc\hosts'

$script:ConsoleLogLatest = $null
$script:ConsoleLogArchive = $null

function Append-RunLog([string]$Text) {
    if (-not $script:ConsoleLogLatest) { return }
    $line = $Text + [Environment]::NewLine
    try { [System.IO.File]::AppendAllText($script:ConsoleLogLatest, $line, [System.Text.UTF8Encoding]::new($false)) } catch { }
    try { [System.IO.File]::AppendAllText($script:ConsoleLogArchive, $line, [System.Text.UTF8Encoding]::new($false)) } catch { }
}

function Status([string]$Text, [System.ConsoleColor]$Color = [System.ConsoleColor]::Gray) {
    Microsoft.PowerShell.Utility\Write-Host $Text -ForegroundColor $Color
    Append-RunLog $Text
}

function Fail([string]$Text) {
    Status "[ERROR] $Text" Red
    if ($script:ConsoleLogLatest) { Status "[LOG] $script:ConsoleLogLatest" DarkGray }
    exit 1
}

function ConvertFrom-JsonWithComments([string]$Text, [string]$SourceName) {
    $sb = New-Object System.Text.StringBuilder
    $inString = $false
    $escaped = $false
    $stripped = 0
    for ($i = 0; $i -lt $Text.Length; $i++) {
        $c = $Text[$i]
        if ($inString) {
            [void]$sb.Append($c)
            if ($escaped) { $escaped = $false }
            elseif ($c -eq '\') { $escaped = $true }
            elseif ($c -eq '"') { $inString = $false }
            continue
        }
        if ($c -eq '"') { $inString = $true; [void]$sb.Append($c); continue }
        if ($c -eq '/' -and ($i + 1) -lt $Text.Length -and $Text[$i + 1] -eq '/') {
            while ($i -lt $Text.Length -and $Text[$i] -ne "`n" -and $Text[$i] -ne "`r") { $i++ }
            $stripped++
            continue
        }
        if ($c -eq '/' -and ($i + 1) -lt $Text.Length -and $Text[$i + 1] -eq '*') {
            $i += 2
            while (($i + 1) -lt $Text.Length -and -not ($Text[$i] -eq '*' -and $Text[$i + 1] -eq '/')) { $i++ }
            $i++
            $stripped++
            continue
        }
        [void]$sb.Append($c)
    }
    if ($stripped -gt 0) {
        Status "[WARN] $SourceName 里有 $stripped 处 JSON 注释（C# 侧允许，PowerShell/Node 不允许）——已自动剥除。建议改到 docs 里。" Yellow
    }
    return ($sb.ToString() | ConvertFrom-Json)
}

function Test-AnantaAdministrator {
    $id = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object System.Security.Principal.WindowsPrincipal($id)
    return $principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Find-Exe([string]$EnvName, [string]$CommandName, [string[]]$Fallbacks = @()) {
    $fromEnv = [Environment]::GetEnvironmentVariable($EnvName)
    if ($fromEnv -and (Test-Path -LiteralPath $fromEnv)) { return $fromEnv }
    $cmd = Get-Command $CommandName -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }
    foreach ($candidate in $Fallbacks) {
        if ($candidate -and (Test-Path -LiteralPath $candidate)) { return $candidate }
    }
    return $null
}

function Quote-WindowsProcessArgument([string]$Value) {
    if ($null -eq $Value) { return '""' }
    if ($Value -notmatch '[\s"]') { return $Value }
    $escaped = [System.Text.RegularExpressions.Regex]::Replace($Value, '(\\*)"', '$1$1\\"')
    $escaped = [System.Text.RegularExpressions.Regex]::Replace($escaped, '(\\+)$', '$1$1')
    return '"' + $escaped + '"'
}

function Invoke-SilentNative {
    param([string]$FilePath, [string[]]$Arguments, [string]$WorkingDirectory)
    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = $FilePath
    $psi.WorkingDirectory = if ($WorkingDirectory) { $WorkingDirectory } else { $Root }
    $psi.UseShellExecute = $false
    $psi.CreateNoWindow = $true
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true
    $utf8 = New-Object System.Text.UTF8Encoding($false)
    try { $psi.StandardOutputEncoding = $utf8 } catch { }
    try { $psi.StandardErrorEncoding = $utf8 } catch { }
    $psi.Arguments = (($Arguments | ForEach-Object { Quote-WindowsProcessArgument ([string]$_) }) -join ' ')

    $process = New-Object System.Diagnostics.Process
    $process.StartInfo = $psi
    if (-not $process.Start()) { return 1 }
    $stdoutTask = $process.StandardOutput.ReadToEndAsync()
    $stderrTask = $process.StandardError.ReadToEndAsync()
    $process.WaitForExit()
    foreach ($text in @($stdoutTask.Result, $stderrTask.Result)) {
        if ([string]::IsNullOrWhiteSpace($text)) { continue }
        foreach ($line in ($text -split "`r?`n")) {
            if ($line.Length -gt 0) { Append-RunLog $line }
        }
    }
    return $process.ExitCode
}

function Stop-StaleAnantaProcesses {
    foreach ($proc in @(Get-Process -Name 'Ananta.App' -ErrorAction SilentlyContinue)) {
        try { Stop-Process -Id $proc.Id -Force -ErrorAction SilentlyContinue } catch { }
    }
    try {
        $proxyServerJs = [System.IO.Path]::GetFullPath((Join-Path $ProxyDir 'server.js'))
        foreach ($proc in @(Get-CimInstance Win32_Process -Filter "Name='node.exe'" -ErrorAction SilentlyContinue)) {
            $cmd = [string]$proc.CommandLine
            if ($cmd -and ($cmd.IndexOf($proxyServerJs, [System.StringComparison]::OrdinalIgnoreCase) -ge 0)) {
                try { Stop-Process -Id $proc.ProcessId -Force -ErrorAction SilentlyContinue } catch { }
            }
        }
    } catch { }
    Start-Sleep -Milliseconds 200
}

if (-not (Test-AnantaAdministrator)) {
    $psExe = Join-Path $PSHOME 'powershell.exe'
    if (-not (Test-Path -LiteralPath $psExe)) { $psExe = 'powershell.exe' }
    try {
        $elevated = Start-Process -FilePath $psExe -Verb RunAs -ArgumentList ('-NoLogo -NoProfile -ExecutionPolicy Bypass -File "' + $PSCommandPath + '"') -WorkingDirectory $Root -Wait -PassThru
        exit $elevated.ExitCode
    } catch {
        Microsoft.PowerShell.Utility\Write-Host "[ERROR] administrator launch failed: $($_.Exception.Message)" -ForegroundColor Red
        exit 1
    }
}

$ExampleConfigPath = Join-Path $Root 'config\private-server.example.json'
foreach ($required in @(
    $ServerProject,
    (Join-Path $ProxyDir 'server.js'),
    (Join-Path $ProxyDir 'package.json'),
    (Join-Path $ProxyDir 'tools\generate_client_config_patch.js'),
    $ExampleConfigPath,
    (Join-Path $Root 'Ananta.Server\ClientData\4229938\MethodIds.json'),
    (Join-Path $Root 'Ananta.Server\ClientData\4229938\RpcSurface.json')
)) {
    if (-not (Test-Path -LiteralPath $required)) { Fail "server package is incomplete: $required" }
}

if (-not (Test-Path -LiteralPath $ConfigPath)) {
    Copy-Item -LiteralPath $ExampleConfigPath -Destination $ConfigPath
}
try { $Config = ConvertFrom-JsonWithComments (Get-Content -Raw -Encoding UTF8 -LiteralPath $ConfigPath) 'config/private-server.json' }
catch {
    
    
    $hint = 'invalid config/private-server.json: ' + $_.Exception.Message
    $hint += '  —— 这份文件同时被 C# 服务端 / Node 代理 / 本脚本解析。'
    $hint += '  // 注释这里会自动剥除，但缺逗号、多逗号、/* 没闭合仍然会失败。'
    $hint += '  校验命令: python -c "import json,io;json.load(io.open(''config/private-server.json'',encoding=''utf-8-sig''))"'
    Fail $hint
}

$RunId = Get-Date -Format 'yyyyMMdd-HHmmss'
$LogDir = [string]$Config.logging.directory
if ([string]::IsNullOrWhiteSpace($LogDir)) { $LogDir = 'logs' }
if (-not [System.IO.Path]::IsPathRooted($LogDir)) { $LogDir = Join-Path $Root $LogDir }
$LogDir = [System.IO.Path]::GetFullPath($LogDir)
[System.IO.Directory]::CreateDirectory($LogDir) | Out-Null
$ConsoleLoggingEnabled = [bool]$Config.logging.console.enabled
$PacketLoggingEnabled = [bool]$Config.logging.packets.enabled
$script:ConsoleLogLatest = $null
$script:ConsoleLogArchive = $null

if ($ConsoleLoggingEnabled) {
    $script:ConsoleLogLatest = Join-Path $LogDir 'console-latest.log'
    $script:ConsoleLogArchive = Join-Path $LogDir ("console-{0}.log" -f $RunId)
    foreach ($file in @($script:ConsoleLogLatest, $script:ConsoleLogArchive)) {
        [System.IO.File]::WriteAllText($file, '', [System.Text.UTF8Encoding]::new($false))
    }
    $env:Ananta_CONSOLE_LOG_LATEST = $script:ConsoleLogLatest
    $env:Ananta_CONSOLE_LOG_ARCHIVE = $script:ConsoleLogArchive
} else {
    Remove-Item Env:Ananta_CONSOLE_LOG_LATEST -ErrorAction SilentlyContinue
    Remove-Item Env:Ananta_CONSOLE_LOG_ARCHIVE -ErrorAction SilentlyContinue
}

$PacketLogLatest = $null
$PacketLogArchive = $null
if ($PacketLoggingEnabled) {
    $PacketLogLatest = Join-Path $LogDir 'packets-latest.log'
    $PacketLogArchive = Join-Path $LogDir ("packets-{0}.log" -f $RunId)
    foreach ($file in @($PacketLogLatest, $PacketLogArchive)) {
        [System.IO.File]::WriteAllText($file, '', [System.Text.UTF8Encoding]::new($false))
    }
    $env:Ananta_PACKET_LOG_LATEST = $PacketLogLatest
    $env:Ananta_PACKET_LOG_ARCHIVE = $PacketLogArchive
} else {
    Remove-Item Env:Ananta_PACKET_LOG_LATEST -ErrorAction SilentlyContinue
    Remove-Item Env:Ananta_PACKET_LOG_ARCHIVE -ErrorAction SilentlyContinue
}
$env:Ananta_RUN_ID = $RunId
$env:Ananta_LOG_DIR = $LogDir
$env:Ananta_LOGS_PREPARED = '1'

$consoleDisplay = if ($ConsoleLoggingEnabled) { $script:ConsoleLogLatest } else { 'disabled' }
$packetDisplay = if ($PacketLoggingEnabled) { $PacketLogLatest } else { 'disabled' }
Append-RunLog '[START] launching standalone bootstrap...'
Append-RunLog ("[LOGS] console={0} | packets={1}" -f $consoleDisplay, $packetDisplay)
Append-RunLog ("[BUILD] Ananta Private Server | client {0} | world-entry + switching + buffs/combat" -f $Config.client.version)
Append-RunLog "[CONFIG] $ConfigPath"
Append-RunLog "[CONFIG] pid=$($Config.player.pid) spirit=$($Config.player.initialSpiritTemplateId) raid=$($Config.world.raidId)"

$env:Ananta_CONFIG = $ConfigPath
$env:Ananta_ROOT = $Root
$env:Ananta_COMPACT_LOG = '1'
$env:Ananta_HIDE_BOOT_LOG = '1'
Remove-Item Env:Ananta_QUIET_CONSOLE -ErrorAction SilentlyContinue
$env:DOTNET_CLI_UI_LANGUAGE = 'en-US'
$env:DOTNET_NOLOGO = '1'
$env:DOTNET_CLI_TELEMETRY_OPTOUT = '1'
$env:DOTNET_SKIP_FIRST_TIME_EXPERIENCE = '1'

$NodeExe = Find-Exe 'Ananta_NODE_EXE' 'node' @('C:\Program Files\nodejs\node.exe')
if (-not $NodeExe) { Fail 'Node.js was not found. Install Node.js LTS.' }
$DotnetExe = Find-Exe 'Ananta_DOTNET_EXE' 'dotnet'
if (-not $DotnetExe) { Fail '.NET 8 SDK was not found.' }

$FengariPackage = Join-Path $ProxyDir 'node_modules\fengari\package.json'
if (-not (Test-Path -LiteralPath $FengariPackage)) {
    $NpmExe = Find-Exe 'Ananta_NPM_EXE' 'npm.cmd' @((Join-Path (Split-Path -Parent $NodeExe) 'npm.cmd'))
    if (-not $NpmExe) { Fail 'Node dependencies are missing and npm.cmd was not found.' }
    if ((Invoke-SilentNative $NpmExe @('ci', '--ignore-scripts', '--no-audit', '--no-fund') $ProxyDir) -ne 0) {
        Fail 'npm dependency restore failed'
    }
}
if (-not (Test-Path -LiteralPath $FengariPackage)) { Fail 'fengari dependency is missing.' }
Append-RunLog '[NODE] exact Lua serializer dependency OK (fengari)'

Stop-StaleAnantaProcesses

$DnsName = [string]$Config.network.proxy.updateHost
$PfxPath = Join-Path $ProxyDir ("certs\{0}.pfx" -f $DnsName)
$PfxPassphrase = [string]$Config.network.proxy.certificatePassphrase

$RequiredProxyDomains = @(
    $DnsName,
    'serverlist-test.l50.leihuo.netease.com',
    'l50.gdl.netease.com',
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
    'mgbsdk.matrix.netease.com',
    'mgbsdk.matrix.easebar.com',
    'dns.update.netease.com',
    'dns.update.easebar.com',
    'openapi.music.163.com'
) | Select-Object -Unique

$hostsOk = Test-Path -LiteralPath $HostsPath
if ($hostsOk) {
    $hostLines = @(Get-Content -LiteralPath $HostsPath -ErrorAction SilentlyContinue)
    foreach ($domain in $RequiredProxyDomains) {
        $pattern = '^\s*127\.0\.0\.1\s+' + [regex]::Escape($domain) + '(?:\s|$)'
        if (-not ($hostLines | Where-Object { $_ -match $pattern })) {
            $hostsOk = $false
            break
        }
    }
}

$certOk = $false
if (Test-Path -LiteralPath $PfxPath) {
    try {
        $pfx = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($PfxPath, $PfxPassphrase)
        
        
        $certOk = (
            $pfx.NotAfter -gt (Get-Date).AddHours(1) -and
            $pfx.Subject -eq ("CN={0}" -f $DnsName) -and
            $pfx.Issuer -eq 'CN=Ananta Local Proxy Root'
        )
        $pfx.Dispose()
    } catch { $certOk = $false }
}
if (-not $certOk -or -not $hostsOk) {
    Append-RunLog '[PROXY] repairing certificate/hosts redirects for login services'
    $setupScript = Join-Path $ProxyRoot 'SETUP_PROXY_AS_ADMIN.ps1'
    if (-not (Test-Path -LiteralPath $setupScript)) { Fail 'proxy setup script is missing' }
    if ((Invoke-SilentNative 'powershell.exe' @('-NoLogo', '-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $setupScript) $Root) -ne 0) {
        Fail 'certificate/hosts setup failed'
    }
}

$hostLines = @(Get-Content -LiteralPath $HostsPath -ErrorAction SilentlyContinue)
foreach ($domain in @('serverlist-test.l50.leihuo.netease.com','l50.gdl.netease.com','service.mkey.163.com','mgbsdk.matrix.netease.com')) {
    $pattern = '^\s*127\.0\.0\.1\s+' + [regex]::Escape($domain) + '(?:\s|$)'
    if (-not ($hostLines | Where-Object { $_ -match $pattern })) {
        Fail "local proxy redirect is missing for $domain"
    }
}

Append-RunLog '[1/3] fastpatch + startup checks'
if ((Invoke-SilentNative $NodeExe @('.\tools\generate_client_config_patch.js') $ProxyDir) -ne 0) {
    Fail 'fastpatch generation failed'
}
$FastPatchPath = Join-Path $ProxyDir ("public\fastpatch_{0}.zip" -f $Config.client.version)
$RuntimeFastPatchRoot = [string]$Config.paths.runtimeFastpatch
if (-not [System.IO.Path]::IsPathRooted($RuntimeFastPatchRoot)) { $RuntimeFastPatchRoot = Join-Path $Root $RuntimeFastPatchRoot }
$FastPatchSource = Join-Path $RuntimeFastPatchRoot ([string]$Config.client.version)
try {
    Add-Type -AssemblyName System.IO.Compression.FileSystem -ErrorAction SilentlyContinue
    $temp = "$FastPatchPath.tmp"
    if (Test-Path -LiteralPath $temp) { Remove-Item -LiteralPath $temp -Force }
    [System.IO.Compression.ZipFile]::CreateFromDirectory($FastPatchSource, $temp, [System.IO.Compression.CompressionLevel]::Optimal, $false)
    if (Test-Path -LiteralPath $FastPatchPath) { Remove-Item -LiteralPath $FastPatchPath -Force }
    Move-Item -LiteralPath $temp -Destination $FastPatchPath
} catch { Fail "cannot build fastpatch: $($_.Exception.Message)" }

Append-RunLog '[2/3] build (clean)'
$cleanDirs = @(Get-ChildItem -LiteralPath (Join-Path $Root 'Ananta.Server') -Directory -Recurse -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -in @('bin','obj') } | Select-Object -ExpandProperty FullName)
$cleanDirs += @((Join-Path $Root 'Ananta.SDK\bin'), (Join-Path $Root 'Ananta.SDK\obj'))
foreach ($dir in $cleanDirs | Select-Object -Unique) {
    if (Test-Path -LiteralPath $dir) { Remove-Item -LiteralPath $dir -Recurse -Force }
}
if ((Invoke-SilentNative $DotnetExe @('build', $ServerProject, '--nologo', '-v:q') $Root) -ne 0) {
    Fail 'server build failed'
}

Append-RunLog '[2.5/3] audit polymorphic typemarks'
$auditScript = Join-Path $Root 'tools\audit_polymorphic.py'
if ($env:Ananta_SKIP_AUDIT -eq '1') {
    
    Append-RunLog '  [WARN] Ananta_SKIP_AUDIT=1，跳过审计'
} elseif (-not (Test-Path -LiteralPath $auditScript)) {
    Append-RunLog '  [WARN] tools/audit_polymorphic.py 不存在，跳过审计'
} else {
    $py = Find-Exe 'Ananta_PYTHON_EXE' 'python'
    if (-not $py) { $py = Find-Exe 'Ananta_PYTHON_EXE' 'py' }
    if (-not $py) { $py = Find-Exe 'Ananta_PYTHON_EXE' 'python3' }
    if (-not $py) {
        
        $fallback = Join-Path $env:USERPROFILE '.workbuddy-ai\binaries\python\versions\3.13.12\python.exe'
        if (Test-Path -LiteralPath $fallback) { $py = $fallback }
    }
    if (-not $py) {
        Append-RunLog '  [WARN] 找不到 python，跳过审计'
    } else {
        $auditLog = Join-Path $LogDir ("polymorphic-audit-{0}.log" -f $RunId)
        $auditRc = $null
        $auditLines = @()
        $prevEap = $ErrorActionPreference
        $prevEnc = $env:PYTHONIOENCODING
        try {
            $ErrorActionPreference = 'Continue'          
            $env:PYTHONIOENCODING = 'utf-8'              
            $auditRaw = & $py $auditScript --strict 2>&1
            $auditRc = $LASTEXITCODE
            $auditLines = @($auditRaw | ForEach-Object { $_.ToString() })
        } catch {
            Append-RunLog ("  [WARN] 审计脚本无法运行: " + $_.Exception.Message)
        } finally {
            $ErrorActionPreference = $prevEap
            $env:PYTHONIOENCODING = $prevEnc
        }

        if ($auditLines.Count -gt 0) {
            $auditLines | Set-Content -LiteralPath $auditLog -Encoding UTF8
        }

        
        
        
        $auditCrashed = ($auditLines | Where-Object {
            $_ -match 'Traceback \(most recent call last\)' -or $_ -match 'SyntaxError' -or $_ -match '^\s*File "'
        }).Count -gt 0

        if ($auditRc -eq 1 -and -not $auditCrashed) {
            foreach ($line in $auditLines) { Append-RunLog ("  " + $line) }
            Fail "polymorphic TypeMark audit found problems (see $auditLog) —— 契约里的多态标记会让客户端反序列化失败（卡加载/黑屏/退回登录）。确实要跳过就设 Ananta_SKIP_AUDIT=1"
        } elseif ($auditRc -eq 1) {
            Append-RunLog ("  [WARN] 审计脚本自己崩了（输出里有 Traceback），跳过。输出见 " + $auditLog)
            foreach ($line in ($auditLines | Select-Object -First 6)) {
                Append-RunLog ("    | " + $line)
            }
        } elseif ($auditRc -eq 0) {
            Append-RunLog ("  OK (log: " + $auditLog + ")")
        } elseif ($null -eq $auditRc) {
            Append-RunLog '  [WARN] 审计进程没有启动（输出为空），跳过'
        } else {
            Append-RunLog ("  [WARN] 审计脚本自身出错 (exit=" + $auditRc + ")，跳过。输出见 " + $auditLog)
            foreach ($line in ($auditLines | Select-Object -First 5)) {
                Append-RunLog ("    | " + $line)
            }
        }
    }
}

$wantedPorts = @(
    [int]$Config.network.proxy.httpPort,
    [int]$Config.network.proxy.httpsPort,
    [int]$Config.network.proxy.loginListPort,
    [int]$Config.network.proxy.loginTcpPort,
    [int]$Config.network.proxy.gameTcpPort,
    [int]$Config.network.proxy.sceneSubPort,
    [int]$Config.network.loginPorts[0],
    [int]$Config.network.loginPorts[1],
    [int]$Config.network.gamePort
) | Select-Object -Unique
try {
    $busy = @(Get-NetTCPConnection -State Listen -ErrorAction SilentlyContinue | Where-Object { $wantedPorts -contains $_.LocalPort })
    if ($busy.Count -gt 0) {
        $desc = ($busy | Sort-Object LocalPort -Unique | ForEach-Object { ":$($_.LocalPort) pid=$($_.OwningProcess)" }) -join ', '
        Fail "ports already in use: $desc"
    }
} catch { }

Append-RunLog '[3/3] start'
Append-RunLog '[OK] one console | Ctrl+C stops the stack'

try { Clear-Host } catch { }
try { $Host.UI.RawUI.WindowTitle = 'Ananta 4229938 Private Server' } catch { }

$proxy = $null
$serverExit = 0
try {
    $proxy = Start-Process -FilePath $NodeExe -ArgumentList @('server.js') -WorkingDirectory $ProxyDir -NoNewWindow -PassThru
    Start-Sleep -Milliseconds 500
    if ($proxy.HasExited) { Fail "proxy exited with code $($proxy.ExitCode)" }

    & $DotnetExe run --no-build --project $ServerProject
    $serverExit = $LASTEXITCODE
} finally {
    if ($proxy -and -not $proxy.HasExited) {
        try { Stop-Process -Id $proxy.Id -Force -ErrorAction SilentlyContinue } catch { }
    }
    Stop-StaleAnantaProcesses
    Append-RunLog '[STOP] Ananta stack stopped'
}
if ($serverExit -ne 0) { exit $serverExit }
