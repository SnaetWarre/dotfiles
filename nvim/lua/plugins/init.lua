return {
  -- Lazy.nvim
  {
    "folke/lazy.nvim",
    lazy = false,
  },

  -- LSP Configuration
  {
    "VonHeikemen/lsp-zero.nvim",
    branch = "v3.x",
    dependencies = {
      "neovim/nvim-lspconfig",
      "hrsh7th/nvim-cmp",
      "hrsh7th/cmp-nvim-lsp",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "rafamadriz/friendly-snippets",
    },
  },

  -- Telescope
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
  },

  -- Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
  },

  -- Theme
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd([[colorscheme tokyonight]])
    end,
  },

  -- Git integration
  {
    "tpope/vim-fugitive",
    lazy = false,
  },

  -- Comment
  {
    "numToStr/Comment.nvim",
    lazy = false,
  },

  -- Harpoon
  {
    "ThePrimeagen/harpoon",
    lazy = false,
  },

  -- Undotree
  {
    "mbbill/undotree",
    lazy = false,
  },

  -- Vim surround
  {
    "tpope/vim-surround",
    lazy = false,
  },
} 