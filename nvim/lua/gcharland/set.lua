-- Set colorscheme
vim.cmd.colorscheme("habamax")
vim.api.nvim_set_hl(0, "Normal", { bg = "#0a0a0a" })
vim.opt.termguicolors = true
vim.opt.incsearch = true -- incremental search
vim.opt.hlsearch = false -- incremental search

-- vim.opt.clipboard = 'unnamedplus' -- use system keyboard for yank

vim.opt.nu = true                 -- set line numbers -- set line numbers
vim.opt.relativenumber = true     -- use relative line numbers

-- set tab size to 2 spaces
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true

vim.opt.wrap = false

vim.cmd("command! W w")
vim.cmd("command! Wq wq")
vim.cmd("command! WQ wq")
vim.cmd("command! Q q")
