# 🤖 Local LLM auf dem Chromebook – Ollama + Cloudflare Tunnel

[![Made with Ollama](https://img.shields.io/badge/Powered%20by-Ollama-blue?logo=ollama&logoColor=white)](https://ollama.com)
[![Cloudflare Tunnel](https://img.shields.io/badge/Tunnel-Cloudflare-orange?logo=cloudflare)](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/)
[![Platform](https://img.shields.io/badge/Platform-Chromebook%20Linux-lightgrey?logo=linux)](https://chromeos.dev/en/linux)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Buy Me A Coffee](https://img.shields.io/badge/Buy%20me%20a%20coffee-☕-yellow)](https://buymeacoffee.com/DEINNAME)

> Lokales LLM (Large Language Model) auf einem Chromebook betreiben und sicher über das Internet via Cloudflare Tunnel erreichbar machen – **kein Port-Forwarding, kein festes IP nötig**.

---

## 📋 Inhaltsverzeichnis

- [Voraussetzungen](#-voraussetzungen)
- [Schritt 1: Linux auf Chromebook aktivieren](#-schritt-1-linux-auf-chromebook-aktivieren)
- [Schritt 2: Ollama installieren](#-schritt-2-ollama-installieren)
- [Schritt 3: Modell herunterladen](#-schritt-3-modell-herunterladen)
- [Schritt 4: Ollama als Server starten](#-schritt-4-ollama-als-server-starten)
- [Schritt 5: cloudflared installieren](#-schritt-5-cloudflared-installieren)
- [Schritt 6: Cloudflare Tunnel einrichten](#-schritt-6-cloudflare-tunnel-einrichten)
- [Schritt 7: Autostart konfigurieren](#-schritt-7-autostart-konfigurieren)
- [Modell-Empfehlungen](#-modell-empfehlungen)
- [Troubleshooting](#-troubleshooting)

---

## ✅ Voraussetzungen

- Chromebook mit **Linux (Crostini)** aktiviert
- Mindestens **4 GB RAM** (8 GB empfohlen)
- Domain bei **Cloudflare** (auch kostenlos nutzbar)
- Internetverbindung

---

## 🐧 Schritt 1: Linux auf Chromebook aktivieren

1. Einstellungen → **Erweitert** → **Entwickler**
2. „Linux-Entwicklungsumgebung" → **Aktivieren**
3. Speicher: mindestens **10 GB** vergeben
4. Terminal öffnen und System aktualisieren:

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl wget git build-essential
```

---

## 🦙 Schritt 2: Ollama installieren

```bash
curl -fsSL https://ollama.com/install.sh | sh
```

Installation prüfen:

```bash
ollama --version
# ollama version is X.X.X
```

> 💡 Ollama installiert sich automatisch als Systemdienst und ist nach Neustart sofort verfügbar.

---

## 📦 Schritt 3: Modell herunterladen

### Empfohlene Modelle nach RAM

| Modell | RAM-Bedarf | Qualität | Befehl |
|--------|-----------|----------|--------|
| `gemma3:2b` | ~2 GB | ⭐⭐⭐ | `ollama pull gemma3:2b` |
| `qwen2.5:3b` | ~2.3 GB | ⭐⭐⭐⭐ | `ollama pull qwen2.5:3b` |
| `llama3.2:3b` | ~2.5 GB | ⭐⭐⭐⭐ | `ollama pull llama3.2:3b` |
| `phi3:mini` | ~2.3 GB | ⭐⭐⭐ | `ollama pull phi3:mini` |
| `mistral:7b` | ~5 GB | ⭐⭐⭐⭐⭐ | `ollama pull mistral:7b` |

**Für 4 GB RAM → `qwen2.5:3b` empfohlen:**

```bash
ollama pull qwen2.5:3b
```

Modell testen:

```bash
ollama run qwen2.5:3b "Erkläre mir Photosynthese in 3 Sätzen."
```

---

## 🖥️ Schritt 4: Ollama als Server starten

Ollama läuft standardmäßig als API-Server auf Port `11434`:

```bash
# Status prüfen
systemctl status ollama

# Manuell starten (falls nötig)
ollama serve
```

API testen:

```bash
curl http://localhost:11434/api/generate \
  -d '{"model": "qwen2.5:3b", "prompt": "Hallo!", "stream": false}'
```

OpenAI-kompatible API (z.B. für Open WebUI):
http://localhost:11434/v1/chat/completions

text

---

## ☁️ Schritt 5: cloudflared installieren

### Architektur ermitteln

```bash
lscpu | grep "Architecture"
# x86_64 → amd64 | aarch64 → arm64
```

### Installation (x86_64 / amd64)

```bash
# Paketquelle hinzufügen
curl -L --output cloudflared.deb \
  https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
sudo dpkg -i cloudflared.deb
cloudflared --version
```

### Installation (ARM / aarch64)

```bash
curl -L --output cloudflared.deb \
  https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm64.deb
sudo dpkg -i cloudflared.deb
```

---

## 🌐 Schritt 6: Cloudflare Tunnel einrichten

### 6a) Dashboard-Methode (empfohlen für Einsteiger)

1. 🔗 Öffne: **[dash.cloudflare.com](https://dash.cloudflare.com)**
2. Navigiere zu: **Networking → Tunnels → Create a tunnel**
3. Tunnelname vergeben (z.B. `chromebook-llm`)
4. Betriebssystem wählen: **Debian** → Architektur wählen
5. Den angezeigten Installationsbefehl **direkt kopieren und ausführen** – dieser enthält bereits deinen Token!

```bash
# Beispiel (dein Token wird im Dashboard generiert):
sudo cloudflared service install eyJhIjoiXXXXXXX...
```

6. Im Dashboard: **Public Hostname** hinzufügen:
   - **Subdomain:** `llm`
   - **Domain:** `deinedomain.de`
   - **Service:** `http://localhost:11434`
7. ✅ Speichern → Tunnel ist aktiv!

### 6b) CLI-Methode (für Fortgeschrittene)

```bash
# Authentifizieren (öffnet Browser)
cloudflared tunnel login

# Tunnel erstellen
cloudflared tunnel create chromebook-llm

# Konfiguration anlegen
mkdir -p ~/.cloudflared
nano ~/.cloudflared/config.yml
```

Inhalt `config.yml`:

```yaml
tunnel: chromebook-llm
credentials-file: /home/DEINUSER/.cloudflared/<TUNNEL-ID>.json

ingress:
  - hostname: llm.deinedomain.de
    service: http://localhost:11434
  - service: http_status:404
```

```bash
# DNS-Eintrag erstellen
cloudflared tunnel route dns chromebook-llm llm.deinedomain.de

# Tunnel testen
cloudflared tunnel run chromebook-llm
```

---

## ⚙️ Schritt 7: Autostart konfigurieren

### Ollama (läuft bereits als Systemdienst)

```bash
sudo systemctl enable ollama
sudo systemctl start ollama
```

### Cloudflared als Systemdienst

```bash
sudo cloudflared service install
sudo systemctl enable cloudflared
sudo systemctl start cloudflared
```

Status beider Dienste prüfen:

```bash
systemctl status ollama cloudflared
```

---

## 🧠 Modell-Empfehlungen
┌─────────────────────────────────────────────────┐
│ RAM │ Empfohlenes Modell │ Tokens/Sek (CPU) │
├────────┼────────────────────┼───────────────────┤
│ 4 GB │ qwen2.5:3b │ 3–5 tok/s │
│ 8 GB │ mistral:7b │ 2–4 tok/s │
│ 16 GB │ llama3.1:8b │ 3–5 tok/s │
└─────────────────────────────────────────────────┘

text

> ⚠️ **Tipp:** Immer Q4-quantisierte Modelle verwenden – volle Qualität bei halben RAM-Bedarf!

---

## 🛠️ Troubleshooting

### Ollama startet nicht

```bash
journalctl -u ollama -n 50
sudo systemctl restart ollama
```

### Cloudflared Tunnel verbindet nicht

```bash
cloudflared tunnel info chromebook-llm
journalctl -u cloudflared -n 50
```

### Modell zu langsam

- Kleineres Modell wählen (z.B. `gemma3:2b` statt `mistral:7b`)
- Hintergrundprozesse beenden: `htop`
- Swap deaktivieren/erhöhen: `sudo swapon --show`

### API nicht erreichbar von außen

```bash
# Tunnel-Status im Dashboard prüfen:
# dash.cloudflare.com → Networking → Tunnels
# Sollte "Healthy" anzeigen
```

---

## 📚 Weiterführende Links

- 📖 [Ollama Dokumentation](https://github.com/ollama/ollama)
- 🌐 [Cloudflare Tunnel Docs](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/)
- 🤗 [Hugging Face GGUF Modelle](https://huggingface.co/models?library=gguf)
- 💬 [Open WebUI (Chat-Interface für Ollama)](https://github.com/open-webui/open-webui)

---

<div align="center">

Wenn dir dieses Projekt hilft, freue ich mich über einen Kaffee ☕

[![Buy Me A Coffee](https://img.shields.io/badge/Buy%20Me%20A%20Coffee-☕%20Support-yellow?style=for-the-badge&logo=buymeacoffee)](https://buymeacoffee.com/DEINNAME)

**Made with ❤️ in Karlsruhe**

</div>
