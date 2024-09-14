local map = vim.keymap.set

-- better up/down
map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })
map({ "n", "x" }, "<Down>", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
map({ "n", "x" }, "<Up>", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })

-- move Lines
map("n", "<A-d>", "<cmd>m .+1<cr>==", { desc = "Move Down" })
map("n", "<A-u>", "<cmd>m .-2<CR>==", { desc = "Move Up" })
map("i", "<A-d>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move Down" })
map("i", "<A-u>", "<esc><cmd>m .-2<CR>==gi", { desc = "Move Up" })
map("v", "<A-d>", "<cmd>m '>+1<cr>gv=gv", { desc = "Move Down" })
map("v", "<A-u>", ":cmd>m '<-2<cr>gv=gv", { desc = "Move Up" })

-- navigate in insert mode
map("i", "<C-h>", "<Left>", { desc = "Left" })
map("i", "<C-j>", "<Down>", { desc = "Down" })
map("i", "<C-k>", "<Up>", { desc = "Up" })
map("i", "<C-l>", "<Right>", { desc = "Right" })
map("i", "<C-a>", "<esc>^i", { desc = "Move to the beginning of current line" })
map("i", "<C-e>", "<end>", { desc = "Move to the end of current line" })

-- register stuff insert mode
map("i", "<C-r>", "<C-r><C-o>", { desc = 'Insert register "literally"' })
map("i", "<C-v>", "<C-r><C-o>+", { desc = "Paste system clipboard" })

-- save
map("n", "<C-s>", "<cmd>w<cr>", { desc = "Save file" })
map("i", "<C-s>", "<esc><cmd>w<cr>a", { desc = "Save file" })

-- other
map("n", "<esc>", "<cmd>nohlsearch<cr>", { desc = "Clear search highlights" })

-- https://github.com/mhinz/vim-galore#saner-behavior-of-n-and-n
map("n", "n", "'Nn'[v:searchforward].'zv'", { expr = true, desc = "Next Search Result" })
map("x", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next Search Result" })
map("o", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next Search Result" })
map("n", "N", "'nN'[v:searchforward].'zv'", { expr = true, desc = "Prev Search Result" })
map("x", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev Search Result" })
map("o", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev Search Result" })

-- Add undo break-points
for _, ch in ipairs({ ",", ".", ";", ":", "->" }) do
  map("i", ch, ch .. "<c-g>u")
end

-- better indenting
map("v", "<", "<gv")
map("v", ">", ">gv")

-- diagnostic
local diagnostic_goto = function(next, severity)
  local go = next and vim.diagnostic.goto_next or vim.diagnostic.goto_prev
  severity = severity and vim.diagnostic.severity[severity] or nil
  return function()
    go({ severity = severity })
  end
end
map("n", "]d", diagnostic_goto(true), { desc = "Next Diagnostic" })
map("n", "[d", diagnostic_goto(false), { desc = "Prev Diagnostic" })
map("n", "]e", diagnostic_goto(true, "ERROR"), { desc = "Next Error" })
map("n", "[e", diagnostic_goto(false, "ERROR"), { desc = "Prev Error" })
map("n", "]w", diagnostic_goto(true, "WARN"), { desc = "Next Warning" })
map("n", "[w", diagnostic_goto(false, "WARN"), { desc = "Prev Warning" })

-- tabs
map("n", "<leader><tab>]", "<cmd>tabnext<cr>", { desc = "Next Tab" })
map("n", "<leader><tab>[", "<cmd>tabnext<cr>", { desc = "Prev Tab" })
map("n", "<leader><tab>o", "<cmd>tabonly<cr>", { desc = "Close Other Tabs" })
map("n", "<leader><tab>f", "<cmd>tabfirst<cr>", { desc = "First Tab" })
map("n", "<leader><tab>l", "<cmd>tablast<cr>", { desc = "Last Tab" })

-- windows
map("n", "<leader>ww", "<C-W>p", { desc = "Other Window", remap = true })
map("n", "<leader>wc", "<C-W>c", { desc = "Delete Window", remap = true })
map("n", "<leader>-", "<C-W>s", { desc = "Split Window Below", remap = true })
map("n", "<leader>|", "<C-W>v", { desc = "Split Window Right", remap = true })

-- buffers
map("n", "<leader><space>", "<C-^>", { desc = "Alternate buffer" })
map("n", "[b", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })
map("n", "]b", "<cmd>bnext<cr>", { desc = "Next Buffer" })

-- put empty line on black hole register on dd
map("n", "dd", function()
  return vim.api.nvim_get_current_line():match("^%s*$") and '"_dd' or "dd"
end, { noremap = true, expr = true, desc = "Smart dd" })

-- center first search result
map("c", "<cr>", function()
  local cmdtype = vim.fn.getcmdtype()
  if cmdtype == "/" or cmdtype == "?" then
    return "<cr>zzzv"
  else
    return "<cr>"
  end
end, { noremap = true, expr = true, desc = "Center first search result" })
