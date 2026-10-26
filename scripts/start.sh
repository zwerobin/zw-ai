#!/usr/bin/env bash
# Startet Open WebUI lokal über uv – ohne Docker, im User-Space.
# Liest die Konfiguration aus ../.env. Beenden mit Strg+C.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

if [ ! -f .env ]; then
  echo "Keine .env gefunden. Erst anlegen:  cp .env.example .env  und ausfüllen." >&2
  exit 1
fi

# .env laden (alle Zuweisungen exportieren)
set -a; . ./.env; set +a

if [ -z "${OPENAI_API_KEYS:-}" ]; then
  echo "OPENAI_API_KEYS fehlt in .env (Gemini/Groq-Keys, ';'-getrennt)." >&2
  exit 1
fi

if ! command -v uvx >/dev/null 2>&1; then
  echo "uv/uvx nicht gefunden. Einmalig installieren:" >&2
  echo "  curl -LsSf https://astral.sh/uv/install.sh | sh" >&2
  echo "danach neue Shell öffnen oder:  source \$HOME/.local/bin/env" >&2
  exit 1
fi

echo "Open WebUI startet auf http://localhost:${PORT:-8080}  (Daten in ${DATA_DIR:-./data})"
# Python 3.11, weil Open WebUI 3.13 noch nicht unterstützt.
exec uvx --python 3.11 open-webui@latest serve --port "${PORT:-8080}"
