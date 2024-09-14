return {
  {
    "smjonas/inc-rename.nvim",
    cmd = "IncRename",
    opts = {},
  },

  -- LSP Keymaps
  {
    "neovim/nvim-lspconfig",
    opts = function()
      local keys = require("plugins.lsp.mappings").get()
      keys[#keys + 1] = {
        "<leader>cr",
        function()
          local inc_rename = require("inc_rename")
          return ":" .. inc_rename.config.cmd_name .. " " .. vim.fn.expand("<cword>")
        end,
        expr = true,
        desc = "Rename (inc-rename.nvim)",
        has = "rename",
      }
    end,
  },
}
