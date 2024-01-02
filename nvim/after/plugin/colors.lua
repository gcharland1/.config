--@Todo: Get actual list from command colorscheme <c-d>
AvailableColorSchemes = {
    "rose-pine",
    "catppuccin-mocha",
    --"catppuccin-frappe",
    --"catppuccin-macchiato",
    --"everforest",
    --"apprentice",
    --"jellybeans",
    --"tender",
    --"onedark",
}

require("catppuccin").setup({
    color_overrides = {
        mocha = {
            base = "#1f1f26",
        },
    }
})

-- Change colorscheme
function ColorNext()
    local currentColor = vim.api.nvim_exec('colorscheme', true)
    print("Current colorscheme: "..currentColor)
    local nextColor = 1
    for i, cs in pairs(AvailableColorSchemes) do
        if cs == currentColor then
            nextColor = (i+1 <= #AvailableColorSchemes and i+1 or 1)
        end
    end
    print("New theme: "..AvailableColorSchemes[nextColor])
    return vim.cmd(string.format("colorscheme %s", AvailableColorSchemes[nextColor]))
end

vim.keymap.set("n", "<leader>cc", function() ColorNext() end)
vim.cmd(string.format("colorscheme %s", AvailableColorSchemes[1]))
