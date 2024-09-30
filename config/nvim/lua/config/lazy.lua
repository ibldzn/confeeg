local M = {}

function M.setup()
  local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

  if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
      "git",
      "clone",
      "--filter=blob:none",
      "--single-branch",
      "https://github.com/folke/lazy.nvim.git",
      lazypath,
    })
  end

  vim.opt.runtimepath:prepend(lazypath)

  require("lazy").setup({
    debug = false,
    spec = {
      { import = "plugins" },
      { import = "plugins.lsp.langs" },
      { import = "plugins.formatters" },
      -- { import = "plugins.extras.editor" },
    },
    defaults = { lazy = true },
    checker = { enabled = true },
    performance = {
      cache = {
        enabled = true,
      },
      rtp = {
        disabled_plugins = {
          "2html_plugin",
          "getscript",
          "getscriptPlugin",
          "gzip",
          "logipat",
          "matchit",
          "matchparen",
          "netrw",
          "netrwFileHandlers",
          "netrwPlugin",
          "netrwSettings",
          "rrhelper",
          "spellfile_plugin",
          "tar",
          "tarPlugin",
          "tohtml",
          "tutor",
          "vimball",
          "vimballPlugin",
          "zip",
          "zipPlugin",
        },
      },
    },
  })
end

return M
