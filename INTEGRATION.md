# Chezmoi C & Lua Integration

Added to your structure:

```
/home/thinkpadx395_kei19/.local/share/chezmoi/
├── ci/              ← CI/CD sync manager
│   └── sync.sh
├── aliases/         ← Path aliases
│   ├── bash_aliases.sh
│   └── fish_aliases.fish
├── optimize/        ← System optimization
│   └── fedora.conf
├── lua/             ← Lua config
│   └── config.lua
├── dot_config/      ← YOUR EXISTING
│   ├── fish/        ← (unchanged)
│   └── nvim/        ← (unchanged)
├── doc_zshrc        ← YOUR EXISTING (unchanged)
└── .git/            ← YOUR EXISTING (unchanged)
```

## Usage

### Load Aliases
```bash
source /home/thinkpadx395_kei19/.local/share/chezmoi/aliases/bash_aliases.sh
```

### CI/CD Sync
```bash
cms    # or: bash /home/thinkpadx395_kei19/.local/share/chezmoi/ci/sync.sh
```

### Lua Config
```bash
lua /home/thinkpadx395_kei19/.local/share/chezmoi/lua/config.lua
```

### Quick Navigation
```bash
cz     # cd to chezmoi root
czf    # cd to fish config
czn    # cd to nvim config
```
