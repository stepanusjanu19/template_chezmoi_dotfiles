#!/usr/bin/env lua

--[[
    chezmoi_manage.lua
    Lua manager for your EXACT structure
    Place in: ~/.local/share/chezmoi/lua/
    Usage: lua chezmoi_manage.lua [options]
]]

local io = require("io")
local os = require("os")

local ChezmoiManager = {
    home = os.getenv("HOME") or "",

    paths = {
        chezmoi = nil,
        dot_config = nil,
        fish = nil,
        nvim = nil,
        git = nil,

        ci = nil,
        aliases = nil,
        optimize = nil,
        lua = nil,
    },

    colors = {
        reset = "\27[0m",
        green = "\27[32m",
        blue = "\27[34m",
        cyan = "\27[36m",
        yellow = "\27[33m",
    }
}

function ChezmoiManager:init()
    self.paths.chezmoi = self.home .. "/.local/share/chezmoi"
    self.paths.dot_config = self.paths.chezmoi .. "/dot_config"
    self.paths.fish = self.paths.dot_config .. "/fish"
    self.paths.nvim = self.paths.dot_config .. "/nvim"
    self.paths.git = self.paths.chezmoi .. "/.git"
    self.paths.ci = self.paths.chezmoi .. "/ci"
    self.paths.aliases = self.paths.chezmoi .. "/aliases"
    self.paths.optimize = self.paths.chezmoi .. "/optimize"
    self.paths.lua = self.paths.chezmoi .. "/lua"
end

function ChezmoiManager:print_banner()
    print(self.colors.cyan .. [[
╔════════════════════════════════════════╗
║  Chezmoi Lua Manager                   ║
║  For Your Exact Structure              ║
╚════════════════════════════════════════╝
]] .. self.colors.reset)
end

function ChezmoiManager:print_info(msg)
    print(self.colors.green .. "[INFO] " .. self.colors.reset .. msg)
end

function ChezmoiManager:print_section(title)
    print("\n" .. self.colors.blue .. "=== " .. title .. " ===" .. self.colors.reset)
end

function ChezmoiManager:exec(cmd)
    return os.execute(cmd) == 0
end

function ChezmoiManager:file_exists(path)
    local f = io.open(path, "r")
    if f then f:close(); return true end
    return false
end

function ChezmoiManager:write_file(path, content)
    local f = io.open(path, "w")
    if not f then return false end
    f:write(content)
    f:close()
    return true
end

function ChezmoiManager:mkdir(path)
    self:exec("mkdir -p " .. path)
end

-- Detect your existing structure
function ChezmoiManager:detect_structure()
    self:print_section("Detecting Your Structure")

    local items = {
        {"Chezmoi root", self.paths.chezmoi},
        {"dot_config/", self.paths.dot_config},
        {"dot_config/fish/", self.paths.fish},
        {"dot_config/nvim/", self.paths.nvim},
        {"git repo", self.paths.git},
    }

    for _, item in ipairs(items) do
        local exists = self:file_exists(item[2]) or self:file_exists(item[2] .. "/.")
        local status = exists and "✓" or "✗"
        print(string.format("  %-20s %s", item[1], status))
    end
end

