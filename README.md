# 🤖 LocalLLMChromebook

[![Engine](https://img.shields.io/badge/Engine-llama.cpp-0ea5e9)](https://github.com/ggml-org/llama.cpp)
[![Cloudflare Tunnel](https://img.shields.io/badge/Tunnel-Cloudflare-orange?logo=cloudflare)](https://developers.cloudflare.com/cloudflare-one/networks/connectors/cloudflare-tunnel/)
[![Platform](https://img.shields.io/badge/Platform-Chromebook%20Linux-lightgrey?logo=linux)](https://chromeos.dev/en/linux)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

> Lokale LLMs auf dem Chromebook mit **llama.cpp** und **Cloudflare Tunnel**.

<p align="center">
  <a href="https://github.com/jbkunama1/LocalLLMChromebook">
    <img src="https://user-gen-media-assets.s3.amazonaws.com/gpt4o_images/9cd004ea-32b8-48b4-afaf-a53c1c0fd029.png" alt="LocalLLMChromebook Logo" width="220">
  </a>
</p>

<p align="center">
  <a href="https://www.buymeacoffee.com/highfish" target="_blank">
    <img src="https://cdn.buymeacoffee.com/buttons/default-orange.png" width="170" height="40" alt="Buy me a coffee">
  </a>
</p>

---

## ✨ Features

- ⚙️ **llama.cpp** als leichter lokaler Inference-Server [cite:117][cite:121]
- 🌐 **llama-server** mit HTTP-API und Web-UI [cite:121]
- ☁️ **Cloudflare Tunnel** für sicheren externen Zugriff ohne Port-Forwarding [cite:9]
- 💻 Optimiert für **Chromebook + Linux (Crostini)**
- 📦 Fokus auf **kleine GGUF-Modelle**
- 🚀 Setup mit Build, Start und Tunnel-Konfiguration

---

## 🚀 Quick Start

Direktinstallation per Einzeiler:

```bash
curl -fsSL https://raw.githubusercontent.com/jbkunama1/LocalLLMChromebook/main/setup.sh -o setup.sh && chmod +x setup.sh && ./setup.sh
```

Danach läuft der Server standardmäßig lokal auf:

- llama.cpp Server: `http://localhost:8080`

Der offizielle Server von llama.cpp stellt eine leichte HTTP-Schnittstelle und eine Weboberfläche bereit. [cite:121]

---

## 📦 Stack

| Komponente | Zweck | Standard-Port |
|---|---|---:|
| `llama.cpp` | Lokale Inference Engine | - |
| `llama-server` | HTTP-API + Web-UI | `8080` |
| `cloudflared` | Sicherer Tunnel zu Cloudflare | - |

Cloudflare Tunnel erlaubt, lokale Dienste über Public Hostnames aus dem Dashboard erreichbar zu machen, ohne Router-Portfreigaben. [cite:9]

---

## 🧩 Architektur

```text
Chromebook (Linux / Crostini)
│
├── llama.cpp Build
├── GGUF-Modell
├── llama-server      → http://localhost:8080
└── cloudflared       → Cloudflare Tunnel
                         └── llm.deinedomain.de → localhost:8080
```

llama.cpp kann per CMake gebaut werden; der Server gehört offiziell zum Projekt und wird über die Server-Dokumentation beschrieben. [cite:110][cite:121]

---

## 🐧 Voraussetzungen

- Chromebook mit aktiviertem **Linux (Crostini)**
- Mindestens **4 GB RAM**, besser **8 GB**
- Internetverbindung
- Optional: eigene Domain bei Cloudflare

Für sehr schwache Geräte sind kleine **GGUF-Modelle** mit niedriger Quantisierung meist die praktikabelste Wahl. [cite:117]

---

## ⚙️ llama.cpp installieren

System vorbereiten:

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y git cmake build-essential curl wget python3 python3-pip
```

Repository klonen und bauen:

```bash
git clone https://github.com/ggml-org/llama.cpp
cd llama.cpp
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build -j
```

Die offizielle Build-Dokumentation beschreibt den CMake-Build als Standardweg. [cite:110]

---

## 🧠 Modell herunterladen

Für llama.cpp brauchst du ein **GGUF-Modell** im lokalen Dateisystem. Das Projekt arbeitet direkt mit GGUF-Dateien statt mit einer eigenen Modell-Bibliothek. [cite:117]

Beispielstruktur:

```bash
mkdir -p ~/models
# GGUF-Datei nach ~/models kopieren oder herunterladen
```

Empfehlung für kleine Geräte:

- `TinyLlama-1.1B-Chat` als GGUF
- kleine `SmolLM2 1.7B` GGUF-Varianten
- nach Möglichkeit `Q4_0`, `Q4_K_M` oder kleiner, wenn RAM knapp ist

GGUF ist das native Modellformat, das in llama.cpp verwendet wird. [cite:117]

---

## 🌐 llama-server starten

Server lokal starten:

```bash
cd ~/llama.cpp
./build/bin/llama-server -m ~/models/dein-modell.gguf --host 0.0.0.0 --port 8080 -c 1024 -ngl 0
```

Wichtige Parameter:

- `-m` → Pfad zum GGUF-Modell
- `--host 0.0.0.0` → Zugriff im lokalen Netz oder per Tunnel
- `--port 8080` → Webserver-Port
- `-c 1024` → kleinere Kontextgröße für schwache Geräte
- `-ngl 0` → keine GPU-Layer, passend für CPU-only Chromebook

Die Server-README dokumentiert die Serverargumente wie Host, Port und Threads. [cite:121]

---

## 🔌 API testen

```bash
curl http://localhost:8080/health
```

Oder im Browser:

```text
http://localhost:8080
```

llama-server bietet eine HTTP-API und eine Weboberfläche direkt im Server-Prozess. [cite:121]

---

## ☁️ cloudflared installieren

Architektur prüfen:

```bash
lscpu | grep "Architecture"
```

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
cloudflared --version
```

Die offiziellen Cloudflare-Downloads unterscheiden zwischen `amd64` und `arm64`. [cite:15]

---

## 🌐 Tunnel im Web einrichten

Cloudflare Dashboard:

1. Domain öffnen
2. **Zero Trust / One** → **Networks → Tunnels**
3. **Create a tunnel**
4. Betriebssystem **Debian** wählen
5. Installationsbefehl aus dem Dashboard auf dem Chromebook ausführen
6. **Public Hostname** anlegen

Beispiel:

```text
llm.deinedomain.de → http://localhost:8080
```

Cloudflare dokumentiert die Tunnel-Erstellung und Zuweisung von Public Hostnames in der Setup-Dokumentation. [cite:9]

---

## 🛠️ Systemd-Service

Beispiel für `/etc/systemd/system/llama.service`:

```ini
[Unit]
Description=llama.cpp Server
After=network.target

[Service]
Type=simple
ExecStart=/home/USERNAME/llama.cpp/build/bin/llama-server -m /home/USERNAME/models/dein-modell.gguf --host 0.0.0.0 --port 8080 -c 1024 -ngl 0
Restart=always

[Install]
WantedBy=multi-user.target
```

Ein vergleichbarer Systemd-Start für llama.cpp Server wird auch in Praxisbeispielen dokumentiert. [cite:115]

Danach:

```bash
sudo systemctl daemon-reload
sudo systemctl enable llama
sudo systemctl start llama
```

---



---

## ▶️ Startscript (llama.cpp)

Für den schnellen Start des Servers gibt es ein Startscript:

```bash
./start-llama.sh
```

Konfiguration im Script (Standardwerte):

```bash
MODEL_PATH="$HOME/models/tinyllama-1.1b-chat-v1.0.Q4_K_M.gguf"
CTX_SIZE=4096
THREADS=4
PORT=8080
LLM_API_KEY="sk-xxxxxxxx"
API_KEY_FILE="$HOME/.config/llama.cpp/api-keys.txt"
```

Das Script legt eine lokale API-Key-Datei an und startet `llama-server` mit `--api-key-file`, sodass OpenAI-kompatible Clients einen Bearer-Key mitsenden können. [cite:121][cite:154]

Beispiel für einen Testaufruf:

```bash
curl http://localhost:8080/health   -H "Authorization: Bearer sk-xxxxxxxx"
```

Den Pfad zum GGUF-Modell solltest du an deine Datei anpassen.

---

## 🛠️ Dateien im Repo

| Datei | Zweck |
|---|---|
| `README.md` | Vollständige Projektdokumentation |
| `INSTALL.md` | Kompakte Kurzinstallation |
| `setup.sh` | Setup-Script für llama.cpp |
| `index.html` / GitHub Pages | Projekt-Landingpage |

Die Repo-Dateien sind auf eine reine llama.cpp-Variante umgestellt. [cite:50][cite:51][cite:52]

---

## ❓ FAQ

### Warum kein Ollama mehr?

Wenn Modell-Tags, Startverhalten oder Ressourcenverbrauch in Ollama problematisch sind, ist llama.cpp oft der direktere und kontrollierbarere Weg. [cite:117]

### Brauche ich GGUF-Dateien?

Ja. llama.cpp arbeitet direkt mit GGUF-Modellen im Dateisystem. [cite:117]

### Kann ich den Server extern erreichbar machen?

Ja. Mit Cloudflare Tunnel kannst du `localhost:8080` auf eine Subdomain wie `llm.deinedomain.de` legen. [cite:9]

---

## ❤️ Support

<p align="center">
  <a href="https://www.buymeacoffee.com/highfish" target="_blank">
    <img src="https://cdn.buymeacoffee.com/buttons/default-orange.png" width="170" height="40" alt="Buy me a coffee">
  </a>
</p>

---

## 🔗 Links

- Repo: [LocalLLMChromebook](https://github.com/jbkunama1/LocalLLMChromebook)
- llama.cpp: [ggml-org/llama.cpp](https://github.com/ggml-org/llama.cpp)
- Cloudflare Tunnel Docs: [developers.cloudflare.com/tunnel/setup](https://developers.cloudflare.com/tunnel/setup/)
