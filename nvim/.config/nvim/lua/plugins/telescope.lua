local opts = {
  noremap = true,
  silent = true,
  desc = "Search Everywhere",
}

function SearchEverywhere()
  require("telescope.builtin").grep_string({
    search = "",
  })
end

local function setKeyMaps()
  vim.keymap.set("n", "<leader>ff", SearchEverywhere, opts)
end

local function config()
  require("telescope").setup({})
  setKeyMaps()
end

return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = config,
  },
}
