-- Adapted from a combo of
-- https://lsp-zero.netlify.app/v3.x/blog/theprimeagens-config-from-2022.html
-- https://github.com/ThePrimeagen/init.lua/blob/master/lua/theprimeagen/lazy/lsp.lua
return {
    "neovim/nvim-lspconfig",
    dependencies = {
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-cmdline",
        "hrsh7th/nvim-cmp",
        "L3MON4D3/LuaSnip",
        "saadparwaiz1/cmp_luasnip",
        "j-hui/fidget.nvim",
    },
    config = function()

        local cmp_lsp = require("cmp_nvim_lsp")
        local capabilities = vim.tbl_deep_extend(
            "force",
            {},
            vim.lsp.protocol.make_client_capabilities(),
            cmp_lsp.default_capabilities()
        )
        vim.api.nvim_create_autocmd("LspAttach", {
            callback = function(args)
                local bufnr = args.buf

                local bufmap = function(mode, lhs, rhs, desc)
                  vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
                end
                -- LSP actions
                bufmap("n", "gd", vim.lsp.buf.definition, "Goto Definition")        -- [web:4]
                bufmap("n", "gr", vim.lsp.buf.references, "Goto References")       -- [web:4]
                bufmap("n", "gI", vim.lsp.buf.implementation, "Goto Implementation") -- [web:4]
                bufmap("n", "gt", vim.lsp.buf.type_definition, "Goto Type Def")    -- [web:4]
                bufmap("n", "K", vim.lsp.buf.hover, "Hover")                       -- [web:4]
                bufmap("n", "<C-k>", vim.lsp.buf.signature_help, "Signature Help") -- [web:10]
                bufmap("n", "<leader>rn", vim.lsp.buf.rename, "Rename")            -- [web:1]
                bufmap("n", "<leader>ca", vim.lsp.buf.code_action, "Code Action")  -- [web:1]
                bufmap("v", "<leader>ca", vim.lsp.buf.code_action, "Range Code Action") -- [web:4]
                bufmap("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, "Add Workspace Folder") -- [web:10]
                bufmap("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, "Remove Workspace Folder") -- [web:10]
                bufmap("n", "<leader>wl", function()
                      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
                    end, "List Workspace Folders")                                     -- [web:10]
                bufmap("n", "<leader>f", function()
                      vim.lsp.buf.format({ async = true })
                    end, "Format Buffer")
            end,
        })

        require("fidget").setup({})
        require("mason").setup()
        require('mason-lspconfig').setup({
            ensure_installed = {
                "bashls",
                "eslint",
                "jdtls",
                "lua_ls",
                "pyright",
                "ruff",
                "ts_ls",
            },

        })

        require('luasnip.loaders.from_vscode').lazy_load()
        local cmp = require('cmp')
        local cmp_select = { behavior = cmp.SelectBehavior.Select }

        cmp.setup({
            sources = {
                { name = 'path' },
                { name = 'nvim_lsp' },
                { name = 'luasnip', keyword_length = 2 },
                { name = 'buffer',  keyword_length = 3 },
            },
            mapping = cmp.mapping.preset.insert({
                ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
                ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
                ['<CR>'] = cmp.mapping.confirm({ select = true }),
                ['<C-Space>'] = cmp.mapping.complete(),
            }),
            snippet = {
                expand = function(args)
                    require('luasnip').lsp_expand(args.body)
                end,
            },
        })
    end
}
