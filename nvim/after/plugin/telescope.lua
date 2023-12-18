local builtin = require('telescope.builtin')

local function find_git_files_with_fallback()
    local function is_git_repo()
        vim.fn.system("git rev-parse --is-inside-work-tree")
        return vim.v.shell_error == 0
    end
    if is_git_repo() then
        builtin.git_files()
    else
        builtin.find_files()
    end
end

-- Find files
vim.keymap.set('n', '<leader>ff', find_git_files_with_fallback)
vim.keymap.set('n', '<leader>fF', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.git_files, {})
vim.keymap.set('n', '<leader>f.', function() builtin.find_files({ cwd = vim.fn.expand('%:p:h') }) end)
-- Find in files
vim.keymap.set('n', '<leader>f/', builtin.live_grep, {})
vim.keymap.set('n', '<leader>/', builtin.grep_string)
