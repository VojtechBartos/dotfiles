vim.env.PATH = vim.env.PATH .. ":/opt/homebrew/bin"

-- Source shared vimrc (options, keymaps)
local vimrc = vim.fn.expand("~/.vimrc")
if vim.fn.filereadable(vimrc) == 1 then
  vim.cmd("source " .. vimrc)
else
  vim.cmd("source " .. vim.fn.expand("~/.dotfiles/vim/vimrc.symlink"))
end

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup("plugins")

-- Python LSP (pyright) + autocomplete (nvim-cmp) — Neovim 0.11 vim.lsp.config API
local cmp = require("cmp")
local cmp_lsp = require("cmp_nvim_lsp")

local lsp_capabilities = cmp_lsp.default_capabilities()

-- Python
vim.lsp.config("pyright", {
  cmd = { "pyright-langserver", "--stdio" },
  filetypes = { "python" },
  root_markers = { ".git", "pyrightconfig.json", "pyproject.toml" },
  capabilities = lsp_capabilities,
  settings = {
    python = {
      analysis = {
        diagnosticMode = "workspace",
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
      },
    },
  },
  on_attach = function(client, bufnr)
    local bufpath = vim.api.nvim_buf_get_name(bufnr)
    local dir = vim.fs.dirname(bufpath)
    local venv_dir = vim.fs.find(".venv", { path = dir, upward = true, type = "directory" })[1]
    if venv_dir then
      local python = venv_dir .. "/bin/python"
      if vim.uv.fs_stat(python) then
        client.config.settings.python.pythonPath = python
        client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
      end
    end
  end,
})
vim.lsp.enable("pyright")

-- Go
vim.lsp.config("gopls", {
  cmd = { "gopls" },
  filetypes = { "go", "gomod", "gowork" },
  root_markers = { "go.work", "go.mod", ".git" },
  capabilities = lsp_capabilities,
})
vim.lsp.enable("gopls")

-- TypeScript / JavaScript / React
vim.lsp.config("ts_ls", {
  cmd = { "typescript-language-server", "--stdio" },
  filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
  root_markers = { "package.json", "tsconfig.json", "jsconfig.json", ".git" },
  capabilities = lsp_capabilities,
})
vim.lsp.enable("ts_ls")

-- nvim-cmp: completion menu (LSP, Copilot, buffer, path, snippets)
cmp.setup({
  sources = cmp.config.sources(
    { { name = "copilot", group_index = 2 } },
    { { name = "nvim_lsp" } },
    { { name = "buffer" }, { name = "path" } },
    { { name = "luasnip" } }
  ),
  mapping = cmp.mapping.preset.insert({
    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
    ["<C-f>"] = cmp.mapping.scroll_docs(4),
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<C-e>"] = cmp.mapping.abort(),
    ["<CR>"] = cmp.mapping.confirm({ select = true }),
    ["<Tab>"] = cmp.mapping.select_next_item(),
    ["<S-Tab>"] = cmp.mapping.select_prev_item(),
  }),
  snippet = {
    expand = function(args)
      require("luasnip").lsp_expand(args.body)
    end,
  },
})

-- Auto-reload files changed outside nvim
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold" }, {
  callback = function()
    if vim.fn.getcmdwintype() == "" then
      vim.cmd("checktime")
    end
  end,
})

-- Use treesitter highlighting when a parser is available, fallback to syntax
vim.api.nvim_create_autocmd("FileType", {
  callback = function()
    pcall(vim.treesitter.start)
  end,
})

-- fzf: always bottom split, full width
vim.g.fzf_layout = { down = "40%" }
vim.env.FZF_DEFAULT_OPTS = (vim.env.FZF_DEFAULT_OPTS or "") .. " --preview 'bat --color=always --style=plain {}' --preview-window=right:50%"

-- fzf: fuzzy file finder and full-text search (leader = , from vimrc)
vim.keymap.set("n", "<leader>t", "<cmd>Files<cr>", { desc = "Fuzzy find files" })
vim.keymap.set("n", "<leader>r", "<cmd>Ag<cr>", { desc = "Full text search (silver searcher)" })

-- Neo-tree: open/toggle file explorer; show hidden files and directories
require("neo-tree").setup({
  window = {
    width = 35,
    adaptive_size = false,
  },
  filesystem = {
    filtered_items = {
      hide_dotfiles = false,
      hide_gitignored = false,
    },
    use_libuv_file_watcher = true,
  },
})
vim.keymap.set("n", "<leader>e", "<cmd>Neotree toggle<cr>", { desc = "Neo-tree toggle" })
vim.keymap.set("n", "<leader>ef", ":Neotree reveal<CR>", { silent = true })
vim.keymap.set("n", "<leader>gb", "<cmd>Git blame<cr>", { desc = "Git blame" })

-- Diagnostics
vim.keymap.set("n", "<leader>d", function() vim.diagnostic.open_float({ scope = "line" }) end, { desc = "Show diagnostics" })
vim.keymap.set("n", "<leader>dd", function() vim.diagnostic.setloclist() vim.cmd("lopen") end, { desc = "Show all diagnostics in file" })
vim.keymap.set("n", "<leader>da", function() vim.diagnostic.setqflist() vim.cmd("copen") end, { desc = "Show all workspace diagnostics" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Prev diagnostic" })

-- LSP keymaps (buffer-local, only active when an LSP client is attached)
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local map = function(keys, fn, desc)
      vim.keymap.set("n", keys, fn, { buffer = args.buf, desc = desc })
    end
    map("gd",         vim.lsp.buf.definition,  "Go to definition")
    map("gr",         vim.lsp.buf.references,   "Go to references")
    map("K",          vim.lsp.buf.hover,        "Hover docs")
    map("<leader>rn", vim.lsp.buf.rename,       "Rename symbol")
    map("<leader>ca", vim.lsp.buf.code_action,  "Code action")
  end,
})

-- Splits and save
vim.keymap.set("n", "<leader>vv", "<cmd>vsplit<cr>", { desc = "Split vertically" })
vim.keymap.set("n", "<leader>vh", "<cmd>split<cr>", { desc = "Split horizontally" })
vim.keymap.set("n", "<leader>h", "<cmd>History<cr>", { desc = "Command history (fzf)" })
vim.keymap.set("n", "<leader>s", "<cmd>w<cr>", { desc = "Save" })

-- Tabs
vim.keymap.set("n", "<leader>c", "<cmd>tabnew<cr>", { desc = "New tab" })


local function set_indent_highlights()
  vim.api.nvim_set_hl(0, "IBLChar",            { fg = "#2f343d" })
  vim.api.nvim_set_hl(0, "IblScope",            { fg = "#5a6070" })
  vim.api.nvim_set_hl(0, "NeoTreeWinSeparator", { link = "WinSeparator" })
end
set_indent_highlights()
vim.api.nvim_create_autocmd("ColorScheme", { callback = set_indent_highlights })

require("ibl").setup({
  indent = { char = "▏", highlight = "IBLChar" },
  scope  = { enabled = true, highlight = "IblScope" },
})
