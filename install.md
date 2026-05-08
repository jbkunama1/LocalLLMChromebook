# INSTALL

Schnellinstallation für LocalLLMChromebook (Ollama + Open WebUI + Cloudflare Tunnel).

---

## 1. System vorbereiten (Chromebook Linux / Crostini)

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl wget git build-essential python3 python3-pip python3-venv
```

---

## 2. Ollama installieren

```bash
curl -fsSL https://ollama.com/install.sh | sh
ollama --version
```

---

## 3. Modell laden und testen

```bash
ollama pull qwen2.5:3b
ollama run qwen2.5:3b "Hallo Chromebook!"
```

---

## 4. Open WebUI installieren (ohne Docker)

```bash
mkdir -p ~/open-webui && cd ~/open-webui
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install open-webui
open-webui serve
```

---

## 5. Open WebUI mit Ollama verbinden

In Open WebUI:

```text
Backend: Ollama
URL:     http://localhost:11434
```

---

## 6. cloudflared installieren

```bash
lscpu | grep "Architecture"
# x86_64 → amd64 / aarch64 → arm64
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

---

## 7. Cloudflare Tunnel installieren (Befehl aus Dashboard)

Cloudflare Dashboard → Zero Trust / One → Networks → Tunnels → Create tunnel → Debian:

```bash
sudo cloudflared service install <DEIN-TUNNEL-TOKEN>
```

---

## 8. Hostnames (Beispiel)

Im Cloudflare-Dashboard (Public Hostnames):

```text
ollama.deinedomain.de → http://localhost:11434
chat.deinedomain.de   → http://localhost:8080
```

---

## 9. Dienste aktivieren

```bash
sudo systemctl enable ollama
sudo systemctl start ollama

sudo systemctl enable cloudflared
sudo systemctl start cloudflared
```
