-- This file is called from init.vim (Added when cloning the repo)

return require('packer').startup(function(use)
    -- Packer can manage itself
    use('wbthomason/packer.nvim')

    -- Fizzy finder
    use({
        'nvim-telescope/telescope.nvim', tag = '0.1.5',
        -- or                            , branch = '0.1.x',
        requires = { {'nvim-lua/plenary.nvim'} }
    })

    -- Harpoon (Pin files for quick access)
    use({'theprimeagen/harpoon'})

    -- Linter (Smart highlighting and coloring for programming languages)
    use({'nvim-treesitter/nvim-treesitter', run = ':TSUpdate'})

    -- Code analyzer
    use({
       'folke/trouble.nvim',
        config = function()
            require('trouble').setup {
                icons = true,
                -- your configuration comes here
                -- or leave it empty to the default settings
                -- refer to the configuration section below
            }
        end
    })

    -- lsp server config
    use {
        'VonHeikemen/lsp-zero.nvim',
        branch = 'v3.x',
        requires = {
            -- LSP Support
            {'neovim/nvim-lspconfig'},

            --- Uncomment these if you want to manage LSP servers from neovim
            {'williamboman/mason.nvim'},
            {'williamboman/mason-lspconfig.nvim'},

            -- Autocompletion
            {'hrsh7th/nvim-cmp'},
            {'hrsh7th/cmp-buffer'},
            {'hrsh7th/cmp-path'},
            {'saadparwaiz1/cmp_luasnip'},
            {'hrsh7th/cmp-nvim-lsp'},
            {'hrsh7th/cmp-nvim-lua'},

            -- Snippets
            {'L3MON4D3/LuaSnip'},
            {'rafamadriz/friendly-snippets'},
        }
    }

    -- Git-like undo tree
    use({'mbbill/undotree'})

    -- Lazygit for nvim
    use({
        "kdheepak/lazygit.nvim",
        -- optional for floating window border decoration
        requires = {
            "nvim-lua/plenary.nvim",
        },
    })

    -- Markdownpreview
    use({
        "iamcco/markdown-preview.nvim",
        run = "cd app && npm install",
        setup = function()
            vim.g.mkdp_filetypes = { "markdown" }
        end,
        ft = { "markdown" },
    })

    -- Colorschemes
    use({'navarasu/onedark.nvim'})
    use({'rose-pine/neovim'})

end)
