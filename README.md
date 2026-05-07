# 🤖 ChromeLLM – Lokale KI auf dem Chromebook (Ollama + Open WebUI + Cloudflare Tunnel)

[![Made with Ollama](https://img.shields.io/badge/Powered%20by-Ollama-blue?logo=ollama&logoColor=white)](https://ollama.com)
[![Cloudflare Tunnel](https://img.shields.io/badge/Tunnel-Cloudflare-orange?logo=cloudflare)](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/)
[![Open WebUI](https://img.shields.io/badge/UI-Open%20WebUI-9cf?logo=react)](https://github.com/open-webui/open-webui)
[![Platform](https://img.shields.io/badge/Platform-Chromebook%20Linux-lightgrey?logo=linux)](https://chromeos.dev/en/linux)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

> Lokales LLM (Large Language Model) auf einem Chromebook betreiben, mit **Ollama** als Backend, **Open WebUI** als Chat-Oberfläche und sicherem Zugriff über **Cloudflare Tunnel** – ideal für Experimente, Side‑Projects und Self‑Hosted KI.

<p align="center">
  <a href="https://www.buymeacoffee.com/highfish" target="_blank">
    <img src="https://cdn.buymeacoffee.com/buttons/default-orange.png" width="170" height="40" alt="Buy me a coffee">
  </a>
</p>

---

## 📋 Inhaltsverzeichnis

- [Voraussetzungen](#-voraussetzungen)
- [Schritt 1: Linux auf Chromebook aktivieren](#-schritt-1-linux-auf-chromebook-aktivieren)
- [Schritt 2: Ollama installieren](#-schritt-2-ollama-installieren)
- [Schritt 3: Modell herunterladen](#-schritt-3-modell-herunterladen)
- [Schritt 4: Ollama als Server starten](#-schritt-4-ollama-als-server-starten)
- [Schritt 5: cloudflared installieren](#-schritt-5-cloudflared-installieren)
- [Schritt 6: Cloudflare Tunnel einrichten](#-schritt-6-cloudflare-tunnel-einrichten)
- [Schritt 7: Open WebUI installieren](#-schritt-7-open-webui-installieren)
- [Schritt 8: Open WebUI mit Ollama verbinden](#-schritt-8-open-webui-mit-ollama-verbinden)
- [Schritt 9: Open WebUI extern erreichbar machen](#-schritt-9-open-webui-extern-erreichbar-machen)
- [Modell-Empfehlungen](#-modell-empfehlungen)
- [Troubleshooting](#-troubleshooting)

---

## ✅ Voraussetzungen

- Chromebook mit **Linux (Crostini)** aktiviert  
- Mindestens **4 GB RAM** (8 GB empfohlen)  
- Domain bei **Cloudflare** (kostenloser Plan reicht) [web:9]  
- Internetverbindung  

---

## 🐧 Schritt 1: Linux auf Chromebook aktivieren

1. Einstellungen → **Erweitert** → **Entwickler**
2. „Linux-Entwicklungsumgebung" → **Aktivieren**
3. Speicher: mindestens **10 GB** vergeben
4. Terminal öffnen und System aktualisieren:

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl wget git build-essential python3 python3-pip
```

---

## 🦙 Schritt 2: Ollama installieren

```bash
curl -fsSL https://ollama.com/install.sh | sh
```

Version prüfen:

```bash
ollama --version
```

Ollama wird als Systemdienst registriert und automatisch gestartet. [web:5]

---

## 📦 Schritt 3: Modell herunterladen

### Empfohlene Modelle nach RAM

| Modell        | RAM-Bedarf | Qualität | Befehl                     |
|--------------|-----------:|---------:|----------------------------|
| `gemma3:2b`  |   ~2 GB    |     ⭐⭐⭐  | `ollama pull gemma3:2b`    |
| `qwen2.5:3b` |  ~2.3 GB   |    ⭐⭐⭐⭐  | `ollama pull qwen2.5:3b`   |
| `llama3.2:3b`|  ~2.5 GB   |    ⭐⭐⭐⭐  | `ollama pull llama3.2:3b`  |
| `phi3:mini`  |  ~2.3 GB   |     ⭐⭐⭐  | `ollama pull phi3:mini`    |
| `mistral:7b` |    ~5 GB   |   ⭐⭐⭐⭐⭐  | `ollama pull mistral:7b`   |

Für 4 GB RAM:

```bash
ollama pull qwen2.5:3b
```

Test:

```bash
ollama run qwen2.5:3b "Erkläre mir kurz, was ein Chromebook ist."
```

---

## 🖥️ Schritt 4: Ollama als Server starten

Ollama läuft als API auf Port `11434`. [web:22]

Status:

```bash
systemctl status ollama
```

API testen:

```bash
curl http://localhost:11434/api/generate \
  -d '{"model": "qwen2.5:3b", "prompt": "Hallo!", "stream": false}'
```

---

## ☁️ Schritt 5: cloudflared installieren

Architektur prüfen:

```bash
lscpu | grep "Architecture"
x86_64 → amd64 | aarch64 → arm64
text

### x86_64 / amd64

```bash
curl -L --output cloudflared.deb \
  https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
sudo dpkg -i cloudflared.deb
cloudflared --version
```

### ARM / aarch64

```bash
curl -L --output cloudflared.deb \
  https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm64.deb
sudo dpkg -i cloudflared.deb
```

Downloads siehe Cloudflare-Doku. [web:15]

---

## 🌐 Schritt 6: Cloudflare Tunnel einrichten (Ollama-API)

### Dashboard-Methode (einfach)

1. **[dash.cloudflare.com](https://dash.cloudflare.com)** → Domain wählen  
2. **Zero Trust / One** → **Networks → Tunnels → Create a tunnel** [web:9]  
3. Tunnelname: z.B. `chromebook-ollama`  
4. OS: **Debian** → Architektur wählen  
5. Den im Dashboard angezeigten Befehl kopieren und ausführen (enthält Token):

```bash
Beispiel – dein echter Befehl kommt aus dem Dashboard:
sudo cloudflared service install eyJhIjoiXXXXXX...

text

6. Im Dashboard: **Public Hostname** hinzufügen  
   - Subdomain: `ollama`  
   - Domain: `deinedomain.de`  
   - Service: `http://localhost:11434`  

Jetzt ist die Ollama-API unter `https://ollama.deinedomain.de` erreichbar. [web:9]

---

## 🧊 Schritt 7: Open WebUI installieren

Python-Installation ohne Docker (ressourcenschonend) laut Open-WebUI-Doku. [web:19][web:23]

```bash
Projektordner
mkdir -p ~/open-webui && cd ~/open-webui

Virtuelle Umgebung
python3 -m venv venv
source venv/bin/activate

Open WebUI installieren
pip install --upgrade pip
pip install open-webui

text

Starten:

```bash
open-webui serve
```

Standard-Port:

- Web-UI: `http://localhost:8080` [web:19]

---

## 💬 Schritt 8: Open WebUI mit Ollama verbinden

1. Browser öffnen: `http://localhost:8080`  
2. Admin-User anlegen  
3. Settings → **Connections / Backends** [web:26]  
4. Backend: **Ollama**  
5. URL auf:

```text
http://localhost:11434
```

setzen.  
6. Speichern und in Open WebUI z.B. `qwen2.5:3b` auswählen.

---

## 🌍 Schritt 9: Open WebUI extern erreichbar machen

Im gleichen Tunnel einen zweiten Hostname hinzufügen. [web:34]

- `ollama.deinedomain.de` → `http://localhost:11434`  
- `chat.deinedomain.de` → `http://localhost:8080`  

Über das Cloudflare-Dashboard:

1. Tunnel öffnen  
2. **Public Hostnames → Add**  
3. Subdomain `chat`, Service `http://localhost:8080`  

Optional: Cloudflare Access davor schalten (Zero-Trust-Login). [web:9]

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

---

## 🛠️ Troubleshooting

**Open WebUI startet nicht**

```bash
source venv/bin/activate
open-webui serve --host 0.0.0.0 --port 8080
```

**Open WebUI findet Ollama nicht**

```bash
curl http://localhost:11434/api/tags
```

Wenn das funktioniert: URL in Open WebUI auf `http://localhost:11434` stellen.

**Cloudflared Tunnel ist „unhealthy"**

```bash
systemctl status cloudflared
journalctl -u cloudflared -n 50
```

---

<p align="center">
  <a href="https://www.buymeacoffee.com/highfish" target="_blank">
    <img src="https://cdn.buymeacoffee.com/buttons/default-orange.png" width="170" height="40" alt="Buy me a coffee">
  </a>
</p>

<p align="center"><sub>Made with ❤️ on a Chromebook.</sub></p>
**Made with ❤️ in Karlsruhe**

