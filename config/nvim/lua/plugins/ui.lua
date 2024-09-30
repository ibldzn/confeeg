local Utils = require("utils")

return {
  {
    "rcarriga/nvim-notify",
    event = "VeryLazy",
    keys = {
      {
        "<leader>Nd",
        function()
          require("notify").dismiss({ silent = true, pending = true })
        end,
        desc = "Dismiss All Notifications",
      },
      {
        "<leader>Nh",
        function()
          require("notify")._print_history()
        end,
        desc = "Check Notifications History",
      },
    },
    opts = {
      stages = "static",
      timeout = 3000,
      max_height = function()
        return math.floor(vim.o.lines * 0.75)
      end,
      max_width = function()
        return math.floor(vim.o.columns * 0.75)
      end,
      on_open = function(win)
        vim.api.nvim_win_set_config(win, { zindex = 100 })
      end,
    },
    init = function()
      local notifs = {}
      local function temp(...)
        table.insert(notifs, vim.F.pack_len(...))
      end

      local orig = vim.notify
      vim.notify = temp

      local timer = vim.uv.new_timer()
      local check = assert(vim.uv.new_check())

      local replay = function()
        timer:stop()
        check:stop()
        if vim.notify == temp then
          vim.notify = orig -- put back the original notify if needed
        end
        vim.schedule(function()
          ---@diagnostic disable-next-line: no-unknown
          for _, notif in ipairs(notifs) do
            vim.notify(vim.F.unpack_len(notif))
          end
        end)
      end

      -- wait till vim.notify has been replaced
      check:start(function()
        if vim.notify ~= temp then
          replay()
        end
      end)

      -- or if it took more than 500ms, then something went wrong
      timer:start(500, 0, replay)
    end,
    config = function()
      vim.notify = require("notify")
    end,
  },

  {
    "nvim-tree/nvim-web-devicons",
    lazy = true,
  },

  {
    "utilyre/barbecue.nvim",
    event = "LazyFile",
    dependencies = {
      "SmiteshP/nvim-navic",
      "nvim-tree/nvim-web-devicons", -- optional dependency
    },
    opts = {
      show_modified = true,
    },
  },

  {
    "lukas-reineke/indent-blankline.nvim",
    event = "LazyFile",
    opts = {
      indent = {
        char = "│",
        tab_char = "│",
      },
      scope = { show_start = false, show_end = false },
      exclude = {
        filetypes = {
          "help",
          "alpha",
          "dashboard",
          "neo-tree",
          "Trouble",
          "trouble",
          "lazy",
          "mason",
          "notify",
          "toggleterm",
          "lazyterm",
        },
      },
    },
    main = "ibl",
  },
}
