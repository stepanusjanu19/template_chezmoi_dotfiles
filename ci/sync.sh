#!/bin/bash
# Lua-powered sync runner
cd "/home/thinkpadx395_kei19/.local/share/chezmoi" || exit 1
lua -e "
    local config = dofile('/home/thinkpadx395_kei19/.local/share/chezmoi/ci/sync_config.lua')
    config:run()
"