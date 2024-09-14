return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    cmd = "Neotree",
    dependencies = {
      { "MunifTanjim/nui.nvim" },
      { "nvim-lua/plenary.nvim" },
    },
    keys = {
      {
        "<a-n>",
        function()
          require("neo-tree.command").execute({ toggle = true, reveal_force_cwd = true })
        end,
        desc = "Explorer NeoTree (Root Dir)",
      },
    },
    init = function()
      -- FIX: use `autocmd` for lazy-loading neo-tree instead of directly requiring it,
      -- because `cwd` is not set up properly.
      vim.api.nvim_create_autocmd("BufEnter", {
        group = vim.api.nvim_create_augroup("Neotree_start_directory", { clear = true }),
        desc = "Start Neo-tree with directory",
        once = true,
        callback = function()
          if package.loaded["neo-tree"] then
            return
          else
            local stats = vim.uv.fs_stat(vim.fn.argv(0))
            if stats and stats.type == "directory" then
              require("neo-tree")
            end
          end
        end,
      })
    end,
    opts = {
      sources = { "filesystem", "buffers", "git_status" },
      open_files_do_not_replace_types = { "terminal", "Trouble", "trouble", "qf", "Outline" },
      filesystem = {
        bind_to_cwd = false,
        follow_current_file = { enabled = true },
        use_libuv_file_watcher = true,
      },
      window = {
        width = 30,
        position = "right",
        mappings = {
          ["q"] = "open",
          ["h"] = "close_node",
          ["<space>"] = "none",
          ["Y"] = {
            function(state)
              local node = state.tree:get_node()
              local path = node:get_id()
              vim.fn.setreg("+", path, "c")
            end,
            desc = "Copy Path to Clipboard",
          },
          ["O"] = {
            function(state)
              require("lazy.util").open(state.tree:get_node().path, { system = true })
            end,
            desc = "Open with System Application",
          },
          ["P"] = { "toggle_preview", config = { use_float = false } },
        },
      },
      default_component_configs = {
        indent = {
          with_expanders = true, -- if nil and file nesting is enabled, will enable expanders
          expander_collapsed = "",
          expander_expanded = "",
          expander_highlight = "NeoTreeExpander",
        },
        git_status = {
          symbols = {
            unstaged = "󰄱",
            staged = "󰱒",
          },
        },
      },
    },
    config = function(_, opts)
      -- local function on_move(data)
      --   LazyVim.lsp.on_rename(data.source, data.destination)
      -- end

      -- local events = require("neo-tree.events")
      -- opts.event_handlers = opts.event_handlers or {}
      -- vim.list_extend(opts.event_handlers, {
      --   { event = events.FILE_MOVED, handler = on_move },
      --   { event = events.FILE_RENAMED, handler = on_move },
      -- })
      require("neo-tree").setup(opts)
      vim.api.nvim_create_autocmd("TermClose", {
        pattern = "*lazygit",
        callback = function()
          if package.loaded["neo-tree.sources.git_status"] then
            require("neo-tree.sources.git_status").refresh()
          end
        end,
      })
    end,
  },

  {
    "mrjones2014/smart-splits.nvim",
    event = "WinNew",
    opts = {},
    dependencies = {
      "sindrets/winshift.nvim",
      opts = {},
      keys = { { "<c-w>W", "<cmd>WinShift<CR>", desc = "Winshift" } },
    },
    keys = {
      { "<c-h>", "<cmd>SmartCursorMoveLeft<CR>", desc = "Move to left split" },
      { "<c-j>", "<cmd>SmartCursorMoveDown<CR>", desc = "Move to below split" },
      { "<c-k>", "<cmd>SmartCursorMoveUp<CR>", desc = "Move to above split" },
      { "<c-l>", "<cmd>SmartCursorMoveRight<CR>", desc = "Move to right split" },

      { "<a-h>", "<cmd>SmartResizeLeft<CR>", desc = "Resize left split" },
      { "<a-j>", "<cmd>SmartResizeDown<CR>", desc = "Resize below split" },
      { "<a-k>", "<cmd>SmartResizeUp<CR>", desc = "Resize above split" },
      { "<a-l>", "<cmd>SmartResizeRight<CR>", desc = "Resize right split" },
    },
  },
}