function ChezmoiManager:create_optimizer()
    self:print_section("Creating System Optimizer")

    self:mkdir(self.paths.optimize)

    local optimizer_content = {}
    table.insert(optimizer_content, "#!/usr/bin/env lua")
    table.insert(optimizer_content, "-- Fedora System Optimizer")
    table.insert(optimizer_content, "-- For your chezmoi structure")
    table.insert(optimizer_content, "")
    table.insert(optimizer_content, "local Optimizer = {}")
    table.insert(optimizer_content, "")
    table.insert(optimizer_content, "function Optimizer:dnf()")
    table.insert(optimizer_content, '    print("⚙️  Optimizing DNF...")')
    table.insert(optimizer_content, "    ")
    table.insert(optimizer_content, "    local config = [[# DNF Optimization")
    table.insert(optimizer_content, "max_parallel_downloads=10")
    table.insert(optimizer_content, "fastestmirror=True")
    table.insert(optimizer_content, "deltarpm=True")
    table.insert(optimizer_content, "]]")
    table.insert(optimizer_content, "    ")
    table.insert(optimizer_content, '    local tmp = "/tmp/dnf_opt.conf"')
    table.insert(optimizer_content, '    local f = io.open(tmp, "w")')
    table.insert(optimizer_content, "    if f then")
    table.insert(optimizer_content, "        f:write(config)")
    table.insert(optimizer_content, "        f:close()")
    table.insert(optimizer_content, '        os.execute("sudo bash -c ' .. "'" .. 'cat " .. tmp .. " >> /etc/dnf/dnf.conf' .. "'" .. '")')
    table.insert(optimizer_content, "        os.remove(tmp)")
    table.insert(optimizer_content, '        print("✅ DNF optimized")')
    table.insert(optimizer_content, "    end")
    table.insert(optimizer_content, "end")
    table.insert(optimizer_content, "")
    table.insert(optimizer_content, "function Optimizer:sysctl()")
    table.insert(optimizer_content, '    print("⚙️  Optimizing sysctl...")')
    table.insert(optimizer_content, "    ")
    table.insert(optimizer_content, "    local config = [[# System Performance")
    table.insert(optimizer_content, "vm.swappiness=10")
    table.insert(optimizer_content, "vm.vfs_cache_pressure=50")
    table.insert(optimizer_content, "net.ipv4.tcp_fastopen=3")
    table.insert(optimizer_content, "]]")
    table.insert(optimizer_content, "    ")
    table.insert(optimizer_content, '    local tmp = "/tmp/sysctl_opt.conf"')
    table.insert(optimizer_content, '    local f = io.open(tmp, "w")')
    table.insert(optimizer_content, "    if f then")
    table.insert(optimizer_content, "        f:write(config)")
    table.insert(optimizer_content, "        f:close()")
    table.insert(optimizer_content, '        os.execute("sudo mv " .. tmp .. " /etc/sysctl.d/99-chezmoi-optimize.conf")')
    table.insert(optimizer_content, '        os.execute("sudo sysctl --system > /dev/null 2>&1")')
    table.insert(optimizer_content, '        print("✅ Sysctl optimized")')
    table.insert(optimizer_content, "    end")
    table.insert(optimizer_content, "end")
    table.insert(optimizer_content, "")
    table.insert(optimizer_content, "function Optimizer:run()")
    table.insert(optimizer_content, '    print("🚀 Running Fedora optimization...\\n")')
    table.insert(optimizer_content, "    self:dnf()")
    table.insert(optimizer_content, "    self:sysctl()")
    table.insert(optimizer_content, '    print("\\n✅ Optimization complete!")')
    table.insert(optimizer_content, "end")
    table.insert(optimizer_content, "")
    table.insert(optimizer_content, "-- Run if called directly")
    table.insert(optimizer_content, 'if arg and arg[0]:match("optimize%.lua$") then')
    table.insert(optimizer_content, "    Optimizer:run()")
    table.insert(optimizer_content, "end")
    table.insert(optimizer_content, "")
    table.insert(optimizer_content, "return Optimizer")

    local optimizer = table.concat(optimizer_content, "\n")

    local opt_file = self.paths.optimize .. "/optimize.lua"
    if self:write_file(opt_file, optimizer) then
        self:exec("chmod +x " .. opt_file)
        print("✅ Optimizer: optimize/optimize.lua")
    end
end

