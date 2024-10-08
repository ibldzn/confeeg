local map = vim.keymap.set

-- better up/down
map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })
map({ "n", "x" }, "<Down>", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
map({ "n", "x" }, "<Up>", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })

-- move Lines
map("n", "<a-d>", "<cmd>m .+1<cr>==", { desc = "Move Down" })
map("n", "<a-u>", "<cmd>m .-2<CR>==", { desc = "Move Up" })
map("i", "<a-d>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move Down" })
map("i", "<a-u>", "<esc><cmd>m .-2<CR>==gi", { desc = "Move Up" })
map("v", "<a-d>", "<cmd>m '>+1<cr>gv=gv", { desc = "Move Down" })
map("v", "<a-u>", ":cmd>m '<-2<cr>gv=gv", { desc = "Move Up" })

-- navigate in insert mode
map("i", "<c-h>", "<left>", { desc = "Left" })
map("i", "<c-j>", "<down>", { desc = "Down" })
map("i", "<c-k>", "<up>", { desc = "Up" })
map("i", "<c-l>", "<right>", { desc = "Right" })
map("i", "<c-a>", "<home>", { desc = "Move to The Beginning of Current Line" })
map("i", "<c-e>", "<end>", { desc = "Move to The End of Current Line" })

-- register stuff insert mode
map("i", "<c-r>", "<c-r><c-o>", { desc = "Insert Register Literally" })
map("i", "<c-v>", "<c-r><c-o>+", { desc = "Paste System Clipboard" })

-- save
map("n", "<c-s>", "<cmd>w<cr>", { desc = "Save File" })
map("i", "<c-s>", "<esc><cmd>w<cr>a", { desc = "Save File" })

-- other
map("n", "<esc>", "<cmd>nohlsearch<cr>", { desc = "Clear Search Highlights" })

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
map("n", "<leader>ww", "<c-w>p", { desc = "Other Window", remap = true })
map("n", "<leader>wc", "<c-w>c", { desc = "Delete Window", remap = true })
map("n", "<leader>w-", "<c-w>s", { desc = "Split Window Below", remap = true })
map("n", "<leader>w|", "<c-w>v", { desc = "Split Window Right", remap = true })

-- buffers
map("n", "<leader><space>", "<c-^>", { desc = "Alternate buffer" })
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
