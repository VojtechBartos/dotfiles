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
  cmd = { "pyright", "--stdio" },
  filetypes = { "python" },
  root_markers = { ".git", "pyrightconfig.json", "pyproject.toml" },
  capabilities = lsp_capabilities,
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

-- fzf: always bottom split, full width
vim.g.fzf_layout = { down = "40%" }

-- fzf: fuzzy file finder and full-text search (leader = , from vimrc)
vim.keymap.set("n", "<leader>t", "<cmd>Files<cr>", { desc = "Fuzzy find files" })
vim.keymap.set("n", "<leader>r", "<cmd>Ag<cr>", { desc = "Full text search (silver searcher)" })

-- Neo-tree: open/toggle file explorer; show hidden files and directories
require("neo-tree").setup({
  filesystem = {
    filtered_items = {
      hide_dotfiles = false,
      hide_gitignored = false,
    },
  },
})
vim.keymap.set("n", "<leader>e", "<cmd>Neotree toggle<cr>", { desc = "Neo-tree toggle" })

-- Splits and save
vim.keymap.set("n", "<leader>vv", "<cmd>vsplit<cr>", { desc = "Split vertically" })
vim.keymap.set("n", "<leader>vh", "<cmd>split<cr>", { desc = "Split horizontally" })
vim.keymap.set("n", "<leader>h", "<cmd>History<cr>", { desc = "Command history (fzf)" })
vim.keymap.set("n", "<leader>s", "<cmd>w<cr>", { desc = "Save" })

-- Tabs
vim.keymap.set("n", "<leader>c", "<cmd>tabnew<cr>", { desc = "New tab" })

-- Atom One Dark + transparent background (Ghostty)
vim.cmd("colorscheme onedark")
vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
vim.api.nvim_set_hl(0, "NonText", { bg = "none" })
vim.api.nvim_set_hl(0, "LineNr", { bg = "none" })
vim.api.nvim_set_hl(0, "SignColumn", { bg = "none" })
vim.api.nvim_set_hl(0, "EndOfBuffer", { bg = "none" })
-- Space character (listchars space:·): color close to One Dark background (#282c34)
vim.api.nvim_set_hl(0, "Whitespace", { fg = "#323842", blend = 100 })
-- Indent guide lines: very close to One Dark bg (#282c34)
local indent_hl = { fg = "#292d35", blend = 100 }
vim.api.nvim_set_hl(0, "IndentBlanklineChar", indent_hl)
vim.api.nvim_set_hl(0, "IBLChar", indent_hl)
vim.api.nvim_set_hl(0, "IblScope", indent_hl)
require("ibl").setup({
  indent = { char = "▏" },  -- thinnest option (left one eighth block)
})
