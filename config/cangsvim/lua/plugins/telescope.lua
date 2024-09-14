local Utils = require("utils")
local have_make = vim.fn.executable("make") == 1
local have_cmake = vim.fn.executable("cmake") == 1

local telescope = function(builtin, ...)
  return function()
    require("telescope.builtin")[builtin](unpack(arg or {}))
  end
end

local find_files = function(no_ignore)
  local fd_cmd = {
    "fd",
    "--type",
    "file",
    "--hidden",
    "--exclude",
    ".git",
  }

  telescope("find_files", {
    find_command = fd_cmd,
    no_ignore = no_ignore,
  })()
end

return {
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    dependencies = {
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = have_make and "make"
          or "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build",
        enabled = have_make or have_cmake,
        config = function(plugin)
          Utils.on_load("telescope.nvim", function()
            local ok, err = pcall(require("telescope").load_extension, "fzf")
            if not ok then
              local lib = plugin.dir .. "/build/libfzf." .. (Utils.is_win() and "dll" or "so")

              if not vim.uv.fs_stat(lib) then
                vim.notify("`telescope-fzf-native.nvim` not built. Rebuilding...", vim.log.levels.WARN)
                require("lazy").build({ plugins = { plugin }, show = false }):wait(function()
                  vim.notify(
                    "Rebuilding `telescope-fzf-native.nvim` done.\nPlease restart Neovim.",
                    vim.log.levels.INFO
                  )
                end)
              else
                vim.notify("Failed to load `telescope-fzf-native.nvim`:\n", vim.log.levels.ERROR)
              end
            end
          end)
        end,
      },
      {},
    },
    opts = function()
      local actions = require("telescope.actions")

      return {
        defaults = {
          prompt_prefix = " ",
          selection_caret = " ",
          -- open files in the first window that is an actual file.
          -- use the current window if no other window is available.
          get_selection_window = function()
            local wins = vim.api.nvim_list_wins()
            table.insert(wins, 1, vim.api.nvim_get_current_win())
            for _, win in ipairs(wins) do
              local buf = vim.api.nvim_win_get_buf(win)
              if vim.bo[buf].buftype == "" then
                return win
              end
            end
            return 0
          end,
          mappings = {
            n = {
              ["<Esc>"] = actions.close,
              ["q"] = actions.close,
            },
          },
        },
      }
    end,
    keys = {
      {
        "<leader>f",
        desc = "Find",
      },
      {
        "<leader>fb",
        telescope("buffers", {
          sort_mru = true,
          sort_lastused = true,
        }),
        desc = "Find buffers",
      },
      {
        "<leader>ff",
        function()
          find_files(false)
        end,
        desc = "Find files",
      },
      {
        "<leader>fa",
        function()
          find_files(true)
        end,
        desc = "Find all files",
      },
      {
        "<leader>fo",
        telescope("oldfiles"),
        desc = "Find old files",
      },
      {
        "<leader>fb",
        telescope("buffers"),
        desc = "Find buffers",
      },
      {
        "<leader>fw",
        telescope("live_grep"),
        desc = "Find word",
      },
      {
        "<leader>fW",
        telescope("grep_string"),
        desc = "Find word under cursor",
      },
      {
        "<leader>f/",
        telescope("current_buffer_fuzzy_find"),
        desc = "Find on current buffer",
      },
      {
        "<leader>f:",
        telescope("command_history"),
        desc = "Find command history",
      },
      {
        "<leader>fs",
        telescope("lsp_document_symbols"),
        desc = "Find LSP symbols in current file",
      },
      {
        "<leader>fS",
        telescope("lsp_workspace_symbols"),
        desc = "Find LSP symbols in current workspace",
      },
      {
        "<leader>fd",
        telescope("diagnostics", { bufnr = 0 }),
        desc = "Find diagnostics in current buffer",
      },
      {
        "<leader>fD",
        telescope("diagnostics"),
        desc = "Find diagnostics in current workspace",
      },
      {
        "<leader>fr",
        telescope("resume"),
        desc = "Find (resume last search)",
      },
    },
  },
}