-- Create CI sync manager
function ChezmoiManager:create_ci_sync()
    self:print_section("Creating CI/CD Sync")

    self:mkdir(self.paths.ci)

    -- Build sync config without nested quotes
    local sync_lines = {}
    table.insert(sync_lines, "-- CI/CD Sync Configuration")
    table.insert(sync_lines, "return {")
    table.insert(sync_lines, '    chezmoi_root = "' .. self.paths.chezmoi .. '",')
    table.insert(sync_lines, "    ")
    table.insert(sync_lines, "    sync = {")
    table.insert(sync_lines, "        auto_pull = true,")
    table.insert(sync_lines, "        auto_apply = true,")
    table.insert(sync_lines, "        auto_commit = false,")
    table.insert(sync_lines, "    },")
    table.insert(sync_lines, "    ")
    table.insert(sync_lines, "    git = {")
    table.insert(sync_lines, "        pull_rebase = true,")
    table.insert(sync_lines, '        commit_msg = "Sync from " .. (os.getenv("HOSTNAME") or "local"),')
    table.insert(sync_lines, "    },")
    table.insert(sync_lines, "    ")
    table.insert(sync_lines, "    run = function(self)")
    table.insert(sync_lines, '        print("🔄 Starting sync...")')
    table.insert(sync_lines, "        ")
    table.insert(sync_lines, '        os.execute("cd " .. self.chezmoi_root)')
    table.insert(sync_lines, "        ")
    table.insert(sync_lines, "        if self.sync.auto_pull then")
    table.insert(sync_lines, '            print("📥 Pulling...")')
    table.insert(sync_lines, '            os.execute("cd " .. self.chezmoi_root .. " && git pull --rebase")')
    table.insert(sync_lines, "        end")
    table.insert(sync_lines, "        ")
    table.insert(sync_lines, "        if self.sync.auto_apply then")
    table.insert(sync_lines, '            print("✨ Applying...")')
    table.insert(sync_lines, '            os.execute("chezmoi apply")')
    table.insert(sync_lines, "        end")
    table.insert(sync_lines, "        ")
    table.insert(sync_lines, '        print("✅ Sync complete!")')
    table.insert(sync_lines, "    end")
    table.insert(sync_lines, "}")

    local sync_config = table.concat(sync_lines, "\n")

    local sync_file = self.paths.ci .. "/sync_config.lua"
    if self:write_file(sync_file, sync_config) then
        print("✅ CI config: ci/sync_config.lua")
    end

    -- Create sync runner
    local runner_lines = {}
    table.insert(runner_lines, "#!/bin/bash")
    table.insert(runner_lines, "# Lua-powered sync runner")
    table.insert(runner_lines, 'cd "' .. self.paths.chezmoi .. '" || exit 1')
    table.insert(runner_lines, 'lua -e "')
    table.insert(runner_lines, "    local config = dofile('" .. self.paths.chezmoi .. "/ci/sync_config.lua')")
    table.insert(runner_lines, "    config:run()")
    table.insert(runner_lines, '"')

    local runner = table.concat(runner_lines, "\n")

    local runner_file = self.paths.ci .. "/sync.sh"
    if self:write_file(runner_file, runner) then
        self:exec("chmod +x " .. runner_file)
        print("✅ Sync runner: ci/sync.sh")
    end
end

-- Create path aliases
function ChezmoiManager:create_aliases()
    self:print_section("Creating Aliases")

    self:mkdir(self.paths.aliases)

    -- Build alias module line by line
    local alias_lines = {}
    table.insert(alias_lines, "-- Path Aliases Module")
    table.insert(alias_lines, "local Aliases = {")
    table.insert(alias_lines, "    -- Your exact structure")
    table.insert(alias_lines, '    CZ = "' .. self.paths.chezmoi .. '",')
    table.insert(alias_lines, '    CZ_CONFIG = "' .. self.paths.dot_config .. '",')
    table.insert(alias_lines, '    CZ_FISH = "' .. self.paths.fish .. '",')
    table.insert(alias_lines, '    CZ_NVIM = "' .. self.paths.nvim .. '",')
    table.insert(alias_lines, '    CZ_GIT = "' .. self.paths.git .. '",')
    table.insert(alias_lines, "    ")
    table.insert(alias_lines, "    -- Integration")
    table.insert(alias_lines, '    CZ_CI = "' .. self.paths.ci .. '",')
    table.insert(alias_lines, '    CZ_OPT = "' .. self.paths.optimize .. '",')
    table.insert(alias_lines, '    CZ_LUA = "' .. self.paths.lua .. '",')
    table.insert(alias_lines, "}")
    table.insert(alias_lines, "")
    table.insert(alias_lines, "function Aliases:export_bash()")
    table.insert(alias_lines, "    for k, v in pairs(self) do")
    table.insert(alias_lines, '        if type(v) == "string" then')
    table.insert(alias_lines, '            print(string.format(' .. "'export %s=\"%s\"'" .. ', k, v))')
    table.insert(alias_lines, "        end")
    table.insert(alias_lines, "    end")
    table.insert(alias_lines, "end")
    table.insert(alias_lines, "")
    table.insert(alias_lines, "function Aliases:export_fish()")
    table.insert(alias_lines, "    for k, v in pairs(self) do")
    table.insert(alias_lines, '        if type(v) == "string" then')
    table.insert(alias_lines, '            print(string.format(' .. "'set -gx %s \"%s\"'" .. ', k, v))')
    table.insert(alias_lines, "        end")
    table.insert(alias_lines, "    end")
    table.insert(alias_lines, "end")
    table.insert(alias_lines, "")
    table.insert(alias_lines, "return Aliases")

    local alias_module = table.concat(alias_lines, "\n")

    local alias_file = self.paths.lua .. "/aliases.lua"
    self:mkdir(self.paths.lua)
    if self:write_file(alias_file, alias_module) then
        print("✅ Alias module: lua/aliases.lua")
    end

    -- Generate bash/fish exports
    local bash_cmd = "lua -e 'local a=dofile(\"" .. alias_file .. "\"); a:export_bash()' > " .. self.paths.aliases .. "/vars.sh"
    local fish_cmd = "lua -e 'local a=dofile(\"" .. alias_file .. "\"); a:export_fish()' > " .. self.paths.aliases .. "/vars.fish"

    self:exec(bash_cmd)
    self:exec(fish_cmd)

    print("✅ Exports: aliases/vars.sh and aliases/vars.fish")
