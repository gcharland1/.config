return {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.6', -- or, branch = '0.1.x',
    dependencies = { 
        'nvim-lua/plenary.nvim',
        {
            "nvim-telescope/telescope-live-grep-args.nvim" ,
            version = "^1.0.0",
        },
    },

    config = function()
        local telescope = require("telescope")
        local lga_actions = require("telescope-live-grep-args.actions")

        telescope.setup({
            defaults = {
                dynamic_preview_title = true,
                file_ignore_patterns = {
                    "node_modules", "build", "dist", "target"
                },
                path_display = { "shorten" },
            },
            extensions = {
                live_grep_args = {
                    auto_quoting = true, -- enable/disable auto-quoting
                    -- define mappings, e.g.
                    mappings = { -- extend mappings
                        i = {
                            ["<C-k>"] = lga_actions.quote_prompt(),
                            ["<C-i>"] = lga_actions.quote_prompt({ postfix = " --iglob " }),
                            -- freeze the current list and start a fuzzy search in the frozen list
                            ["<C-space>"] = lga_actions.to_fuzzy_refine,
                        },
                    },
                    -- ... also accepts theme settings, for example:
                    -- theme = "dropdown", -- use dropdown theme
                    -- theme = { }, -- use own theme spec
                    -- layout_config = { mirror=true }, -- mirror preview pane
                }
            }
        })

        telescope.load_extension("live_grep_args")

        -- Keybinding: Ctrl+f in normal mode opens live_grep_args
        vim.keymap.set(
            "n",
            "<C-f>",
            telescope.extensions.live_grep_args.live_grep_args,
            { noremap = true, silent = true, desc = "Live grep with filters" }
        )


        local builtin = require('telescope.builtin')
        vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
        vim.keymap.set('n', '<leader>fg', builtin.git_files, {})
        vim.keymap.set('n', '<leader>fl', builtin.live_grep, {})
        -- vim.keymap.set('n', ';', builtin.buffers, {})
        vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
    end
}
