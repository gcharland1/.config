AvailableColorSchemes = {
    "rose-pine",
}

local light_background = "#2b2b2b"
local dark_background = "#1a1a1a"
local cursorLineColor = "#3a3a3a"
local colorColumnColor = "#444444"

function SetupColorscheme()
    local background = (tonumber(os.date("%H")) > 16 and dark_background or light_background)
    require("rose-pine").setup({
        variant = "moon",
        groups = {
            background = background,
        },
        highlight_groups = {
            ['CursorLine'] = { bg = cursorLineColor },
            ['ColorColumn'] = { bg = colorColumnColor },
        }
    })
end

-- Change colorscheme with <leader>cc
function ColorNext()
    local currentColor = vim.api.nvim_exec2("colorscheme", {output = true})["output"]
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

SetupColorscheme()
vim.cmd(string.format("colorscheme %s", AvailableColorSchemes[1]))
vim.keymap.set("n", "<leader>cc", function() SetupColorscheme() end)
