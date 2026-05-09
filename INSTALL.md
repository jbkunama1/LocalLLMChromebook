# INSTALL

Schnellinstallation für **LocalLLMChromebook** mit **llama.cpp** und **Cloudflare Tunnel**.

[![Engine](https://img.shields.io/badge/Engine-llama.cpp-0ea5e9)](https://github.com/ggml-org/llama.cpp)
[![Cloudflare Tunnel](https://img.shields.io/badge/Tunnel-Cloudflare-orange?logo=cloudflare)](https://developers.cloudflare.com/cloudflare-one/networks/connectors/cloudflare-tunnel/)

---

## 1. System vorbereiten

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y git cmake build-essential curl wget python3 python3-pip
```

## 2. llama.cpp klonen und bauen

```bash
git clone https://github.com/ggml-org/llama.cpp
cd llama.cpp
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build -j
```

## 3. Modellordner anlegen

```bash
mkdir -p ~/models
```

## 4. llama-server starten

```bash
cd ~/llama.cpp
./build/bin/llama-server -m ~/models/dein-modell.gguf --host 0.0.0.0 --port 8080 -c 1024 -ngl 0
```

## 5. cloudflared installieren

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

## 6. Tunnel installieren

```bash
sudo cloudflared service install <DEIN-TUNNEL-TOKEN>
```

## 7. Hostname

```text
llm.deinedomain.de → http://localhost:8080
```

## 8. Einzeiler

```bash
curl -fsSL https://raw.githubusercontent.com/jbkunama1/LocalLLMChromebook/main/setup.sh -o setup.sh && chmod +x setup.sh && ./setup.sh
```

---

<p align="center">
  <a href="https://www.buymeacoffee.com/highfish" target="_blank">
    <img src="https://cdn.buymeacoffee.com/buttons/default-orange.png" width="170" height="40" alt="Buy me a coffee">
  </a>
</p>


## 9. Startscript

```bash
chmod +x start-llama.sh
./start-llama.sh
```

Optionaler Test mit Dummy-Key:

```bash
curl http://localhost:8080/health   -H "Authorization: Bearer sk-xxxxxxxx"
```
