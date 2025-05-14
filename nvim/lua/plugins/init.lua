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
    "rose-pine/neovim",
    name = "rose-pine",
    lazy = false,
    priority = 1000,
    config = function()
      require("rose-pine").setup({
        variant = "main", -- auto, main, moon, or dawn
        dark_variant = "main", -- main, moon, or dawn
        dim_inactive_windows = false,
        extend_background_behind_borders = true,
        enable = {
          terminal = true,
          legacy_highlights = true,
          migrations = true,
        },
        styles = {
          bold = true,
          italic = true,
          transparency = false,
        },
      })
      vim.cmd([[colorscheme rose-pine]])
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