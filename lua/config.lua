#!/usr/bin/env lua
-- Chezmoi Lua Configuration
-- For your exact structure

local Config = {
    paths = {
        chezmoi = "/home/thinkpadx395_kei19/.local/share/chezmoi",
        dot_config = "/home/thinkpadx395_kei19/.local/share/chezmoi/dot_config",
        fish = "/home/thinkpadx395_kei19/.local/share/chezmoi/dot_config/fish",
        nvim = "/home/thinkpadx395_kei19/.local/share/chezmoi/dot_config/nvim",
    }
}

function Config:sync()
    print("🔄 Syncing via Lua...")
    os.execute("bash " .. self.paths.chezmoi .. "/ci/sync.sh")
end

function Config:optimize()
    print("⚡ Running optimization...")
    local opt_file = self.paths.chezmoi .. "/optimize/fedora.conf"
    print("Config: " .. opt_file)
end

return Config
