return {
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
          accept = "<Tab>",
          dismiss = "<C-q>",
        },
      },
    },
    config = function(_, opts)
      require("copilot").setup(opts)

      local has_cmp, cmp = pcall(require, "cmp")
      if has_cmp then
        cmp.event:on("menu_opened", function()
          vim.b.copilot_suggestion_hidden = true
        end)

        cmp.event:on("menu_closed", function()
          vim.b.copilot_suggestion_hidden = false
        end)
      end

      vim.keymap.set("i", "<Tab>", function()
        local copilot_suggestion = require("copilot.suggestion")
        if copilot_suggestion.is_visible() then
          copilot_suggestion.accept()
        else
          vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Tab>", true, false, true), "n", false)
        end
      end, {
        silent = true,
      })
    end,
  },

  {
    "nvim-lualine/lualine.nvim",
    optional = true,
    event = "VeryLazy",
    opts = function(_, opts)
      local colors = {
        [""] = CangsVim.ui.fg("Special"),
        ["Normal"] = CangsVim.ui.fg("Special"),
        ["Warning"] = CangsVim.ui.fg("DiagnosticError"),
        ["InProgress"] = CangsVim.ui.fg("DiagnosticWarn"),
      }
      table.insert(opts.sections.lualine_x, 2, {
        function()
          local ok, copilot = pcall(CangsVim.lsp.get_clients, { name = "copilot" })
          if not ok or #copilot < 1 then
            return
          end

          local icon = CangsVim.config.icons.kinds.Copilot
          local status = require("copilot.api").status.data

          if vim.tbl_isempty(copilot[1].requests) then
            return icon .. (status.message or "")
          end

          local spinners = CangsVim.config.icons.misc.spinners
          local ms = vim.loop.hrtime() / 1000000
          local frame = math.floor(ms / 120) % #spinners

          return icon .. " " .. spinners[frame + 1] .. " " .. (status.message or "")
        end,
        cond = function()
          if not package.loaded["copilot"] then
            return
          end
          local ok, clients = pcall(CangsVim.lsp.get_clients, { name = "copilot", bufnr = 0 })
          if not ok then
            return false
          end
          return ok and #clients > 0
        end,
        color = function()
          if not package.loaded["copilot"] then
            return
          end
          local status = require("copilot.api").status.data
          return colors[status.status] or colors[""]
        end,
      })
    end,
  },
}
