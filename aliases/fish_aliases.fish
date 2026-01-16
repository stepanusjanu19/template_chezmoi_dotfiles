# Chezmoi Aliases for Fish

# Path Variables
set -gx CZ "/home/thinkpadx395_kei19/.local/share/chezmoi"
set -gx CZ_CONFIG "/home/thinkpadx395_kei19/.local/share/chezmoi/dot_config"
set -gx CZ_FISH "/home/thinkpadx395_kei19/.local/share/chezmoi/dot_config/fish"
set -gx CZ_NVIM "/home/thinkpadx395_kei19/.local/share/chezmoi/dot_config/nvim"

# Navigation
abbr -a cz 'cd $CZ'
abbr -a czc 'cd $CZ_CONFIG'
abbr -a czf 'cd $CZ_FISH'
abbr -a czn 'cd $CZ_NVIM'

# Chezmoi
abbr -a cm chezmoi
abbr -a cma 'chezmoi apply'
abbr -a cmd 'chezmoi diff'
abbr -a cms 'bash $CZ/ci/sync.sh'

# Git
abbr -a czgit 'cd $CZ; and git'
abbr -a czst 'cd $CZ; and git status'
