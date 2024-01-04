vim.opt.path = vim.opt.path + ':~/.volta/bin/node@16:'
vim.opt.path = vim.opt.path + ':~/.volta/bin/npm@8'
vim.opt.path = vim.opt.path + ':/usr/lib/jvm/java-17-openjdk-amd64/bin/java'

vim.opt.nu = true
vim.opt.relativenumber = true

vim.g.netrw_bufsettings = 'noma nomod nu nowrap ro nobl'
vim.g.netrw_liststyle = 0
vim.g.netrw_sizestyle = "H"

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.smartindent = true

vim.opt.wrap = false

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true
--
vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.termguicolors = true
--
vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")
--
vim.opt.updatetime = 50
--
vim.opt.colorcolumn = "160"
vim.opt.cursorline = true
