return {
  {
    "navarasu/onedark.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("onedark").setup({
        style = "dark",
        transparent = true,
        colors = {
          bg0    = "#282C34",  -- editor background (exact VS Code match)
          bg1    = "#31353F",  -- lighter background (popups, floats)
          fg     = "#ABB2BF",
          red    = "#E06C75",
          orange = "#D19A66",
          yellow = "#E5C07B",
          green  = "#98C379",
          cyan   = "#56B6C2",
          blue   = "#61AFEF",
          purple = "#C678DD",
          grey   = "#5C6370",
        },
        highlights = {
          ["@tag"]         = { fg = "#E5C07B" },  -- JSX/TSX tag names → yellow (VS Code match)
          ["Whitespace"]   = { fg = "#3c4050" },  -- space dots (listchars) — much more subtle
          ["@whitespace"]  = { fg = "#3c4050" },
        },
      })
      require("onedark").load()
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    build = function()
      require("nvim-treesitter").install({ "python", "go", "typescript", "javascript", "tsx", "jsx", "lua", "bash", "markdown", "json", "yaml", "sql", "dockerfile", "make", "ini", "toml", "css", "rust" }):wait()
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
