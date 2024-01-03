require'nvim-treesitter.configs'.setup {
  -- A list of parser names, or "all" (the five listed parsers should always be installed)
  ensure_installed = {
      "java",
      "javascript",
      "jsdoc",
      "comment",
      "typescript",
      "html",
      "css" ,
      "c",
      "lua",
      "query",
      "vim",
      "vimdoc"
  },

  sync_install = false,

  auto_install = false,

  highlight = {
    enable = true,
    disable = {},
    additional_vim_regex_highlighting = false,
  },
}
