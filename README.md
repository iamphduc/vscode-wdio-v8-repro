# vscode-webdriverio: worker crash on VS Code 1.144 (Electron 43)

Reproduces a bug in the WebdriverIO VS Code extension (0.4.2): the worker exits on start with
`Unable to deserialize cloned data due to invalid or unsupported version`, so the Testing panel
shows the config but no tests.

Tested with VS Code 1.144.0 (Electron 43.8.3), Node.js 26.13.0, Windows 11.

## Reproduce with the extension

1. `npm install`
2. Open this folder in VS Code 1.144 with the extension 0.4.2 installed.
3. Set `"webdriverio.logLevel": "debug"`, open the Testing panel, and wait about 1 minute.
4. `wdio.conf.js` shows no tests. The "WebdriverIO" output shows:
   ```
   [DEBUG] [Worker#1 stderr] node:v8:527
   Error: Unable to deserialize cloned data due to invalid or unsupported version.
   [DEBUG] Worker#1 process exited with code 1
   [ERROR] Failed to discover tests: [birpc] timeout on calling "loadWdioConfig"
   ```

## Reproduce the cause without the extension

The extension host (VS Code's Electron) and the worker (system Node.js) exchange messages with
`v8.serialize` / `v8.deserialize`. `repro-v8.ps1` writes a value with VS Code's V8 and reads it with
the system Node.js:

```powershell
.\repro-v8.ps1 "C:\path\to\Code.exe"
```

Result on my machine:
```
VS Code side: electron 43.8.3, node 24.22.1, v8 15.0.245.31-electron.0
VS Code side wrote 4 bytes: FF-10-49-02
Node side: node v26.13.0, v8 14.6.202.34-node.40
Error: Unable to deserialize cloned data due to invalid or unsupported version.
```

`FF 10` is the serializer header: format version 16. V8 14.6 (Node.js 26) can't read it.
