local opts = {
  noremap = true,
}

local function setAddToHarpoon(harpoon)
  vim.keymap.set("n", "<leader>a", function()
    local bufname = vim.fn.expand("%:t")
    harpoon:list():add()

    vim.notify(
      "Buffer " .. bufname .. " bol pridaný do Harpoon. ✔",
      vim.log.levels.INFO,
      { title = "Harpoon Pridanie" }
    )
  end, opts)
end

local function setOpenHarpoon(harpoon)
  vim.keymap.set("n", "<leader>g", function()
    harpoon.ui:toggle_quick_menu(harpoon:list())
  end, opts)
end

local function setKeyboardShortcuts(harpoon)
  setAddToHarpoon(harpoon) -- <leader>a
  setOpenHarpoon(harpoon) -- <leader>g
end

return {
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    opts = {
      menu = {
        width = vim.api.nvim_win_get_width(0) - 4,
      },
      settings = {
        save_on_toggle = true,
      },
    },
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local harpoon = require("harpoon")
      harpoon:setup()
      setKeyboardShortcuts(harpoon)
    end,
  },
}