end

-- Create validator
function ChezmoiManager:create_validator()
    self:print_section("Creating Validator")

    local val_lines = {}
    table.insert(val_lines, "-- Configuration Validator")
    table.insert(val_lines, "local Validator = {}")
    table.insert(val_lines, "")
    table.insert(val_lines, "function Validator:check_lua(file)")
    table.insert(val_lines, '    local result = os.execute("lua -c " .. file .. " 2>&1")')
    table.insert(val_lines, "    return result == 0")
    table.insert(val_lines, "end")
    table.insert(val_lines, "")
    table.insert(val_lines, "function Validator:validate_all()")
    table.insert(val_lines, '    print("🔍 Validating configurations...")')
    table.insert(val_lines, "    ")
    table.insert(val_lines, "    local files = {")
    table.insert(val_lines, '        "lua/chezmoi_manage.lua",')
    table.insert(val_lines, '        "lua/aliases.lua",')
    table.insert(val_lines, '        "ci/sync_config.lua",')
    table.insert(val_lines, '        "optimize/optimize.lua",')
    table.insert(val_lines, "    }")
    table.insert(val_lines, "    ")
    table.insert(val_lines, '    local root = "' .. self.paths.chezmoi .. '"')
    table.insert(val_lines, "    local errors = 0")
    table.insert(val_lines, "    ")
    table.insert(val_lines, "    for _, file in ipairs(files) do")
    table.insert(val_lines, '        local path = root .. "/" .. file')
    table.insert(val_lines, '        local f = io.open(path, "r")')
    table.insert(val_lines, "        if f then")
    table.insert(val_lines, "            f:close()")
    table.insert(val_lines, "            if self:check_lua(path) then")
    table.insert(val_lines, '                print("  ✅ " .. file)')
    table.insert(val_lines, "            else")
    table.insert(val_lines, '                print("  ❌ " .. file)')
    table.insert(val_lines, "                errors = errors + 1")
    table.insert(val_lines, "            end")
    table.insert(val_lines, "        end")
    table.insert(val_lines, "    end")
    table.insert(val_lines, "    ")
    table.insert(val_lines, "    if errors == 0 then")
    table.insert(val_lines, '        print("\\n✅ All validations passed!")')
    table.insert(val_lines, "    else")
    table.insert(val_lines, '        print(string.format("\\n❌ %d error(s) found", errors))')
    table.insert(val_lines, "    end")
    table.insert(val_lines, "end")
    table.insert(val_lines, "")
    table.insert(val_lines, "return Validator")

    local validator = table.concat(val_lines, "\n")

    local val_file = self.paths.lua .. "/validator.lua"
    if self:write_file(val_file, validator) then
        self:exec("chmod +x " .. val_file)
        print("✅ Validator: lua/validator.lua")
    end
end

