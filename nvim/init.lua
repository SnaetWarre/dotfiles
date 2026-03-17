-- Leader key
vim.g.mapleader = " "

-- Bootstrapping lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Basic Neovim settings for a clean experience
vim.opt.number = true           -- Show line numbers
vim.opt.relativenumber = true   -- Show relative line numbers
vim.opt.tabstop = 4             -- 4 spaces for a tab
vim.opt.shiftwidth = 4          -- 4 spaces per indentation level
vim.opt.expandtab = true        -- Use spaces instead of tabs
vim.opt.smartindent = true      -- Smart autoindenting
vim.opt.wrap = false            -- Disable line wrapping
vim.opt.cursorline = true       -- Highlight current line
vim.opt.termguicolors = true    -- True color support
vim.opt.mouse = "a"             -- Enable mouse support
vim.opt.signcolumn = "yes"      -- Always show signcolumn

-- Window navigation: Ctrl+H = focus tree, Ctrl+L = focus editor
vim.keymap.set("n", "<C-h>", "<cmd>Neotree focus<cr>", { desc = "Focus file tree" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Focus editor" })

-- ──────────────────────────────────────────────────────────────────────────────
-- KITTY TERMINAL BACKGROUND SYNC
-- Extends the editor background into Kitty's padding area via OSC 11.
-- On colorscheme load: sets terminal bg to match Neovim's Normal bg.
-- On exit: resets terminal bg to pywal's background color.
-- ──────────────────────────────────────────────────────────────────────────────
vim.api.nvim_create_autocmd("ColorScheme", {
  callback = function()
    -- Small delay to ensure highlight groups are fully loaded
    vim.defer_fn(function()
      local normal = vim.api.nvim_get_hl(0, { name = "Normal" })
      if normal.bg then
        local hex = string.format("#%06x", normal.bg)
        io.stdout:write(string.format("\027]11;%s\027\\", hex))
        io.stdout:flush()
      end
    end, 50)
  end,
})

vim.api.nvim_create_autocmd("VimLeave", {
  callback = function()
    -- Read the pywal background color and reset the terminal
    local handle = io.open(os.getenv("HOME") .. "/.cache/wal/colors.json", "r")
    if handle then
      local content = handle:read("*a")
      handle:close()
      local bg = content:match('"background"%s*:%s*"(#%x+)"')
      if bg then
        io.stdout:write(string.format("\027]11;%s\027\\", bg))
        io.stdout:flush()
      end
    end
  end,
})

-- Setup plugins via lazy.nvim
require("lazy").setup({
  -- [[ THEME ]]
  -- Optional: A clean and minimal theme (kanagawa is a solid default)
  {
    "rebelot/kanagawa.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd([[colorscheme kanagawa-dragon]])
    end,
  },

  -- [[ FILE TREE: neo-tree.nvim ]]
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    keys = {
      { "<leader>e", "<cmd>Neotree toggle<cr>", desc = "Toggle file tree" },
    },
    opts = {
      filesystem = {
        follow_current_file = { enabled = true },
        hijack_netrw_behavior = "open_current",
        filtered_items = {
          hide_dotfiles = false,
          hide_gitignored = false,
        },
      },
      window = {
        width = 30,
      },
    },
  },

  -- [[ WHICH-KEY: keybinding hints popup ]]
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      delay = 300,
      icons = {
        separator = "➜",
        group = " ",
      },
    },
    config = function(_, opts)
      local wk = require("which-key")
      wk.setup(opts)
      wk.add({
        { "<leader>e", desc = "Toggle file tree" },
        { "<leader>f", group = "Find" },
        { "<leader>v", group = "LSP" },
        { "<leader>vc", group = "Code" },
        { "<leader>vr", group = "Refactor" },
      })
    end,
  },

  -- [[ FUZZY FINDER: telescope.nvim ]]
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    config = function()
      local telescope = require("telescope")
      telescope.setup({
        defaults = {
          file_ignore_patterns = { "node_modules", ".git/" },
        },
      })
      -- Load fzf-native for faster sorting (silently fail if not compiled)
      pcall(telescope.load_extension, "fzf")

      local builtin = require("telescope.builtin")
      vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
      vim.keymap.set("n", "<leader>fs", builtin.current_buffer_fuzzy_find, { desc = "Search in current buffer" })
      vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Global search (live grep)" })
    end,
  },

  -- [[ SYNTAX HIGHLIGHTING: treesitter ]]
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    build = ":TSUpdate",
    main = "nvim-treesitter.configs",
    opts = {
      ensure_installed = { 
        "c", "cpp", "go", "lua", "python", "rust", 
        "c_sharp", "html", "svelte", "typescript", "javascript" 
      },
      auto_install = true,
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
      },
    },
  },

  -- [[ AUTOCOMPLETION: nvim-cmp ]]
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",    -- LSP source for nvim-cmp
      "L3MON4D3/LuaSnip",        -- Snippet engine
      "saadparwaiz1/cmp_luasnip",-- Snippets source for nvim-cmp
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.abort(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
          ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { 'i', 's' }),
          ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { 'i', 's' }),
        }),
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
        })
      })
    end,
  },

  -- [[ LSP CONFIGURATION ]]
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      -- Automatically install LSPs to stdpath for neovim
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
    config = function()
      -- Setup mason so it can manage external tooling
      require("mason").setup()

      -- Setup mason-lspconfig to ensure servers are installed
      require("mason-lspconfig").setup({
        ensure_installed = {
          "gopls",          -- Go
          "rust_analyzer",  -- Rust
          "omnisharp",      -- .NET / C#
          "clangd",         -- C, C++
          "html",           -- HTML
          "svelte",         -- Svelte
          "ts_ls",          -- TypeScript / JS
          -- Note: 'ty' is not in Mason by default, it relies on global system installation.
        },
      })

      -- Setup keybinds seamlessly for all attached LSPs using native autocommands
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local bufnr = args.buf
          local opts = { buffer = bufnr, remap = false }
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = bufnr, remap = false, desc = "Go to definition" })
          vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = bufnr, remap = false, desc = "Hover docs" })
          vim.keymap.set("n", "<leader>vws", vim.lsp.buf.workspace_symbol, { buffer = bufnr, remap = false, desc = "Workspace symbols" })
          vim.keymap.set("n", "<leader>vd", vim.diagnostic.open_float, { buffer = bufnr, remap = false, desc = "Diagnostics (float)" })
          vim.keymap.set("n", "[d", vim.diagnostic.goto_next, { buffer = bufnr, remap = false, desc = "Next diagnostic" })
          vim.keymap.set("n", "]d", vim.diagnostic.goto_prev, { buffer = bufnr, remap = false, desc = "Prev diagnostic" })
          vim.keymap.set("n", "<leader>vca", vim.lsp.buf.code_action, { buffer = bufnr, remap = false, desc = "Code action" })
          vim.keymap.set("n", "<leader>vrr", vim.lsp.buf.references, { buffer = bufnr, remap = false, desc = "References" })
          vim.keymap.set("n", "<leader>vrn", vim.lsp.buf.rename, { buffer = bufnr, remap = false, desc = "Rename symbol" })
          vim.keymap.set("i", "<C-h>", vim.lsp.buf.signature_help, { buffer = bufnr, remap = false, desc = "Signature help" })
        end,
      })

      -- Set up advanced capabilities for autocompletion
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

      -- Define default capabilities natively for all Neovim 0.11 LSP servers
      vim.lsp.config("*", {
        capabilities = capabilities,
      })
      
      -- Specifix overrides:
      vim.lsp.config("gopls", {
        settings = { gopls = { analyses = { unusedparams = true }, staticcheck = true } },
      })

      -- Explicitly configure the 'ty' python LSP (Astral typechecker), because it's not managed by Mason
      -- Neovim 0.11 makes custom LSP configuration extremely straightforward:
      vim.lsp.config("ty", {
        cmd = { "ty", "lsp" },
        filetypes = { "python" },
        root_markers = { "pyproject.toml", "setup.py", ".git" },
      })
      -- We explicitly enable 'ty' because mason-lspconfig only auto-enables servers it manages
      vim.lsp.enable("ty")
    end,
  },
})