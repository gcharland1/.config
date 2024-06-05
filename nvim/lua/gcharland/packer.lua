return require('packer').startup(function(use)
    -- Packer can manage itself
    use('wbthomason/packer.nvim')

    -- My Maven pluggin
    --use('/home/gcharland/git/personnel/marvin.nvim')

    -- Fizzy finder
    use({
        'nvim-telescope/telescope.nvim', tag = '0.1.5',
        requires = { {'nvim-lua/plenary.nvim'} }
    })

    -- Harpoon (Pin files for quick access)
    use({'theprimeagen/harpoon'})

    -- Linter (Smart highlighting and coloring for programming languages)
    use({'nvim-treesitter/nvim-treesitter'})
    use("nvim-treesitter/playground")
    use("nvim-treesitter/nvim-treesitter-context")

    -- Java specif Lsp and linter
--    use({
--        'neoclide/coc.nvim',
--        branch = 'release',
--        run = "npm ci",
--    })

    -- Code analyzer
    use({
       'folke/trouble.nvim',
       config = function()
           require("trouble").setup {
               icons = false,
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

    -- Fugitive (Git)
    use({"tpope/vim-fugitive"})

    -- Lazygit for nvim
--    use({
--        "kdheepak/lazygit.nvim",
--        requires = {
--            "nvim-lua/plenary.nvim",
--        },
--    })

    -- Markdownpreview
    use({
        "iamcco/markdown-preview.nvim",
        run = "cd app && npm install",
        setup = function()
            vim.g.mkdp_filetypes = { "markdown" }
        end,
        ft = { "markdown" },
    })

    -- Colorscheme
    use({'rose-pine/neovim'})

    -- Vim Be Good
    use({'ThePrimeagen/vim-be-good'})
end)
