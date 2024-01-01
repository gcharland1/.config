require'nvim-treesitter.configs'.setup {
  -- A list of parser names, or "all"
  ensure_installed = {
      "java",
      "javascript",
      "typescript",
      "html",
      "css" ,
      "lua",
      "vim",
      "vimdoc",
      "query"
},

  sync_install = false,

  auto_install = false,

  highlight = {
    enable = true,
    disable = {},
    additional_vim_regex_highlighting = false,
  },
}
