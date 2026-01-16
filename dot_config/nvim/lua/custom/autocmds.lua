require "nvchad.autocmds"

local autocmd = vim.api.nvim_create_autocmd

autocmd("BufWinEnter", {
    callback = function()
        vim.wo.number = true
        vim.wo.relativenumber = true
        vim.wo.cursorline = true
        vim.wo.wrap = false
        vim.wo.colorcolumn = "80"
    end,
})


vim.schedule(function()
    vim.notify("✅ Neovim ready!  (Ctrl+A Select All, Ctrl+S Save, Ctrl+V Paste)")
end)
