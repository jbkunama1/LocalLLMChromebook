# Repo-Struktur

```text
LocalLLMChromebook/
├── README.md
├── INSTALL.md
├── setup.sh
├── start-llama.sh
├── index.html
├── LICENSE
├── .gitignore
└── assets/
    └── logo.png   # optional
```

## GitHub Pages

- Lege `index.html` ins Repo-Root oder alternativ in `/docs`.
- GitHub Pages sucht nach `index.html`, `index.md` oder `README.md` als Einstiegspunkt.
- Wenn du Pages aus `/docs` veröffentlichst, muss `index.html` direkt in `/docs` liegen. [cite:224]

## Hinweise

- `build/`, `CMakeFiles/` und `CMakeCache.txt` sollten ignoriert werden, da sie generierte CMake-Dateien sind. [cite:232]
- Lokale GGUF-Modelle und API-Key-Dateien gehören nicht ins Repo. [cite:232]
