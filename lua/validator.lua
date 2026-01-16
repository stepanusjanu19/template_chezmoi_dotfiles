-- Configuration Validator
local Validator = {}

function Validator:check_lua(file)
    local result = os.execute("lua -c " .. file .. " 2>&1")
    return result == 0
end

function Validator:validate_all()
    print("🔍 Validating configurations...")
    
    local files = {
        "lua/chezmoi_manage.lua",
        "lua/aliases.lua",
        "ci/sync_config.lua",
        "optimize/optimize.lua",
    }
    
    local root = "/home/thinkpadx395_kei19/.local/share/chezmoi"
    local errors = 0
    
    for _, file in ipairs(files) do
        local path = root .. "/" .. file
        local f = io.open(path, "r")
        if f then
            f:close()
            if self:check_lua(path) then
                print("  ✅ " .. file)
            else
                print("  ❌ " .. file)
                errors = errors + 1
            end
        end
    end
    
    if errors == 0 then
        print("\n✅ All validations passed!")
    else
        print(string.format("\n❌ %d error(s) found", errors))
    end
end

return Validator