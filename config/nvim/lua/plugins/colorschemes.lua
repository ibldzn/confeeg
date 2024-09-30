return {
  {
    "Mofiqul/vscode.nvim",
    lazy = false,
    config = function()
      vim.cmd.colorscheme("vscode")
    end,
  },

  {
    "catppuccin/nvim",
    lazy = false,
    name = "catppuccin",
    -- config = function()
    --   vim.cmd.colorscheme("catppuccin")
    -- end,
  },
}