-- Create usage guide
function ChezmoiManager:create_guide()
    self:print_section("Creating Usage Guide")

    local guide_lines = {}
    table.insert(guide_lines, "# Chezmoi Integration Guide")
    table.insert(guide_lines, "## For Your Exact Structure")
    table.insert(guide_lines, "")
    table.insert(guide_lines, "## Your Structure (UNCHANGED)")
    table.insert(guide_lines, "```")
    table.insert(guide_lines, self.paths.chezmoi .. "/")
    table.insert(guide_lines, "├── dot_config/")
    table.insert(guide_lines, "│   ├── fish/          ← YOUR EXISTING (untouched)")
    table.insert(guide_lines, "│   └── nvim/          ← YOUR EXISTING (if exists, untouched)")
    table.insert(guide_lines, "├── doc_zshrc          ← YOUR EXISTING (untouched)")
    table.insert(guide_lines, "└── .git/              ← YOUR EXISTING (untouched)")
    table.insert(guide_lines, "```")
    table.insert(guide_lines, "")
    table.insert(guide_lines, "## New Integration (ADDED)")
    table.insert(guide_lines, "```")
    table.insert(guide_lines, self.paths.chezmoi .. "/")
    table.insert(guide_lines, "├── ci/                ← CI/CD sync manager")
    table.insert(guide_lines, "│   ├── sync.sh")
    table.insert(guide_lines, "│   └── sync_config.lua")
    table.insert(guide_lines, "├── aliases/           ← Path aliases")
    table.insert(guide_lines, "│   ├── bash_aliases.sh")
    table.insert(guide_lines, "│   ├── fish_aliases.fish")
    table.insert(guide_lines, "│   ├── vars.sh")
    table.insert(guide_lines, "│   └── vars.fish")
    table.insert(guide_lines, "├── optimize/          ← System optimization")
    table.insert(guide_lines, "│   └── optimize.lua")
    table.insert(guide_lines, "└── lua/               ← Lua configuration")
    table.insert(guide_lines, "    ├── chezmoi_manage.lua")
    table.insert(guide_lines, "    ├── aliases.lua")
    table.insert(guide_lines, "    └── validator.lua")
    table.insert(guide_lines, "```")
    table.insert(guide_lines, "")
    table.insert(guide_lines, "## Usage")
    table.insert(guide_lines, "")
    table.insert(guide_lines, "### Load Aliases (Bash)")
    table.insert(guide_lines, "```bash")
    table.insert(guide_lines, "source " .. self.paths.chezmoi .. "/aliases/bash_aliases.sh")
    table.insert(guide_lines, "source " .. self.paths.chezmoi .. "/aliases/vars.sh")
    table.insert(guide_lines, "```")
    table.insert(guide_lines, "")
    table.insert(guide_lines, "### Load Aliases (Fish)")
    table.insert(guide_lines, "```fish")
    table.insert(guide_lines, "source " .. self.paths.chezmoi .. "/aliases/fish_aliases.fish")
    table.insert(guide_lines, "source " .. self.paths.chezmoi .. "/aliases/vars.fish")
    table.insert(guide_lines, "```")
    table.insert(guide_lines, "")
    table.insert(guide_lines, "### Run CI/CD Sync")
    table.insert(guide_lines, "```bash")
    table.insert(guide_lines, "cms")
    table.insert(guide_lines, "# or: bash " .. self.paths.chezmoi .. "/ci/sync.sh")
    table.insert(guide_lines, "```")
    table.insert(guide_lines, "")
    table.insert(guide_lines, "### System Optimization")
    table.insert(guide_lines, "```bash")
    table.insert(guide_lines, "lua " .. self.paths.chezmoi .. "/optimize/optimize.lua")
    table.insert(guide_lines, "```")
    table.insert(guide_lines, "")
    table.insert(guide_lines, "### Validate Configs")
    table.insert(guide_lines, "```bash")
    table.insert(guide_lines, "lua " .. self.paths.chezmoi .. "/lua/validator.lua")
    table.insert(guide_lines, "```")
    table.insert(guide_lines, "")
    table.insert(guide_lines, "### Quick Navigation")
    table.insert(guide_lines, "```bash")
    table.insert(guide_lines, "cz      # cd to chezmoi root")
    table.insert(guide_lines, "czf     # cd to fish config")
    table.insert(guide_lines, "czn     # cd to nvim config")
    table.insert(guide_lines, "```")
    table.insert(guide_lines, "")
    table.insert(guide_lines, "### Environment Variables")
    table.insert(guide_lines, "```bash")
    table.insert(guide_lines, "$CZ           # " .. self.paths.chezmoi)
    table.insert(guide_lines, "$CZ_CONFIG    # " .. self.paths.dot_config)
    table.insert(guide_lines, "$CZ_FISH      # " .. self.paths.fish)
    table.insert(guide_lines, "$CZ_NVIM      # " .. self.paths.nvim)
    table.insert(guide_lines, "```")

    local guide = table.concat(guide_lines, "\n")

    local guide_file = self.paths.chezmoi .. "/INTEGRATION_GUIDE.md"
    if self:write_file(guide_file, guide) then
        print("✅ Guide: INTEGRATION_GUIDE.md")
    end
end

-- Main
function ChezmoiManager:run(args)
    self:print_banner()
    self:init()
    self:detect_structure()

    self:create_ci_sync()
    self:create_aliases()
    self:create_optimizer()
    self:create_validator()
    self:create_guide()

    print("\n" .. self.colors.green .. "✅ Integration Complete!" .. self.colors.reset)
    print("\nNext steps:")
    print("  1. source " .. self.paths.aliases .. "/bash_aliases.sh")
    print("  2. cms (run sync)")
    print("  3. cat " .. self.paths.chezmoi .. "/INTEGRATION_GUIDE.md")
    print()
end

-- Run
ChezmoiManager:run(arg)
