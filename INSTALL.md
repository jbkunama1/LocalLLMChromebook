# INSTALL

Schnellinstallation für **LocalLLMChromebook** (Ollama + Open WebUI + Cloudflare Tunnel).

[![Made with Ollama](https://img.shields.io/badge/Powered%20by-Ollama-blue?logo=ollama&logoColor=white)](https://ollama.com)
[![Cloudflare Tunnel](https://img.shields.io/badge/Tunnel-Cloudflare-orange?logo=cloudflare)](https://developers.cloudflare.com/cloudflare-one/networks/connectors/cloudflare-tunnel/)
[![Open WebUI](https://img.shields.io/badge/UI-Open%20WebUI-9cf?logo=react)](https://github.com/open-webui/open-webui)

---

## 1. System vorbereiten

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl wget git build-essential python3 python3-pip python3-venv
```

## 2. Ollama installieren

```bash
curl -fsSL https://ollama.com/install.sh | sh
ollama --version
```

## 3. Modell laden

```bash
ollama pull qwen2.5:3b
ollama run qwen2.5:3b "Hallo Chromebook!"
```

## 4. Open WebUI installieren

```bash
mkdir -p ~/open-webui && cd ~/open-webui
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install open-webui
open-webui serve
```

## 5. Open WebUI verbinden

```text
Backend: Ollama
URL:     http://localhost:11434
```

## 6. cloudflared installieren

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

## 7. Tunnel installieren

```bash
sudo cloudflared service install <DEIN-TUNNEL-TOKEN>
```

## 8. Hostnames

```text
ollama.deinedomain.de → http://localhost:11434
chat.deinedomain.de   → http://localhost:8080
```

## 9. Dienste aktivieren

```bash
sudo systemctl enable ollama
sudo systemctl start ollama
sudo systemctl enable cloudflared
sudo systemctl start cloudflared
```

## 10. Einzeiler

```bash
curl -fsSL https://raw.githubusercontent.com/jbkunama1/LocalLLMChromebook/main/setup.sh -o setup.sh && chmod +x setup.sh && ./setup.sh
```

---

<p align="center">
  <a href="https://www.buymeacoffee.com/highfish" target="_blank">
    <img src="https://cdn.buymeacoffee.com/buttons/default-orange.png" width="170" height="40" alt="Buy me a coffee">
  </a>
</p>
