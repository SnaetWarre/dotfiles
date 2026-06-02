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
vim.opt.termguicolors = false   -- Let Neovim use the terminal's palette
vim.opt.mouse = "a"             -- Enable mouse support
vim.opt.clipboard = "unnamedplus" -- Use the system clipboard by default
vim.opt.signcolumn = "yes"      -- Always show signcolumn
vim.opt.laststatus = 2          -- Compact local statusline like the reference
vim.opt.showmode = false        -- Statusline owns mode display
vim.opt.fillchars = {
  eob = " ",
  fold = " ",
  foldopen = " ",
  foldsep = " ",
  foldclose = " ",
  horiz = "─",
  horizup = "┴",
  horizdown = "┬",
  vert = "│",
  vertleft = "┤",
  vertright = "├",
  verthoriz = "┼",
}

if vim.fn.has("nvim-0.11") == 1 then
  vim.opt.winborder = "single"
end

vim.diagnostic.config({
  virtual_text = false,
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = {
    border = "single",
    source = "if_many",
  },
})

local function set_hl(group, opts)
  opts = vim.tbl_extend("force", { fg = "NONE", bg = "NONE" }, opts or {})
  vim.api.nvim_set_hl(0, group, opts)
end

local function apply_terminal_retro_ui()
  vim.o.background = "dark"
  vim.cmd.colorscheme("default")

  set_hl("Normal", {})
  set_hl("NormalNC", {})
  set_hl("EndOfBuffer", {})
  set_hl("SignColumn", {})
  set_hl("LineNr", { ctermfg = 8 })
  set_hl("CursorLine", { ctermbg = 0 })
  set_hl("CursorLineNr", { ctermfg = 15, bold = true })
  set_hl("Visual", { ctermbg = 8 })
  set_hl("Search", { ctermfg = 0, ctermbg = 11, bold = true })
  set_hl("IncSearch", { ctermfg = 0, ctermbg = 3, bold = true })
  set_hl("Pmenu", { ctermfg = 7, ctermbg = 0 })
  set_hl("PmenuSel", { ctermfg = 0, ctermbg = 6, bold = true })
  set_hl("FloatBorder", { ctermfg = 8 })
  set_hl("WinSeparator", { ctermfg = 8 })

  set_hl("Comment", { ctermfg = 8, italic = true })
  set_hl("String", { ctermfg = 2 })
  set_hl("Character", { ctermfg = 2 })
  set_hl("Number", { ctermfg = 3 })
  set_hl("Boolean", { ctermfg = 3 })
  set_hl("Identifier", { ctermfg = 6 })
  set_hl("Function", { ctermfg = 4, bold = true })
  set_hl("Statement", { ctermfg = 5, bold = true })
  set_hl("Keyword", { ctermfg = 5, bold = true })
  set_hl("Type", { ctermfg = 6 })
  set_hl("Special", { ctermfg = 13 })
  set_hl("Error", { ctermfg = 1, bold = true })
  set_hl("WarningMsg", { ctermfg = 3, bold = true })
  set_hl("DiagnosticError", { ctermfg = 1 })
  set_hl("DiagnosticWarn", { ctermfg = 3 })
  set_hl("DiagnosticInfo", { ctermfg = 4 })
  set_hl("DiagnosticHint", { ctermfg = 6 })

  set_hl("StatusLine", { ctermfg = 7, ctermbg = 0 })
  set_hl("StatusLineNC", { ctermfg = 8, ctermbg = 0 })
  set_hl("RetroMode", { ctermfg = 0, ctermbg = 6, bold = true })
  set_hl("RetroFile", { ctermfg = 15, ctermbg = 0, bold = true })
  set_hl("RetroMeta", { ctermfg = 8, ctermbg = 0 })
  set_hl("RetroPos", { ctermfg = 0, ctermbg = 6, bold = true })
end

local modes = {
  n = "NORMAL",
  no = "OP",
  nov = "OP",
  noV = "OP",
  ["no\22"] = "OP",
  niI = "NORMAL",
  niR = "NORMAL",
  niV = "NORMAL",
  nt = "NORMAL",
  v = "VISUAL",
  vs = "VISUAL",
  V = "V-LINE",
  ["\22"] = "V-BLOCK",
  s = "SELECT",
  S = "S-LINE",
  ["\19"] = "S-BLOCK",
  i = "INSERT",
  ic = "INSERT",
  ix = "INSERT",
  R = "REPLACE",
  Rc = "REPLACE",
  Rx = "REPLACE",
  Rv = "V-REPLACE",
  c = "COMMAND",
  cv = "EX",
  ce = "EX",
  r = "PROMPT",
  rm = "MORE",
  ["r?"] = "CONFIRM",
  ["!"] = "SHELL",
  t = "TERM",
}

