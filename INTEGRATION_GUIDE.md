# Chezmoi Integration Guide
## For Your Exact Structure

## Your Structure (UNCHANGED)
```
/home/thinkpadx395_kei19/.local/share/chezmoi/
├── dot_config/
│   ├── fish/          ← YOUR EXISTING (untouched)
│   └── nvim/          ← YOUR EXISTING (if exists, untouched)
├── doc_zshrc          ← YOUR EXISTING (untouched)
└── .git/              ← YOUR EXISTING (untouched)
```

## New Integration (ADDED)
```
/home/thinkpadx395_kei19/.local/share/chezmoi/
├── ci/                ← CI/CD sync manager
│   ├── sync.sh
│   └── sync_config.lua
├── aliases/           ← Path aliases
│   ├── bash_aliases.sh
│   ├── fish_aliases.fish
│   ├── vars.sh
│   └── vars.fish
├── optimize/          ← System optimization
│   └── optimize.lua
└── lua/               ← Lua configuration
    ├── chezmoi_manage.lua
    ├── aliases.lua
    └── validator.lua
```

## Usage

### Load Aliases (Bash)
```bash
source /home/thinkpadx395_kei19/.local/share/chezmoi/aliases/bash_aliases.sh
source /home/thinkpadx395_kei19/.local/share/chezmoi/aliases/vars.sh
```

### Load Aliases (Fish)
```fish
source /home/thinkpadx395_kei19/.local/share/chezmoi/aliases/fish_aliases.fish
source /home/thinkpadx395_kei19/.local/share/chezmoi/aliases/vars.fish
```

### Run CI/CD Sync
```bash
cms
# or: bash /home/thinkpadx395_kei19/.local/share/chezmoi/ci/sync.sh
```

### System Optimization
```bash
lua /home/thinkpadx395_kei19/.local/share/chezmoi/optimize/optimize.lua
```

### Validate Configs
```bash
lua /home/thinkpadx395_kei19/.local/share/chezmoi/lua/validator.lua
```

### Quick Navigation
```bash
cz      # cd to chezmoi root
czf     # cd to fish config
czn     # cd to nvim config
```

### Environment Variables
```bash
$CZ           # /home/thinkpadx395_kei19/.local/share/chezmoi
$CZ_CONFIG    # /home/thinkpadx395_kei19/.local/share/chezmoi/dot_config
$CZ_FISH      # /home/thinkpadx395_kei19/.local/share/chezmoi/dot_config/fish
$CZ_NVIM      # /home/thinkpadx395_kei19/.local/share/chezmoi/dot_config/nvim
```