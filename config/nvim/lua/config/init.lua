local M = {}

local function try_load(module_name)
  local ok, mod = pcall(require, module_name)

  if not ok then
    local text = "Failed to load module '" .. module_name .. "'"
    vim.notify(text, vim.log.levels.ERROR)
    return
  end

  return mod
end

function M.setup()
  local lazy_autocmds = vim.fn.argc(-1) == 0
  if not lazy_autocmds then
    try_load("config.autocmds")
  end

  local group = vim.api.nvim_create_augroup("CangsVim", { clear = true })
  vim.api.nvim_create_autocmd("User", {
    group = group,
    pattern = "VeryLazy",
    callback = function()
      if lazy_autocmds then
        try_load("config.autocmds")
      end

      try_load("config.mappings")
    end,
  })
end

M.did_init = false
function M.init()
  if M.did_init then
    return
  end

  M.did_init = true

  try_load("utils.plugin").setup()
  try_load("config.options")
end

return M
