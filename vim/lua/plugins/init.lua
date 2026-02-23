return {
  {
    "navarasu/onedark.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("onedark").setup({
        style = "warmer",
        transparent = true,
        highlights = {
          ["Whitespace"]   = { fg = "#5a6275" },
          ["@whitespace"]  = { fg = "#5a6275" },
        },
      })
      require("onedark").load()
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    build = function()
      require("nvim-treesitter").install({ "python", "go", "typescript", "javascript", "tsx", "jsx", "lua", "bash", "markdown", "json", "yaml", "sql", "dockerfile", "make", "ini", "toml", "css" }):wait()
    end,
  },
  "907th/vim-auto-save",
  "itchyny/lightline.vim",
  "airblade/vim-gitgutter",
  "tpope/vim-surround",
  "tpope/vim-fugitive",
  "tpope/vim-commentary",
  "tpope/vim-dispatch",
  {
    "nvim-neo-tree/neo-tree.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-tree/nvim-web-devicons", -- optional, but recommended
    },
    lazy = false, -- neo-tree will lazily load itself
  },
  "junegunn/fzf",
  "junegunn/fzf.vim",
  "lukas-reineke/indent-blankline.nvim",
  -- Python autocomplete: LSP + nvim-cmp
  "neovim/nvim-lspconfig",
  "hrsh7th/nvim-cmp",
  "hrsh7th/cmp-nvim-lsp",
  "hrsh7th/cmp-buffer",
  "hrsh7th/cmp-path",
  "L3MON4D3/LuaSnip",
  "saadparwaiz1/cmp_luasnip",
  -- Dashboard (start screen)
  {
    "goolord/alpha-nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "VimEnter",
    opts = function()
      return require("alpha.themes.dashboard").config
    end,
    config = function(_, opts)
      require("alpha").setup(opts)
    end,
  },
}
