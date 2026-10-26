# Startet Open WebUI lokal über uv unter Windows (PowerShell).
# Liest ..\.env. Beenden mit Strg+C.
# Start:  powershell -ExecutionPolicy Bypass -File scripts\start.ps1
$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

if (-not (Test-Path ".env")) {
    Write-Error "Keine .env gefunden. Erst:  Copy-Item .env.example .env  und ausfüllen."
    exit 1
}

# .env laden (Zeilen name=wert, # und Leerzeilen überspringen)
Get-Content ".env" | ForEach-Object {
    $line = $_.Trim()
    if ($line -eq "" -or $line.StartsWith("#")) { return }
    $idx = $line.IndexOf("=")
    if ($idx -lt 1) { return }
    $name = $line.Substring(0, $idx).Trim()
    $value = $line.Substring($idx + 1).Trim()
    Set-Item -Path "Env:$name" -Value $value
}

if (-not $env:OPENAI_API_KEYS) {
    Write-Error "OPENAI_API_KEYS fehlt in .env (Gemini/Groq-Keys, ';'-getrennt)."
    exit 1
}

if (-not (Get-Command uvx -ErrorAction SilentlyContinue)) {
    Write-Error "uv/uvx nicht gefunden. Installieren:  powershell -ExecutionPolicy ByPass -c `"irm https://astral.sh/uv/install.ps1 | iex`"  (danach Terminal neu starten)"
    exit 1
}

$port = if ($env:PORT) { $env:PORT } else { "8080" }
Write-Host "Open WebUI startet auf http://localhost:$port  (Daten in $($env:DATA_DIR))"
# Python 3.11, weil Open WebUI 3.13 noch nicht unterstützt.
uvx --python 3.11 open-webui@latest serve --port $port
