return {
    "bluz71/vim-moonfly-colors",
    name = "moonfly",
    lazy = false,
    priority = 1000,

    config = function()
        vim.g.moonflyUnderlineMatchParen = true
        vim.g.moonflyWinSeparator = 2
        vim.g.moonflyVirtualTextColor = true
        vim.cmd.colorscheme("moonfly")
    end,
}
