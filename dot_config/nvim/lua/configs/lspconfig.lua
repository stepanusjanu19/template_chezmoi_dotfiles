-- Load NvChad defaults
local nvlsp = require("nvchad.configs.lspconfig")
nvlsp.defaults()

-- YES, this is deprecated (warning only)
-- NO, you must NOT change it yet
---@diagnostic disable-next-line: deprecated
local lspconfig = require("lspconfig")

-- Simple servers
local servers = { "html", "cssls" }

for _, server in ipairs(servers) do
    lspconfig[server].setup {
        on_attach = nvlsp.on_attach,
        capabilities = nvlsp.capabilities,
    }
end

-- Lua language server
lspconfig.lua_ls.setup {
    on_attach = nvlsp.on_attach,
    capabilities = nvlsp.capabilities,
    settings = {
        Lua = {
            diagnostics = { globals = { "vim" } },
            workspace = {
                library = vim.api.nvim_get_runtime_file("", true),
                checkThirdParty = false,
            },
            telemetry = { enable = false },
        },
    },
}
