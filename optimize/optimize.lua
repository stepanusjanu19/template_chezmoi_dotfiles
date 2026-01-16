#!/usr/bin/env lua
-- Fedora System Optimizer
-- For your chezmoi structure

local Optimizer = {}

function Optimizer:dnf()
    print("⚙️  Optimizing DNF...")
    
    local config = [[# DNF Optimization
max_parallel_downloads=10
fastestmirror=True
deltarpm=True
]]
    
    local tmp = "/tmp/dnf_opt.conf"
    local f = io.open(tmp, "w")
    if f then
        f:write(config)
        f:close()
        os.execute("sudo bash -c 'cat " .. tmp .. " >> /etc/dnf/dnf.conf'")
        os.remove(tmp)
        print("✅ DNF optimized")
    end
end

function Optimizer:sysctl()
    print("⚙️  Optimizing sysctl...")
    
    local config = [[# System Performance
vm.swappiness=10
vm.vfs_cache_pressure=50
net.ipv4.tcp_fastopen=3
]]
    
    local tmp = "/tmp/sysctl_opt.conf"
    local f = io.open(tmp, "w")
    if f then
        f:write(config)
        f:close()
        os.execute("sudo mv " .. tmp .. " /etc/sysctl.d/99-chezmoi-optimize.conf")
        os.execute("sudo sysctl --system > /dev/null 2>&1")
        print("✅ Sysctl optimized")
    end
end

function Optimizer:run()
    print("🚀 Running Fedora optimization...\n")
    self:dnf()
    self:sysctl()
    print("\n✅ Optimization complete!")
end

-- Run if called directly
if arg and arg[0]:match("optimize%.lua$") then
    Optimizer:run()
end

return Optimizer