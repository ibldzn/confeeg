vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.g.autoformat = true

-- root dir detection
-- Each entry can be:
-- * the name of a detector function like `lsp` or `cwd`
-- * a pattern or array of patterns like `.git` or `lua`.
-- * a function with signature `function(buf) -> string|string[]`
vim.g.root_spec = { "lsp", { ".git", "lua" }, "cwd" }

vim.g.cangsvim_statuscolumn = {
  folds_open = false, -- show fold sign when fold is open
  folds_githl = false, -- highlight fold sign with git sign color
}

vim.g.cmp_widths = {
  abbr = 40,
  menu = 30,
}

-- Set filetype to `bigfile` for files larger than 1.5 MB
-- Only vim syntax will be enabled (with the correct filetype)
-- LSP, treesitter and other ft plugins will be disabled.
-- mini.animate will also be disabled.
vim.g.bigfile_size = 1024 * 1024 * 1.5 -- 1.5 MB

-- Show the current document symbols location from Trouble in lualine
vim.g.trouble_lualine = true

vim.g.loaded_python_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_node_provider = 0

vim.g.markdown_recommended_style = 0

local opt = vim.opt

if not vim.env.SSH_TTY then
  opt.clipboard:append("unnamedplus")
end

opt.background = "dark"
opt.backspace = "indent,eol,start"
opt.cmdheight = 1
opt.compatible = false
opt.completeopt = "menu,menuone,noselect"
opt.completeopt = { "menuone", "noinsert", "noselect" }
opt.confirm = true
opt.confirm = true
opt.cursorline = true
opt.cursorline = true
opt.cursorlineopt = "number"
opt.expandtab = true
opt.fillchars:append({
  horiz = "─",
  vert = "│",
  foldopen = "",
  foldclose = "",
  fold = " ",
  foldsep = " ",
  diff = "╱",
  eob = " ",
})
opt.formatoptions:remove("c")
opt.formatoptions:remove("r")
opt.formatoptions:remove("o")
opt.grepformat = "%f:%l:%c:%m"
opt.grepprg = "rg --vimgrep"
opt.guifont = "monospace:h11"
opt.ignorecase = true
opt.inccommand = "nosplit"
opt.laststatus = 3
opt.mouse = "a"
opt.number = true
opt.relativenumber = true
opt.scrolloff = 5
opt.shiftwidth = 4
opt.showbreak = "⮡ "
opt.showtabline = 0
opt.sidescroll = 1
opt.sidescrolloff = 5
opt.signcolumn = "number"
opt.splitbelow = true
opt.splitkeep = "screen"
opt.splitright = true
opt.swapfile = true
opt.title = true
opt.undofile = true
opt.undodir = vim.fn.stdpath("data") .. "/undo"
opt.undolevels = 10000
opt.updatetime = 200 -- Save swap file and trigger CursorHold
opt.wrap = true
opt.hlsearch = true
opt.incsearch = true
opt.ignorecase = true
opt.smartcase = true
opt.expandtab = true
opt.shiftwidth = 4
opt.tabstop = 4
opt.termguicolors = true
opt.timeoutlen = vim.g.vscode and 1000 or 300 -- Lower than default (1000) to quickly trigger which-key
opt.virtualedit = "block" -- Allow cursor to move where there is no text in visual block mode
opt.wildmode = "longest:full,full" -- Command-line completion mode
opt.winminwidth = 5 -- Minimum window width
opt.smartindent = true
opt.hidden = true
opt.history = 100
opt.synmaxcol = 240
opt.updatetime = 700 -- ms to wait for trigger an event
opt.shortmess:append("sIcC")
opt.whichwrap:append("<>[]hl")

local default_plugins = {
  "2html_plugin",
  "getscript",
  "getscriptPlugin",
  "gzip",
  "logipat",
  "netrw",
  "netrwPlugin",
  "netrwSettings",
  "netrwFileHandlers",
  "matchit",
  "tar",
  "tarPlugin",
  "rrhelper",
  "spellfile_plugin",
  "vimball",
  "vimballPlugin",
  "zip",
  "zipPlugin",
}

for _, plugin in pairs(default_plugins) do
  vim.g["loaded_" .. plugin] = 1
end

if vim.fn.has("nvim-0.10") == 1 then
  opt.smoothscroll = true
  opt.foldexpr = "v:lua.require'util'.ui.foldexpr()"
  opt.foldmethod = "expr"
  opt.foldtext = ""
else
  opt.foldmethod = "indent"
  opt.foldtext = "v:lua.require'util'.ui.foldtext()"
end
