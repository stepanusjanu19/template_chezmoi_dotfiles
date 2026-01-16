-- Path Aliases Module
local Aliases = {
    -- Your exact structure
    CZ = "/home/thinkpadx395_kei19/.local/share/chezmoi",
    CZ_CONFIG = "/home/thinkpadx395_kei19/.local/share/chezmoi/dot_config",
    CZ_FISH = "/home/thinkpadx395_kei19/.local/share/chezmoi/dot_config/fish",
    CZ_NVIM = "/home/thinkpadx395_kei19/.local/share/chezmoi/dot_config/nvim",
    CZ_GIT = "/home/thinkpadx395_kei19/.local/share/chezmoi/.git",
    
    -- Integration
    CZ_CI = "/home/thinkpadx395_kei19/.local/share/chezmoi/ci",
    CZ_OPT = "/home/thinkpadx395_kei19/.local/share/chezmoi/optimize",
    CZ_LUA = "/home/thinkpadx395_kei19/.local/share/chezmoi/lua",
}

function Aliases:export_bash()
    for k, v in pairs(self) do
        if type(v) == "string" then
            print(string.format('export %s="%s"', k, v))
        end
    end
end

function Aliases:export_fish()
    for k, v in pairs(self) do
        if type(v) == "string" then
            print(string.format('set -gx %s "%s"', k, v))
        end
    end
end

return Aliases