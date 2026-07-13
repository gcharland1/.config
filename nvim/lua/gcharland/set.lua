-- Set colorscheme
--vim.cmd.colorscheme("habamax")
vim.api.nvim_set_hl(0, "Normal", { bg = "#0a0a0a" })
vim.opt.termguicolors = true
vim.opt.incsearch = true -- incremental search
vim.opt.hlsearch = false -- incremental search


-- Don't try to reset nertw cursor location
vim.g.netrw_banner = 1
vim.g.netrw_cursor = 1
vim.g.netrw_fastbrowse = 1

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

vim.api.nvim_create_autocmd("FileType", {
    pattern = "markdown",
    callback = function()
        vim.opt_local.wrap = true
        vim.opt_local.linebreak = true   -- coupe aux word-breaks, jamais mid-mot
        vim.opt_local.textwidth = 140
        vim.opt_local.colorcolumn = "140"
    end,
})

vim.cmd("command! W w")
vim.cmd("command! Wq wq")
vim.cmd("command! WQ wq")
vim.cmd("command! Q q")

