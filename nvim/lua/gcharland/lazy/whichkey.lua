return {
    "folke/which-key.nvim",
    event = "VeryLazy",
    init = function()
        vim.o.timeout = true
        vim.o.timeoutlen = 300 -- Temps en millisecondes avant l'apparition du menu
    end,
    config = function()
    local wk = require("which-key")
    
    -- C'est ici qu'on nomme les groupes de raccourcis !
    wk.add({
      { "<leader>f", group = "Recherche (Telescope)" }, -- Nomme le menu <leader>f
      { "<leader>g", group = "Git" },                   -- Nomme le menu <leader>g
    })
  end
}
