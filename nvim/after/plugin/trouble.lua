require('trouble').setup({
    icons = false,
    fold_open = "v", -- icon used for open folds
    fold_closed = ">", -- icon used for closed folds
    indent_lines = false, -- add an indent guide below the fold icons
    signs = {
        -- icons / text used for a diagnostic
        error = "E",
        warning = "W",
        hint = "hint",
        information = "info"
    },
    -- enabling this will use the signs defined in your lsp client
    use_diagnostic_signs = true,
})

vim.keymap.set("n", "<leader>xq", "<cmd>TroubleToggle quickfix<cr>",
  {silent = true, noremap = true}
)
