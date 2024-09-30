local Utils = require("utils")

return {
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-nvim-lua",
      "hrsh7th/cmp-path",
      {
        "windwp/nvim-autopairs",
        opts = {},
      },
    },
    opts = function()
      vim.api.nvim_set_hl(0, "CmpGhostText", { link = "Comment", default = true })
      local cmp = require("cmp")
      local defaults = require("cmp.config.default")()

      return {
        completion = { completeopt = "menu,menuone,noinsert" },
        snippet = false,
        formatting = {
          fields = { "kind", "abbr", "menu" },
          format = function(_, item)
            local icons = require("config.icons").kinds
            if icons[item.kind] then
              item.kind = icons[item.kind] .. item.kind
            end

            local widths = {
              abbr = vim.g.cmp_widths and vim.g.cmp_widths.abbr or 40,
              menu = vim.g.cmp_widths and vim.g.cmp_widths.menu or 30,
            }

            for key, width in pairs(widths) do
              if item[key] and vim.fn.strdisplaywidth(item[key]) > width then
                item[key] = vim.fn.strcharpart(item[key], 0, width - 1) .. "…"
              end
            end

            return item
          end,
        },
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "path" },
          { name = "nvim_lua" },
          { name = "buffer" },
        }),
        mapping = cmp.mapping.preset.insert({
          ["<tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
            else
              fallback()
            end
          end),
          ["<s-tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item({ behavior = cmp.SelectBehavior.Select })
            else
              fallback()
            end
          end),
          ["<c-p>"] = cmp.mapping.select_prev_item(),
          ["<c-n>"] = cmp.mapping.select_next_item(),
          ["<c-u>"] = cmp.mapping.scroll_docs(-4),
          ["<c-d>"] = cmp.mapping.scroll_docs(4),
          ["<c-space>"] = cmp.mapping.complete(),
          ["<c-q>"] = cmp.mapping({
            i = cmp.mapping.abort(),
            c = cmp.mapping.close(),
          }),
          ["<cr>"] = cmp.mapping.confirm({
            select = true,
            behavior = cmp.ConfirmBehavior.Replace,
          }),
        }),
        experimental = {
          native_menu = false,
          ghost_text = {
            hl_group = "CmpGhostText",
          },
        },
        sorting = defaults.sorting,
      }
    end,
    config = function(_, opts)
      for _, source in ipairs(opts.sources) do
        source.group_index = source.group_index or 1
      end

      local cmp = require("cmp")
      cmp.setup(opts)

      local autopairs = require("nvim-autopairs.completion.cmp")
      cmp.event:on("confirm_done", autopairs.on_confirm_done())

      if Utils.has("copilot.lua") then
        cmp.event:on("menu_opened", function()
          vim.b.copilot_suggestion_hidden = true
        end)

        cmp.event:on("menu_closed", function()
          vim.b.copilot_suggestion_hidden = false
        end)
      end
    end,
  },

  {
    "L3MON4D3/LuaSnip",
    build = (not Utils.is_win())
        and "echo 'NOTE: jsregexp is optional, so not a big deal if it fails to build'; make install_jsregexp"
      or nil,
    dependencies = {
      {
        "rafamadriz/friendly-snippets",
        config = function()
          require("luasnip.loaders.from_vscode").lazy_load()
        end,
      },
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      local luasnip = require("luasnip")

      luasnip.config.setup({
        updateevents = "InsertLeave,TextChanged,TextChangedI",
      })

      local snippets = vim.fn.stdpath("config") .. "/snippets"
      require("luasnip.loaders.from_lua").load({ paths = snippets })

      luasnip.filetype_extend("javascript", { "javascriptreact" })
      luasnip.filetype_extend("typescript", { "typescriptreact" })
      luasnip.filetype_extend("blade", { "html", "php" })

      vim.api.nvim_create_autocmd("InsertLeave", {
        group = vim.api.nvim_create_augroup("LuaSnip", { clear = true }),
        callback = function(args)
          if luasnip.session.current_nodes[args.buf] and not luasnip.session.jump_active then
            luasnip.unlink_current()
          end
        end,
      })
    end,
  },

  {
    "nvim-cmp",
    dependencies = {
      "saadparwaiz1/cmp_luasnip",
    },
    opts = function(_, opts)
      opts.snippet = {
        expand = function(args)
          require("luasnip").lsp_expand(args.body)
        end,
      }
      table.insert(opts.sources, { name = "luasnip" })
    end,
  },

  {
    "nvim-cmp",
    -- stylua: ignore
    keys = {
      {
        "<tab>",
        function()
          return require("luasnip").expand_or_jumpable() and "<Plug>luasnip-expand-or-jump" or "<tab>"
        end,
        expr = true, silent = true, mode = "i",
      },
      { "<tab>", function() require("luasnip").jump(1) end, mode = "s" },
      { "<s-tab>", function() require("luasnip").jump(-1) end, mode = { "i", "s" } },
    },
  },

  {
    "folke/ts-comments.nvim",
    event = "VeryLazy",
    opts = {},
  },

  {
    "kylechui/nvim-surround",
    keys = {
      { "ys", mode = "n" },
      { "ds", mode = "n" },
      { "cs", mode = "n" },
      { "S", mode = "x" },
    },
    opts = {},
  },

  {
    "krady21/compiler-explorer.nvim",
    cmd = {
      "CEAddLibrary",
      "CECompile",
      "CECompileLive",
      "CEDeleteCache",
      "CEFormat",
      "CELoadExample",
      "CEOpenWebsite",
    },
  },

  {
    "andymass/vim-matchup",
    dependencies = "nvim-treesitter/nvim-treesitter",
    event = "LazyFile",
    init = function()
      vim.g.matchup_matchparen_offscreen = { method = "status_manual" }
    end,
  },

  {
    "phaazon/hop.nvim",
    opts = {},
    keys = {
      { "s", desc = "+hop" },
      { "sc", "<cmd>HopChar1<cr>", desc = "Char" },
      { "sC", "<cmd>HopChar2<cr>", desc = "2 Chars" },
      { "sp", "<cmd>HopPattern<cr>", desc = "Pattern" },
      { "ss", "<cmd>HopWord<cr>", desc = "Word" },
      { "sL", "<cmd>HopLine<cr>", desc = "Line" },
      { "sl", "<cmd>HopLineStart<cr>", desc = "Line Start" },
    },
  },

  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    build = ":Copilot auth",
    opts = {
      panel = {
        layout = {
          position = "right",
          ratio = 0.4,
        },
      },
      suggestion = {
        auto_trigger = true,
        keymap = {
          accept = "<tab>",
          dismiss = "<c-q>",
        },
      },
    },
  },

  {
    "mattn/emmet-vim",
    event = "InsertEnter",
    init = function()
      vim.g.user_emmet_leader_key = ","
      vim.g.user_emmet_install_global = 0
    end,
    config = function()
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("emmet", { clear = true }),
        pattern = {
          "css",
          "html",
          "javascript",
          "javascriptreact",
          "less",
          "sass",
          "scss",
          "typescript",
          "typescriptreact",
        },
        command = "EmmetInstall",
      })
    end,
  },
}
