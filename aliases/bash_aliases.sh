#!/bin/bash
# Chezmoi Aliases - Your Structure

# Path Variables
export CZ="/home/thinkpadx395_kei19/.local/share/chezmoi"
export CZ_CONFIG="/home/thinkpadx395_kei19/.local/share/chezmoi/dot_config"
export CZ_FISH="/home/thinkpadx395_kei19/.local/share/chezmoi/dot_config/fish"
export CZ_NVIM="/home/thinkpadx395_kei19/.local/share/chezmoi/dot_config/nvim"
export CZ_GIT="/home/thinkpadx395_kei19/.local/share/chezmoi/.git"

# Navigation Aliases
alias cz='cd $CZ'
alias czc='cd $CZ_CONFIG'
alias czf='cd $CZ_FISH'
alias czn='cd $CZ_NVIM'

# Chezmoi Commands
alias cm='chezmoi'
alias cma='chezmoi apply'
alias cmd='chezmoi diff'
alias cme='chezmoi edit'
alias cms='bash $CZ/ci/sync.sh'

# Git Commands
alias czgit='cd $CZ && git'
alias czst='cd $CZ && git status'
alias czpull='cd $CZ && git pull'
alias czpush='cd $CZ && git push'
