local keymap = vim.keymap

-- Control Backspace to remove the whole word
keymap.set("i", "<C-BS>", "<C-w>")

-- Increment/decrement
keymap.set("n", "+", "<C-a>")
keymap.set("n", "-", "<C-x>")
keymap.set("n", "<C-a>", "gg<S-v>G")

-- Save File with Notification
keymap.set("n", "<C-s>", function()
  vim.cmd("w")
  vim.notify("Saved", vim.log.levels.INFO)
end)

-- Rename
vim.keymap.set("n", "<F2>", function()
  vim.lsp.buf.rename()
end, { noremap = true, silent = true, desc = "Rename Symbol" })

local function harpoon_select_safe(index)
  ---@diagnostic disable-next-line: unused-local
  local ok, err = pcall(function()
    require("harpoon"):list():select(index)
  end)
end

-- Harpoon
vim.keymap.del("n", "<leader>l") -- deleting default LazyVim keymap

vim.keymap.set("n", "<leader>h", function()
  harpoon_select_safe(1)
end, { desc = "Harpoon select 1" })

vim.keymap.set("n", "<leader>j", function()
  harpoon_select_safe(2)
end, { desc = "Harpoon select 2" })

vim.keymap.set("n", "<leader>k", function()
  harpoon_select_safe(3)
end, { desc = "Harpoon select 3" })

vim.keymap.set("n", "<leader>l", function()
  harpoon_select_safe(4)
end, { desc = "Harpoon select 4" })

vim.keymap.set("n", "<leader>ô", function()
  harpoon_select_safe(5)
end, { desc = "Harpoon select 5" })

--[[ vim.keymap.del("n", "<S-H>")
vim.keymap.del("n", "<S-L>")

vim.keymap.set("n", "<S-H>", function()
  require("harpoon"):list():prev()
end)
vim.keymap.set("n", "<S-L>", function()
  require("harpoon"):list():next()
end) ]]

-- errors / warnings
local diagnostic_goto = function(next, severity)
  ---@diagnostic disable-next-line: deprecated
  local go = next and vim.diagnostic.goto_next or vim.diagnostic.goto_prev
  severity = severity and vim.diagnostic.severity[severity] or nil
  return function()
    go({ severity = severity })
  end
end
vim.keymap.set("n", "äd", diagnostic_goto(true), { desc = "Next Diagnostic" })
vim.keymap.set("n", "úd", diagnostic_goto(false), { desc = "Prev Diagnostic" })
vim.keymap.set("n", "äe", diagnostic_goto(true, "ERROR"), { desc = "Next Error" })
vim.keymap.set("n", "úe", diagnostic_goto(false, "ERROR"), { desc = "Prev Error" })
vim.keymap.set("n", "äw", diagnostic_goto(true, "WARN"), { desc = "Next Warning" })
vim.keymap.set("n", "úw", diagnostic_goto(false, "WARN"), { desc = "Prev Warning" })

-- disable annoying Shift-J
vim.keymap.set("n", "J", "<nop>", { noremap = true, silent = true, desc = "Disable join line" })
vim.keymap.set("n", "<S-J>", "<nop>", { noremap = true, silent = true, desc = "Disable Shift+J join line" })
vim.keymap.set("v", "J", "<nop>", { noremap = true, silent = true, desc = "Disable join line" })
vim.keymap.set("v", "<S-J>", "<nop>", { noremap = true, silent = true, desc = "Disable Shift+J join line" })

-- window splits
vim.keymap.set("n", "sv", ":vsplit<CR>") -- vertical split
vim.keymap.set("n", "sh", ":split<CR>") -- horizontal split

-- show usages = go refereces
--vim.keymap.set("n", "su", "<cmd>Telescope lsp_references<cr>", { desc = "References", nowait = true })
vim.keymap.set("n", "su", function()
  Snacks.picker.lsp_references()
end, { desc = "References", nowait = true })

-- close current buffer ("tab" on top)
vim.keymap.set("n", "<C-w>", function()
  Snacks.bufdelete()
end, { desc = "Delete Buffer" })
