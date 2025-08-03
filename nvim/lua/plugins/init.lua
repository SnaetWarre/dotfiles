return {
  -- Lazy.nvim
  {
    "folke/lazy.nvim",
    lazy = false,
  },

  -- Mason for LSP installation
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end,
  },

  -- Mason LSP Config
  {
    "williamboman/mason-lspconfig.nvim",
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "lua_ls",
          "pyright",
          "clangd",
          "csharp_ls",
          "gopls",
          "rust_analyzer",
          "ts_ls",
          "svelte",
          "html",
          "cssls",
          "yamlls",
          "jsonls",
          "eslint",
          "prettier",
        },
        automatic_installation = true,
      })
    end,
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
    config = function()
      local lsp = require('lsp-zero').preset({})

      lsp.on_attach(function(client, bufnr)
        lsp.default_keymaps({buffer = bufnr})
      end)

      -- Configure language servers
      local lspconfig = require('lspconfig')

      -- Lua
      lspconfig.lua_ls.setup(lsp.nvim_lua_ls())

      -- Python
      lspconfig.pyright.setup({
        settings = {
          python = {
            analysis = {
              autoSearchPaths = true,
              useLibraryCodeForTypes = true,
              diagnosticMode = "workspace",
            },
          },
        },
      })

      -- C/C++
      lspconfig.clangd.setup({
        settings = {
          clangd = {
            arguments = {
              "--background-index",
              "--clang-tidy",
              "--header-insertion=iwyu",
              "--completion-style=detailed",
            },
          },
        },
      })

      -- C#
      lspconfig.csharp_ls.setup({
        settings = {
          csharp = {
            enable_roslyn_analyzers = true,
            organize_imports_on_format = true,
            enable_import_completion = true,
          },
        },
      })

      -- Go
      lspconfig.gopls.setup({
        settings = {
          gopls = {
            analyses = {
              unusedparams = true,
              shadow = true,
            },
            staticcheck = true,
            gofumpt = true,
          },
        },
      })

      -- Rust
      lspconfig.rust_analyzer.setup({
        settings = {
          ["rust-analyzer"] = {
            checkOnSave = {
              command = "clippy",
            },
            cargo = {
              allFeatures = true,
            },
          },
        },
      })

      -- TypeScript/JavaScript
      lspconfig.ts_ls.setup({
        settings = {
          typescript = {
            inlayHints = {
              includeInlayParameterNameHints = "all",
              includeInlayParameterNameHintsWhenArgumentMatchesName = false,
              includeInlayFunctionParameterTypeHints = true,
              includeInlayVariableTypeHints = true,
              includeInlayPropertyDeclarationTypeHints = true,
              includeInlayFunctionLikeReturnTypeHints = true,
              includeInlayEnumMemberValueHints = true,
            },
          },
          javascript = {
            inlayHints = {
              includeInlayParameterNameHints = "all",
              includeInlayParameterNameHintsWhenArgumentMatchesName = false,
              includeInlayFunctionParameterTypeHints = true,
              includeInlayVariableTypeHints = true,
              includeInlayPropertyDeclarationTypeHints = true,
              includeInlayFunctionLikeReturnTypeHints = true,
              includeInlayEnumMemberValueHints = true,
            },
          },
        },
      })

      -- Svelte
      lspconfig.svelte.setup({
        settings = {
          svelte = {
            plugin = {
              svelte = {
                enable = true,
              },
            },
          },
        },
      })

      -- HTML
      lspconfig.html.setup({
        settings = {
          html = {
            format = {
              templating = true,
              wrapLineLength = 120,
              wrapAttributes = "auto",
            },
          },
        },
      })

      -- CSS
      lspconfig.cssls.setup({
        settings = {
          css = {
            validate = true,
            lint = {
              unknownAtRules = "ignore",
            },
          },
        },
      })

      -- YAML
      lspconfig.yamlls.setup({
        settings = {
          yaml = {
            format = {
              enable = true,
            },
            validate = true,
            hover = true,
            completion = true,
            schemaStore = {
              enable = true,
            },
          },
        },
      })

      -- JSON
      lspconfig.jsonls.setup({
        settings = {
          json = {
            format = {
              enable = true,
            },
            validate = {
              enable = true,
            },
            schemas = {
              {
                fileMatch = { "package.json" },
                url = "https://json.schemastore.org/package.json",
              },
              {
                fileMatch = { "tsconfig.json" },
                url = "https://json.schemastore.org/tsconfig.json",
              },
            },
          },
        },
      })

      -- ESLint
      lspconfig.eslint.setup({
        settings = {
          eslint = {
            format = {
              enable = true,
            },
            lintTask = {
              enable = true,
            },
          },
        },
      })

      lsp.setup()
    end,
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
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        flavour = "latte", -- latte, frappe, macchiato, mocha
        background = {
          light = "latte",
          dark = "mocha",
        },
        transparent_background = false,
        show_end_of_buffer = false,
        term_colors = true,
        dim_inactive = {
          enabled = false,
          shade = "dark",
          percentage = 0.15,
        },
        no_italic = false,
        no_bold = false,
        no_underline = false,
        styles = {
          comments = { "italic" },
          conditionals = { "italic" },
          loops = {},
          functions = {},
          keywords = {},
          strings = {},
          variables = {},
          numbers = {},
          booleans = {},
          properties = {},
          types = {},
          operators = {},
        },
        integrations = {
          cmp = true,
          gitsigns = true,
          nvimtree = true,
          telescope = true,
          treesitter = true,
          harpoon = true,
        },
      })
      vim.cmd([[colorscheme catppuccin]])
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

  -- Vim surround (using vim-surround for Neovim compatibility)
  {
    "kylechui/nvim-surround",
    version = "*",
    config = function()
      require("nvim-surround").setup({})
    end,
  },

  -- File explorer
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      require("nvim-tree").setup({
        sort_by = "case_sensitive",
        update_focused_file = {
          enable = true,
          update_cwd = true,
        },
        respect_buf_cwd = true,
        view = {
          width = 30,
          side = "left",
          relativenumber = true,
        },
        renderer = {
          group_empty = true,
          icons = {
            glyphs = {
              default = "",
              symlink = "",
              folder = {
                arrow_closed = "",
                arrow_open = "",
                default = "",
                open = "",
                empty = "",
                empty_open = "",
                symlink = "",
                symlink_open = "",
              },
              git = {
                unstaged = "✗",
                staged = "✓",
                unmerged = "",
                renamed = "➜",
                untracked = "★",
                deleted = "",
                ignored = "◌",
              },
            },
          },
        },
        filters = {
          dotfiles = false,
        },
        git = {
          enable = true,
          ignore = false,
        },
        actions = {
          open_file = {
            quit_on_open = false,
          },
          file_popup = {
            open_win_config = {
              col = 1,
              row = 1,
              relative = "cursor",
              border = "shadow",
              style = "minimal",
            },
          },
        },
        filesystem_watchers = {
          enable = true,
        },
      })
    end,
  },

  -- Web devicons
  {
    "nvim-tree/nvim-web-devicons",
    lazy = false,
  },

  -- Terminal integration
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = function()
      require("toggleterm").setup({
        size = 80,
        open_mapping = [[<C-\>]],
        hide_numbers = true,
        shade_filetypes = {},
        shade_terminals = true,
        shading_factor = 2,
        start_in_insert = true,
        insert_mappings = true,
        terminal_mappings = true,
        persist_size = true,
        direction = "vertical",
        close_on_exit = true,
        shell = vim.o.shell,
        float_opts = {
          border = "curved",
          winblend = 0,
          highlights = {
            border = "Normal",
            background = "Normal",
          },
        },
      })
    end,
  },

  -- Auto pairs for brackets, quotes, etc.
  {
    "windwp/nvim-autopairs",
    config = function()
      require("nvim-autopairs").setup()
    end,
  },

  -- Git signs in the gutter
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup()
    end,
  },

  -- Indent guides
  {
    "lukas-reineke/indent-blankline.nvim",
    version = "3",
    config = function()
      require("ibl").setup({
        indent = {
          char = "│",
          tab_char = "│",
        },
        scope = {
          enabled = true,
          highlight = "Function",
          show_start = true,
          show_end = true,
        },
      })
    end,
  },

  -- Better status line
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = {
          theme = "catppuccin",
        },
      })
    end,
  },

  -- Buffer line
  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = "nvim-tree/nvim-web-devicons",
    config = function()
      require("bufferline").setup({
        options = {
          diagnostics = "nvim_lsp",
          always_show_bufferline = false,
          show_buffer_close_icons = true,
          show_close_icon = false,
          color_icons = true,
        },
      })
    end,
  },

  -- Better search and replace
  {
    "nvim-pack/nvim-spectre",
    config = function()
      require("spectre").setup()
    end,
  },

  -- Project management
  {
    "ahmedkhalf/project.nvim",
    config = function()
      require("project_nvim").setup({
        detection_methods = { "pattern" },
        patterns = { ".git", "_darcs", ".hg", ".bzr", ".svn", "Makefile", "package.json" },
      })
    end,
  },
}
