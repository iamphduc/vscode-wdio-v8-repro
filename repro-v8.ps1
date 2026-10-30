# The cause without the extension: write a value with VS Code's V8, read it with the system Node.js.
# Usage: .\repro-v8.ps1 "C:\path\to\Code.exe"
param([Parameter(Mandatory)][string]$Code)
Set-Location $PSScriptRoot
Remove-Item data.bin, electron.txt -ErrorAction SilentlyContinue

# Write with VS Code's V8 (Electron runs as Node.js). Code.exe can't write to a pipe, so it writes files.
$env:ELECTRON_RUN_AS_NODE = '1'
$js = "const fs=require('fs');fs.writeFileSync('data.bin',require('v8').serialize(1));fs.writeFileSync('electron.txt','electron '+process.versions.electron+', node '+process.versions.node+', v8 '+process.versions.v8)"
Start-Process -FilePath $Code -ArgumentList '-e', "`"$js`"" -Wait -NoNewWindow
Remove-Item Env:ELECTRON_RUN_AS_NODE
"VS Code side: $(Get-Content electron.txt)"
"VS Code side wrote $((Get-Item data.bin).Length) bytes: $([BitConverter]::ToString([IO.File]::ReadAllBytes("$PSScriptRoot\data.bin")))"

# Read with the system Node.js
"Node side: node $(node --version), v8 $(node -p process.versions.v8)"
node -e "try { console.log('read OK:', require('v8').deserialize(require('fs').readFileSync('data.bin'))) } catch (e) { console.log('Error:', e.message) }"