function _G.retro_mode()
  return modes[vim.api.nvim_get_mode().mode] or "NORMAL"
end

function _G.retro_diagnostics()
  local counts = vim.diagnostic.count(0)
  local total = 0
  for _, count in pairs(counts) do
    total = total + count
  end
  return total > 0 and ("   " .. total) or ""
end

local function setup_retro_statusline()
  vim.o.statusline = table.concat({
    "%#RetroMode# %{v:lua.retro_mode()} ",
    "%#RetroFile# %t%m",
    "%=",
    "%#RetroMeta# %{&fileencoding != '' ? &fileencoding : &encoding}",
    "%{v:lua.retro_diagnostics()}",
    "  %y  %p%% ",
    "%#RetroPos# %l:%c ",
  })
end

apply_terminal_retro_ui()
setup_retro_statusline()

-- Window navigation: Ctrl+H = focus tree, Ctrl+L = focus editor
vim.keymap.set("n", "<C-h>", "<cmd>Neotree focus<cr>", { desc = "Focus file tree" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Focus editor" })

-- Setup plugins via lazy.nvim
require("lazy").setup({
  -- [[ DASHBOARD ]]
  {
    "nvimdev/dashboard-nvim",
    event = "VimEnter",
    dependencies = { { "nvim-tree/nvim-web-devicons" } },
    config = function()
      require("dashboard").setup({
        theme = "doom",
        config = {
          header = {
            "",
            "",
            "",
            "",
            " ██╗   ██╗ █████╗     ███╗   ███╗██╗   ██╗███╗   ███╗ ",
            " ╚██╗ ██╔╝██╔══██╗    ████╗ ████║██║   ██║████╗ ████║ ",
            "  ╚████╔╝ ███████║    ██╔████╔██║██║   ██║██╔████╔██║ ",
            "   ╚██╔╝  ██╔══██║    ██║╚██╔╝██║██║   ██║██║╚██╔╝██║ ",
            "    ██║   ██║  ██║    ██║ ╚═╝ ██║╚██████╔╝██║ ╚═╝ ██║ ",
            "    ╚═╝   ╚═╝  ╚═╝    ╚═╝     ╚═╝ ╚═════╝ ╚═╝     ╚═╝ ",
            "",
            "",
            "",
          },
          center = {
            { action = "Telescope find_files", desc = " Find file", icon = " ", key = "f" },
            { action = "Telescope oldfiles", desc = " Recent files", icon = " ", key = "r" },
            { action = "Telescope live_grep", desc = " Find text", icon = " ", key = "g" },
            { action = "Lazy", desc = " lazy.nvim", icon = "󰒲 ", key = "l" },
            { action = "qa", desc = " Quit", icon = " ", key = "q" },
          },
          footer = function()
            local stats = require("lazy").stats()
            return { "alr lil bro why are we even reading this type shi fr" }
          end,
        },
      })
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

  -- [[ MARKDOWN IMAGES + PREVIEW ]]
  {
    "iamcco/markdown-preview.nvim",
    ft = { "markdown" },
    build = function()
      vim.fn["mkdp#util#install"]()
    end,
    config = function()
      vim.g.mkdp_auto_start = 0
      vim.g.mkdp_auto_close = 1
      vim.g.mkdp_refresh_slow = 0
      vim.g.mkdp_open_to_the_world = 0
      vim.g.mkdp_browser = ""

      vim.keymap.set("n", "<leader>mp", "<cmd>MarkdownPreviewToggle<cr>", { desc = "Toggle markdown preview" })
    end,
  },

  -- [[ MARKDOWN IMAGES + PREVIEW ]]
  {
    "3rd/image.nvim",
    ft = "markdown",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      backend = "kitty",
      processor = "magick_cli",
      integrations = {
        markdown = {
          enabled = true,
          clear_in_insert_mode = false,
          download_remote_images = true,
          only_render_image_at_cursor = false,
        },
      },
      max_width = 100,
      max_height = 30,
      window_overlap_clear_enabled = true,
      window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" },
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
          "lua_ls",         -- Lua, including Hyprland's Lua config stubs
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

      local hypr_stubs = "/usr/share/hypr/stubs"
      local lua_workspace_library = {
        vim.env.VIMRUNTIME,
        vim.fn.stdpath("config") .. "/lua",
      }

      if vim.uv.fs_stat(hypr_stubs) then
        table.insert(lua_workspace_library, hypr_stubs)
      end

      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            diagnostics = {
              globals = { "hl", "vim" },
            },
            workspace = {
              checkThirdParty = false,
              library = lua_workspace_library,
            },
          },
        },
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
