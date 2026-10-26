# zw-ai

Eigene KI-Oberfläche als zentraler Hub, der später per **MCP** mit den zwe-Apps
(zwsite/Projekt-Tool, zw-Map, …) verbunden wird. Basis: **Open WebUI**,
ohne Docker über `uv` gestartet, mit austauschbarem Modell.

Leitgedanke: Das Modell ist austauschbar. Zum Entwickeln läuft ein **kostenloses
Gemini-Modell** über dessen OpenAI-kompatiblen Endpunkt; später wird in der
Oberfläche einfach eine andere Verbindung (Claude über Bedrock EU, Azure OpenAI …)
eingetragen – der Rest bleibt gleich.

## Stand / Fahrplan
- [x] Schritt 1: KI-Schicht lauffähig (Chat + kostenloses Modell) ← **hier**
- [ ] Schritt 2: MCP-Server der Apps anbinden (via `mcpo`-Proxy)
- [ ] Schritt 3: Nutzer-Rechte durchreichen (Login/SSO), Projekt-Wissensspeicher
- [ ] Schritt 4: Zielmodell final wählen und Prompts schärfen

## Voraussetzungen
- `uv` (installiert Python 3.11 selbst, kein root nötig):
  ```bash
  curl -LsSf https://astral.sh/uv/install.sh | sh
  source $HOME/.local/bin/env   # oder neue Shell öffnen
  ```
- Ein kostenloser **API-Key**, mind. einer von:
  - Gemini: https://aistudio.google.com/apikey
  - Groq: https://console.groq.com/keys

## Start
```bash
cp .env.example .env            # einmalig
# in .env eintragen: OPENAI_API_KEYS=<gemini>;<groq>  und  WEBUI_SECRET_KEY=$(openssl rand -hex 32)
bash scripts/start.sh
```
Dann http://localhost:8080 öffnen. Der **erste registrierte Nutzer wird Admin**.

### Windows (PowerShell)
```powershell
# uv einmalig installieren, danach Terminal neu starten:
powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"

Copy-Item .env.example .env   # einmalig, dann .env ausfüllen
# WEBUI_SECRET_KEY erzeugen:  python -c "import secrets; print(secrets.token_hex(32))"
powershell -ExecutionPolicy Bypass -File scripts\start.ps1
```

## Mehrere Anbieter (Gemini + Groq)
Open WebUI legt beim **ersten** Start je Eintrag in `OPENAI_API_BASE_URLS` /
`OPENAI_API_KEYS` eine Verbindung an und zeigt **alle Modelle gemeinsam im
Dropdown** – du wählst pro Chat, z. B. `gemini-3.8-flash` (Gemini) oder ein
Llama-Modell (Groq).

**Wichtiger Haken (persistente Konfiguration):** Verbindungen werden nach dem
ersten Start in `data/webui.db` gespeichert und haben dann **Vorrang vor der
.env**. Änderst du die Keys/URLs in der `.env` nachträglich, greifen sie nicht
automatisch. Dann entweder:
- die Verbindung direkt in **Avatar → Einstellungen → Admin → Verbindungen**
  anpassen/ergänzen, **oder**
- `data/` löschen (frischer Start – re-seeded aus der .env, aber Account/Chats weg).

Hinweis: Google schaltet ältere Modellnamen für neue Keys ab – bei einem 404
„no longer available" im Dropdown das aktuelle Flash-Modell wählen.

## Modell später austauschen
Nicht neu bauen – nur eine Verbindung ergänzen/ändern unter
**Admin → Verbindungen**:
- **Claude (Bedrock EU)** oder **Azure OpenAI**: jeweils als OpenAI-kompatible
  Verbindung (ggf. über ein LiteLLM-Gateway, das alle Anbieter vereinheitlicht).
Die Tool-fähigkeit (für MCP) muss das Zielmodell unterstützen – Gemini, GPT und
Claude tun das.

## Daten & Geheimnisses
- Alle Daten liegen in `./data` (SQLite) und sind gitignored.
- `.env` und `.webui_secret_key` werden nicht eingecheckt.

## Nächster Schritt: MCP (Schritt 2)
Open WebUI spricht MCP nicht direkt, sondern über den **`mcpo`**-Proxy, der einen
MCP-Server als OpenAPI-Tool bereitstellt, das Open WebUI als „Tool“ einbindet.
Grober Ablauf (wird in Schritt 2 ausgearbeitet):
```
Open WebUI ──(OpenAPI-Tool)──▶ mcpo ──(MCP)──▶ zwsite-MCP-Server ──▶ zwsite (gRPC/CQRS)
```
Wichtig dabei: Der MCP-Server greift **mit den Rechten des angemeldeten Nutzers**
auf die App zu, nicht als allmächtiger Service-Account.
