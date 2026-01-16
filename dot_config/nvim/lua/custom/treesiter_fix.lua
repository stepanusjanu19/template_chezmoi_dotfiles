vim.api.nvim_create_autocmd("BufEnter", {
  callback = function()
    if vim.bo.filetype == "" then
      vim.treesitter.stop()
    end
  end,
})

