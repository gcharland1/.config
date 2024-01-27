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
vim.keymap.set("n", "n", "nzz")

-- New keybinding ideas
-- Add to harpoon in Netrw
-- Search word under cursor in page
vim.keymap.set("v", "/", "y/<C-R>\"<CR>")

