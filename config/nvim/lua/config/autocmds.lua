local augroup = function(name)
  return vim.api.nvim_create_augroup("cangs_" .. name, { clear = true })
end

-- Check if we need to reload the file when it changed
vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  group = augroup("checktime"),
  callback = function()
    if vim.o.buftype ~= "nofile" then
      vim.cmd("checktime")
    end
  end,
})

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup("highlight_yank"),
  callback = function()
    vim.highlight.on_yank({ timeout = 1000 })
  end,
})

-- resize splits if window got resized
vim.api.nvim_create_autocmd({ "VimResized" }, {
  group = augroup("resize_splits"),
  callback = function()
    local current_tab = vim.fn.tabpagenr()
    vim.cmd("tabdo wincmd =")
    vim.cmd("tabnext " .. current_tab)
  end,
})

-- go to last loc when opening a buffer
vim.api.nvim_create_autocmd("BufReadPost", {
  group = augroup("last_loc"),
  callback = function(event)
    local exclude = { "gitcommit" }
    local buf = event.buf
    if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].cangs_last_loc then
      return
    end
    vim.b[buf].cangs_last_loc = true
    local mark = vim.api.nvim_buf_get_mark(buf, '"')
    local lcount = vim.api.nvim_buf_line_count(buf)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- auto create dir when saving a file, in case some intermediate directory does not exist
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
  group = augroup("auto_create_dir"),
  callback = function(event)
    if event.match:match("^%w%w+:[\\/][\\/]") then
      return
    end
    local file = vim.uv.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})

-- close window with q
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("close_with_q"),
  pattern = {
    "checkhealth",
    "dap-float",
    "help",
    "lspinfo",
    "man",
    "neotest-attach",
    "neotest-output",
    "neotest-output-panel",
    "neotest-summary",
    "notify",
    "qf",
    "query",
    "spectre_panel",
    "startuptime",
    "tsplayground",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", vim.cmd.close, { buffer = event.buf, silent = true })
  end,
})

-- wrap and check for spell in text filetypes
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("wrap_spell"),
  pattern = { "gitcommit", "markdown" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
})

-- fix conceallevel for json files
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("json_conceal"),
  pattern = { "json", "jsonc", "json5" },
  callback = function()
    vim.opt_local.conceallevel = 0
  end,
})

-- no comments on new line
vim.api.nvim_create_autocmd("BufEnter", {
  group = augroup("no_comments_on_new_line"),
  command = "set fo-=c fo-=r fo-=o",
})

-- toggle relative line number
vim.api.nvim_create_autocmd({ "InsertEnter", "InsertLeave" }, {
  group = augroup("relative_number_toggle"),
  callback = function(event)
    if vim.wo.number or vim.wo.relativenumber then
      vim.wo.relativenumber = event.event == "InsertLeave"
    end
  end,
})

-- some terminal options
vim.api.nvim_create_autocmd("TermOpen", {
  group = augroup("term_options"),
  callback = function()
    local opts = {
      listchars = nil,
      number = false,
      relativenumber = false,
      cursorline = false,
      signcolumn = "no",
    }

    for opt, val in pairs(opts) do
      vim.opt_local[opt] = val
    end

    vim.cmd.startinsert({ bang = true })
  end,
})

-- two space indent
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("indent_two_spaces"),
  pattern = {
    "cmake",
    "css",
    "graphql",
    "html",
    "javascript",
    "javascriptreact",
    "json",
    "lua",
    "nix",
    "php",
    "scss",
    "sql",
    "tex",
    "typescript",
    "typescriptreact",
    "xhtml",
    "xml",
    "yaml",
  },
  callback = function()
    vim.opt_local.expandtab = true
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
  end,
})

-- literal tab indent
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("tab_indent"),
  pattern = { "go", "gitconfig" },
  callback = function()
    vim.opt_local.expandtab = false
  end,
})

vim.filetype.add({
  pattern = {
    [".*"] = {
      function(path, buf)
        return vim.bo[buf]
            and vim.bo[buf].filetype ~= "bigfile"
            and path
            and vim.fn.getfsize(path) > vim.g.bigfile_size
            and "bigfile"
          or nil
      end,
    },
  },
})

vim.api.nvim_create_autocmd({ "FileType" }, {
  group = augroup("bigfile"),
  pattern = "bigfile",
  callback = function(ev)
    vim.schedule(function()
      vim.bo[ev.buf].syntax = vim.filetype.match({ buf = ev.buf }) or ""
    end)
  end,
})
