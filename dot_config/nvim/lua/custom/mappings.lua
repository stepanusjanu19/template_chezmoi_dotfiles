-- require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set
local dap = require("dap")

vim.g.mapleader = " "

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

-- Save
map("n", "<C-s>", "<cmd>w<CR>")
map("i", "<C-s>", "<Esc><cmd>w<CR>a")
map("v", "<C-s>", "<Esc><cmd>w<CR>")

-- Quit
map("n", "<C-q>", "<cmd>q<CR>")
map("i", "<C-q>", "<Esc><cmd>q<CR>")
map("v", "<C-q>", "<Esc><cmd>q<CR>")

-- Select All
map("n", "<C-a>", "ggVG")
map("i", "<C-a>", "<Esc>ggVG")
map("v", "<C-a>", "ggVG")

-- Clipboard (VS Code style)
map("v", "<C-c>", '"+y')
map("v", "<C-x>", '"+x')
map("n", "<C-v>", '"+p')
map("i", "<C-v>", '<Esc>"+pa')
map("c", "<C-v>", "<C-r>+")

-- Undo / Redo
map("n", "<C-z>", "u")
map("n", "<C-y>", "<C-r>")

-- Search word under cursor
map("n", "<C-f>", [[/<C-r><C-w><CR>]])

-- Clear highlight
map("n", "<Esc><Esc>", "<cmd>nohlsearch<CR>")

-- Split navigation
map("n", "<C-h>", "<C-w>h")
map("n", "<C-j>", "<C-w>j")
map("n", "<C-k>", "<C-w>k")
map("n", "<C-l>", "<C-w>l")

-- Resize splits
map("n", "<C-Up>", "<cmd>resize +2<CR>")
map("n", "<C-Down>", "<cmd>resize -2<CR>")
map("n", "<C-Left>", "<cmd>vertical resize -2<CR>")
map("n", "<C-Right>", "<cmd>vertical resize +2<CR>")


vim.keymap.set("n", "<F5>", dap.continue)
vim.keymap.set("n", "<F10>", dap.step_over)
vim.keymap.set("n", "<F11>", dap.step_into)
vim.keymap.set("n", "<F12>", dap.step_out)
vim.keymap.set("n", "<Leader>b", dap.toggle_breakpoint)

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
