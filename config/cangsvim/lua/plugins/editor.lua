return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    keys = {
      { "<A-n>", "<cmd>Neotree toggle reveal_force_cwd<CR>", desc = "Neotree" },
    },
    opts = {
      enable_git_status = false,
      window = {
        width = 30,
        position = "right",
        mappings = {
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
      filesystem = {
        filtered_items = {
          hide_dotfiles = false,
        },
      },
    },
    init = function()
      vim.g.neo_tree_remove_legacy_commands = true

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
    config = function(_, opts)
      local function on_move(data)
        CangsVim.lsp.on_rename(data.source, data.destination)
      end

      local events = require("neo-tree.events")
      opts.event_handlers = opts.event_handlers or {}
      vim.list_extend(opts.event_handlers, {
        { event = events.FILE_MOVED, handler = on_move },
        { event = events.FILE_RENAMED, handler = on_move },
      })

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
    "nvim-pack/nvim-spectre",
    build = false,
    cmd = "Spectre",
    opts = { open_cmd = "noswapfile vnew" },
    -- stylua: ignore
    keys = {
      { "<leader>sr", function() require("spectre").open() end, desc = "Replace in Project (Spectre)" },
      { "<leader>sf", function() require("spectre").open_file_search() end, desc = "Replace in File (Spectre)" },
      { "<leader>sr", function() require("spectre").open_visual({ select_word = true }) end, mode = "v", desc = "Replace in Project (Spectre)" },
      { "<leader>sf", function() require("spectre").open_visual({ path = vim.fn.expand("%"), select_word = true }) end, mode = "v", desc = "Replace in File (Spectre)" },
    },
  },

  -- git signs highlights text that has changed since the list
  -- git commit, and also lets you interactively stage & unstage
  -- hunks in a commit.
  {
    "lewis6991/gitsigns.nvim",
    event = "LazyFile",
    opts = {
      signs = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "" },
        topdelete = { text = "" },
        changedelete = { text = "▎" },
        untracked = { text = "▎" },
      },
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
        end

        -- stylua: ignore start
        map("n", "]h", function() gs.nav_hunk("next") end, "Next Hunk")
        map("n", "[h", function() gs.nav_hunk("prev") end, "Prev Hunk")
        map({ "n", "v" }, "<leader>gs", ":Gitsigns stage_hunk<CR>", "Stage Hunk")
        map({ "n", "v" }, "<leader>gr", ":Gitsigns reset_hunk<CR>", "Reset Hunk")
        map("n", "<leader>gS", gs.stage_buffer, "Stage Buffer")
        map("n", "<leader>gu", gs.undo_stage_hunk, "Undo Stage Hunk")
        map("n", "<leader>gR", gs.reset_buffer, "Reset Buffer")
        map("n", "<leader>gp", gs.preview_hunk_inline, "Preview Hunk Inline")
        map("n", "<leader>gb", function() gs.blame_line({ full = true }) end, "Blame Line")
        map("n", "<leader>gd", gs.diffthis, "Diff This")
        map("n", "<leader>gD", function() gs.diffthis("~") end, "Diff This ~")
        map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "GitSigns Select Hunk")
      end,
    },
  },

  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts_extend = { "spec" },
    opts = {
      plugins = { spelling = true },
      spec = {
        mode = { "n", "v" },
        { "<leader><tab>", group = "tabs" },
        { "<leader>c", group = "code" },
        { "<leader>f", group = "file/find" },
        { "<leader>g", group = "git" },
        { "<leader>h", group = "hunks" },
        { "<leader>q", group = "quit/session" },
        { "<leader>s", group = "search" },
        { "<leader>u", group = "ui" },
        { "<leader>x", group = "diagnostics/quickfix" },
        { "[", group = "prev" },
        { "]", group = "next" },
        { "g", group = "goto" },
        { "ys", group = "surround" },
        { "z", group = "fold" },
        {
          "<leader>b",
          group = "buffer",
          expand = function()
            return require("which-key.extras").expand.buf()
          end,
        },
        {
          "<leader>w",
          group = "windows",
          proxy = "<c-w>",
          expand = function()
            return require("which-key.extras").expand.win()
          end,
        },
        -- better descriptions
        { "gx", desc = "Open with system app" },
      },
    },
    keys = {
      {
        "<leader>?",
        function()
          require("which-key").show({ global = false })
        end,
        desc = "Buffer Keymaps (which-key)",
      },
      {
        "<c-w><space>",
        function()
          require("which-key").show({ keys = "<c-w>", loop = true })
        end,
        desc = "Window Hydra Mode (which-key)",
      },
    },
    config = function(_, opts)
      local wk = require("which-key")
      wk.setup(opts)
    end,
  },

  {
    "mrjones2014/smart-splits.nvim",
    event = "WinNew",
    opts = {},
    dependencies = {
      {
        "sindrets/winshift.nvim",
        opts = {},
        keys = { { "<C-w>W", "<cmd>WinShift<cr>", desc = "Winshift" } },
      },
    },
    keys = {
      { "<C-h>", "<cmd>SmartCursorMoveLeft<CR>", desc = "Move to left split" },
      { "<C-j>", "<cmd>SmartCursorMoveDown<CR>", desc = "Move to below split" },
      { "<C-k>", "<cmd>SmartCursorMoveUp<CR>", desc = "Move to above split" },
      { "<C-l>", "<cmd>SmartCursorMoveRight<CR>", desc = "Move to right split" },

      { "<A-h>", "<cmd>SmartResizeLeft<CR>", desc = "Resize left split" },
      { "<A-j>", "<cmd>SmartResizeDown<CR>", desc = "Resize below split" },
      { "<A-k>", "<cmd>SmartResizeUp<CR>", desc = "Resize above split" },
      { "<A-l>", "<cmd>SmartResizeRight<CR>", desc = "Resize right split" },
    },
  },

  {
    "phaazon/hop.nvim",
    keys = {
      { "s", desc = "Hop" },
      { "sc", "<cmd>HopChar1<CR>", desc = "Char" },
      { "sC", "<cmd>HopChar2<CR>", desc = "2 Chars" },
      { "sl", "<cmd>HopLine<CR>", desc = "Line" },
      { "sL", "<cmd>HopLineStart<CR>", desc = "Line start" },
      { "ss", "<cmd>HopWord<CR>", desc = "Words" },
    },
    opts = {},
  },

  {
    "mbbill/undotree",
    keys = {
      { "<C-c>", vim.cmd.UndotreeToggle, desc = "Toggle undo tree" },
    },
    init = function()
      vim.g.undotree_WindowLayout = 2
      vim.g.undotree_SetFocusWhenToggle = true
    end,
  },

  -- TODO: add telescope stuff here
}
