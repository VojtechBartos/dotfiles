return {
  { "joshdick/onedark.vim", lazy = false, priority = 1000 },
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
}
