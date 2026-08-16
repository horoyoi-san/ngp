ANANTA PROXY PACK
Date: 2026-06-11

Included
- proxy\                         local update/login/scene proxy
- SETUP_PROXY_AS_ADMIN.ps1       creates a local certificate and updates hosts
- Start-Proxy.ps1                starts only the proxy
- REMOVE_PROXY_HOSTS_AS_ADMIN.ps1 removes the hosts entries again
- CHECK_PORTS.ps1                shows the proxy listener ports

Not included
- No game files.
- No C# game server.

Requirements
- Windows x64
- Node.js installed, or set ANANTA_NODE_EXE to the full path of node.exe.

One-time setup on the target PC
1. Open PowerShell as Administrator.
2. Change into this folder.
3. Run:
   powershell -ExecutionPolicy Bypass -File .\SETUP_PROXY_AS_ADMIN.ps1

Start the proxy
1. Open PowerShell.
2. Change into this folder.
3. Run:
   powershell -ExecutionPolicy Bypass -File .\Start-Proxy.ps1

Proxy ports
- 80
- 443
- 5801
- 5803
- 5804
- 8013

Cleanup
Run this as Administrator:
   powershell -ExecutionPolicy Bypass -File .\REMOVE_PROXY_HOSTS_AS_ADMIN.ps1

Troubleshooting
- Check listener ports:
   powershell -ExecutionPolicy Bypass -File .\CHECK_PORTS.ps1
- If the proxy says the certificate is missing, run SETUP_PROXY_AS_ADMIN.ps1 again as Administrator.
- If port 80 or 443 is already in use, close the conflicting process and start the proxy again.
