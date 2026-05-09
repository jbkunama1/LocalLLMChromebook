#!/usr/bin/env bash
set -euo pipefail

echo "[1/6] System aktualisieren"
sudo apt update && sudo apt upgrade -y
sudo apt install -y git cmake build-essential curl wget python3 python3-pip

echo "[2/6] llama.cpp klonen"
if [ ! -d "$HOME/llama.cpp" ]; then
  git clone https://github.com/ggml-org/llama.cpp "$HOME/llama.cpp"
fi

echo "[3/6] llama.cpp bauen"
cd "$HOME/llama.cpp"
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build -j

echo "[4/6] Modellordner und API-Key-Ordner anlegen"
mkdir -p "$HOME/models"
mkdir -p "$HOME/.config/llama.cpp"

echo "[5/6] Dummy-API-Key-Datei anlegen"
printf '%s\n' 'sk-xxxxxxxx' > "$HOME/.config/llama.cpp/api-keys.txt"
chmod 600 "$HOME/.config/llama.cpp/api-keys.txt"

echo "[6/6] Fertig"
echo "Lege jetzt eine GGUF-Datei nach $HOME/models"
echo "Empfohlen: tinyllama-1.1b-chat-v1.0.Q4_K_M.gguf"
echo "Beispiel mit Hugging Face Repo:"
echo "  hieupt/TinyLlama-1.1B-Chat-v1.0-Q4_K_M-GGUF"
echo "Start danach mit: ./start-llama.sh"
