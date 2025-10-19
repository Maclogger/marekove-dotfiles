return {
  "karb94/neoscroll.nvim",
  event = "WinScrolled", -- Alebo 'VeryLazy' podľa vašej preferencie
  config = function()
    require("neoscroll").setup({
      -- Definujte mapovania, ktoré chcete plynule scrollovať
      mappings = { "<C-u>", "<C-d>" },
      easing_function = "linear", -- Typ easing funkcie
      -- Môžete pridať ďalšie nastavenia podľa potreby
      hide_cursor = true, -- Skrýva kurzor počas animácie
      stop_eof = true, -- Zastaví animáciu na konci súboru
      use_local_scrolloff = false, -- Používa globálny scrolloff
      respect_scrolloff = false, -- Ignoruje scrolloff pri posúvaní
      cursor_scrolls_alone = true, -- Posúva kurzor samostatne
    })
  end,
}
