vim.g.mapleader = " "

-- Projet files
vim.keymap.set("n", "<leader>pf", vim.cmd.Ex)

-- Navigate to previous buffer
vim.keymap.set("n", "<leader><Tab>", "<cmd>buffer#<cr>")

-- Yank to clipboard
vim.keymap.set("n", "<leader>y", "\"+y")
vim.keymap.set("v", "<leader>y", "\"+y")

-- Delete/Paste without overwriting register
vim.keymap.set("v", "<leader>p", "pgvy")
vim.keymap.set("v", "<leader>d", "\"_d")

-- Center window after big jumps
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<S-n>", "<S-n>zz")

-- Center window on next search result
vim.keymap.set("n", "n", "nzz")
vim.keymap.set("n", "N", "Nzz")

-- Resize split windows
vim.keymap.set("n", "<C-w>|", "<cmd>vsplit<cr>")
vim.keymap.set("n", "<C-w>-", "<cmd>split<cr>")

-- Resize split windows
vim.keymap.set("n", "<C-w><C-h>", "<cmd>vertical resize -5<cr>")
vim.keymap.set("n", "<C-w><C-j>", "<cmd>resize -5<cr>")
vim.keymap.set("n", "<C-w><C-k>", "<cmd>resize +5<cr>")
vim.keymap.set("n", "<C-w><C-l>", "<cmd>vertical resize +5<cr>")

-- Search word under cursor in page
--  ...project, etc

-- Search commands ( :command ) with or without fzf auto-complete

-- Add to harpoon in Netrw

-- Search word under cursor in page
vim.keymap.set("v", "/", "y/<C-R>\"<CR>")
vim.keymap.set("v", "<leader>/", "y:%s/<C-R>\"//g<left><left>")

-- Execute current file
vim.keymap.set("n", "<leader><Enter>", ":w<CR>:! %:p<CR>")

-- Format XML file
vim.keymap.set("n", "<leader><leader>X", ":w<CR>:r!xmllint --format %<CR>ggdd")
