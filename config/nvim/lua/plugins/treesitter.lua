return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    cmd = { "TSInstall", "TSUpdate", "TSUpdateSync" },
    lazy = vim.fn.argc(-1) == 0, -- load treesitter early when opening a file from the cmdline
    event = { "LazyFile", "VeryLazy" },
    init = function(plugin)
      require("lazy.core.loader").add_to_rtp(plugin)
      require("nvim-treesitter.query_predicates")
    end,
    keys = {
      { "<cr>", desc = "Increment Selection" },
      { "<s-tab>", desc = "Decrement Selection", mode = "x" },
    },
    opts = {
      highlight = { enable = true },
      indent = { enable = true },
      ensure_installed = {
        "bash",
        "c",
        "diff",
        "html",
        "javascript",
        "jsdoc",
        "json",
        "jsonc",
        "lua",
        "luadoc",
        "luap",
        "markdown",
        "markdown_inline",
        "printf",
        "python",
        "query",
        "regex",
        "toml",
        "tsx",
        "typescript",
        "vim",
        "vimdoc",
        "xml",
        "yaml",
      },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<cr>",
          node_incremental = "<tab>",
          scope_incremental = false,
          node_decremental = "<s-tab>",
        },
      },
      textobjects = {
        select = {
          enable = true,
          lookahead = true,
          keymaps = {
            ["ac"] = { query = "@call.outer", desc = "around function call" },
            ["ic"] = { query = "@call.inner", desc = "inner function call" },
            ["al"] = { query = "@loop.outer", desc = "around loop" },
            ["il"] = { query = "@loop.inner", desc = "inner loop" },
            ["af"] = { query = "@function.outer", desc = "around function" },
            ["if"] = { query = "@function.inner", desc = "inner function" },
            ["aC"] = { query = "@conditional.outer", desc = "around conditional" },
            ["iC"] = { query = "@conditional.inner", desc = "inner conditional" },
          },
          selection_modes = {
            ["@parameter.outer"] = "v", -- charwise
            ["@function.outer"] = "V", -- linewise
            ["@class.outer"] = "<c-v>", -- blockwise
          },
        },
        lsp_interop = {
          enable = true,
          peek_definition_code = {
            ["<leader>k"] = "@function.outer",
            ["<leader>K"] = "@class.outer",
          },
        },
        move = {
          enable = true,
          goto_next_start = { ["]f"] = "@function.outer", ["]c"] = "@class.outer", ["]a"] = "@parameter.inner" },
          goto_next_end = { ["]F"] = "@function.outer", ["]C"] = "@class.outer", ["]A"] = "@parameter.inner" },
          goto_previous_start = { ["[f"] = "@function.outer", ["[c"] = "@class.outer", ["[a"] = "@parameter.inner" },
          goto_previous_end = { ["[F"] = "@function.outer", ["[C"] = "@class.outer", ["[A"] = "@parameter.inner" },
        },
      },
    },
    opts_extend = { "ensure_installed" },
    config = function(_, opts)
      -- if type(opts.ensure_installed) == "table" then
      --   opts.ensure_installed = CangsVim.dedup(opts.ensure_installed)
      -- end
      require("nvim-treesitter.configs").setup(opts)
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    event = "VeryLazy",
    enabled = true,
    config = function()
      -- If treesitter is already loaded, we need to run config again for textobjects
      -- if CangsVim.is_loaded("nvim-treesitter") then
      --   local opts = CangsVim.opts("nvim-treesitter")
      --   require("nvim-treesitter.configs").setup({ textobjects = opts.textobjects })
      -- end

      -- When in diff mode, we want to use the default
      -- vim text objects c & C instead of the treesitter ones.
      local move = require("nvim-treesitter.textobjects.move") ---@type table<string,fun(...)>
      local configs = require("nvim-treesitter.configs")
      for name, fn in pairs(move) do
        if name:find("goto") == 1 then
          move[name] = function(q, ...)
            if vim.wo.diff then
              local config = configs.get_module("textobjects.move")[name] ---@type table<string,string>
              for key, query in pairs(config or {}) do
                if q == query and key:find("[%]%[][cC]") then
                  vim.cmd("normal! " .. key)
                  return
                end
              end
            end
            return fn(q, ...)
          end
        end
      end
    end,
  },

  {
    "windwp/nvim-ts-autotag",
    event = "LazyFile",
    opts = {},
  },

  {
    "nvim-treesitter/nvim-treesitter-context",
    event = "LazyFile",
    opts = {
      mode = "topline",
      truncate_side = "outer",
      max_lines = 2,
      categories = {
        default = {
          ["if"] = false,
          ["switch"] = false,
          ["loop"] = false,
          ["lambda"] = false,
        },
      },
    },
  },
}

