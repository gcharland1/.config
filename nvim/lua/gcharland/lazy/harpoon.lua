return {
  'ThePrimeagen/harpoon',
  branch = 'master', -- or, branch = '0.1.x',
  dependencies = { 'nvim-lua/plenary.nvim' },
  config = function()
    -- require('harpoon').setup({})

    local mark = require('harpoon.mark')
    local ui = require('harpoon.ui')

    vim.keymap.set('n', '<leader><leader>h', require("harpoon.mark").add_file(), {})
    vim.keymap.set('n', '<leader><tab>', require("harpoon.ui").toggle_quick_menu(), {})
    vim.keymap.set('n', '<leader>1', require("harpoon.ui").nav_file(1), {})
    vim.keymap.set('n', '<leader>2', require("harpoon.ui").nav_file(2), {})
    vim.keymap.set('n', '<leader>3', require("harpoon.ui").nav_file(3), {})
    vim.keymap.set('n', '<leader>4', require("harpoon.ui").nav_file(4), {})
    vim.keymap.set('n', '<leader>5', require("harpoon.ui").nav_file(5), {})
    vim.keymap.set('n', '<leader>6', require("harpoon.ui").nav_file(6), {})
  end
}
