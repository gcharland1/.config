AvailableColorSchemes = {
    "rose-pine",
    "catppuccin-mocha",
}

local background = "#1e1d2b"

require("catppuccin").setup({
    color_overrides = {
        mocha = {
            base = background,
        },
    }
})

require("rose-pine").setup({
    variant = "moon",
    groups = {
        background = background,
    },
})

vim.cmd(string.format("colorscheme %s", AvailableColorSchemes[1]))

-- Change colorscheme with <leader>cc
function ColorNext()
    local currentColor = vim.api.nvim_exec2("colorscheme", {output = true})
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
