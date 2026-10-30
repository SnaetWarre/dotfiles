-- Leader key
vim.g.mapleader = " "

-- Bootstrapping lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
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
vim.opt.relativenumber = true  -- Absolute numbers like the reference (set true for hybrid)
vim.opt.tabstop = 4             -- 4 spaces for a tab
vim.opt.shiftwidth = 4          -- 4 spaces per indentation level
vim.opt.expandtab = true        -- Use spaces instead of tabs
vim.opt.smartindent = true      -- Smart autoindenting
vim.opt.wrap = false            -- Disable line wrapping
vim.opt.cursorline = true       -- Highlight current line
vim.opt.termguicolors = true    -- Needed for coloured undercurls and exact colours
vim.opt.mouse = "a"             -- Enable mouse support
vim.opt.clipboard = "unnamedplus" -- Use the system clipboard by default
vim.opt.signcolumn = "yes:2"    -- Two sign columns: git bar + diagnostic dot
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

-- Diagnostics: no virtual text, a ● in the gutter, coloured undercurl in the text
vim.diagnostic.config({
  virtual_text = false,
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "●",
      [vim.diagnostic.severity.WARN] = "●",
      [vim.diagnostic.severity.INFO] = "●",
      [vim.diagnostic.severity.HINT] = "●",
    },
  },
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = {
    border = "single",
    source = "if_many",
  },
})

-- Palette (eyeballed from the screenshot -- tweak freely)
local p = {
  fg     = "#d0d3da",
  bg     = "#1b1d23", -- editor background (solid, independent of your terminal)
  panel  = "#2a2d35", -- cursorline + statusline background
  dim    = "#5f6572", -- comments, line numbers, separators
  sel    = "#3b404b",
  red    = "#e06c75",
  orange = "#e8a35a",
  yellow = "#e5c07b",
  green  = "#98c379",
  cyan   = "#56b6c2",
  blue   = "#61afef",
  purple = "#c678dd",
}

local function hl(group, opts)
  vim.api.nvim_set_hl(0, group, opts)
end

local function apply_retro_ui()
  vim.o.background = "dark"
  vim.cmd.colorscheme("default")

  -- Solid background, only inside nvim
  hl("Normal", { fg = p.fg, bg = p.bg })
  hl("NormalNC", { fg = p.fg, bg = p.bg })
  hl("NormalFloat", { fg = p.fg, bg = p.bg })
  hl("EndOfBuffer", { fg = p.bg, bg = p.bg })
  hl("SignColumn", { bg = p.bg })
  hl("FoldColumn", { fg = p.dim, bg = p.bg })
  hl("LineNr", { fg = p.dim, bg = p.bg })
  hl("CursorLine", { bg = p.panel })
  hl("CursorLineNr", { fg = p.yellow, bg = p.panel, bold = true })
  hl("Visual", { bg = p.sel })
  hl("Search", { fg = "#000000", bg = p.yellow, bold = true })
  hl("IncSearch", { fg = "#000000", bg = p.orange, bold = true })
  hl("Pmenu", { fg = p.fg, bg = p.panel })
  hl("PmenuSel", { fg = "#000000", bg = p.cyan, bold = true })
  hl("FloatBorder", { fg = p.dim, bg = p.bg })
  hl("WinSeparator", { fg = p.dim, bg = p.bg })

  -- Syntax
  hl("Comment", { fg = p.dim, italic = true })
  hl("String", { fg = p.green })
  hl("Character", { fg = p.green })
  hl("Number", { fg = p.orange })
  hl("Boolean", { fg = p.orange })
  hl("Identifier", { fg = p.fg })
  hl("Function", { fg = p.blue, bold = true })
  hl("Statement", { fg = p.purple, bold = true })
  hl("Keyword", { fg = p.purple, bold = true })
  hl("Type", { fg = p.yellow })
  hl("Special", { fg = p.cyan })
  hl("Error", { fg = p.red, bold = true })
  hl("WarningMsg", { fg = p.yellow, bold = true })

  -- Diagnostics: coloured text for signs, curly coloured underline in the buffer
  hl("DiagnosticError", { fg = p.red })
  hl("DiagnosticWarn", { fg = p.yellow })
  hl("DiagnosticInfo", { fg = p.blue })
  hl("DiagnosticHint", { fg = p.cyan })
  hl("DiagnosticUnderlineError", { undercurl = true, sp = p.red })
  hl("DiagnosticUnderlineWarn", { undercurl = true, sp = p.yellow })
  hl("DiagnosticUnderlineInfo", { undercurl = true, sp = p.blue })
  hl("DiagnosticUnderlineHint", { undercurl = true, sp = p.cyan })

  -- Git gutter bars (gitsigns)
  hl("GitSignsAdd", { fg = p.green, bg = p.bg })
  hl("GitSignsChange", { fg = p.yellow, bg = p.bg })
  hl("GitSignsDelete", { fg = p.red, bg = p.bg })

  -- Statusline
  hl("StatusLine", { fg = p.fg, bg = p.panel })
  hl("StatusLineNC", { fg = p.dim, bg = p.panel })
  hl("RetroMode", { fg = p.fg, bg = p.panel, bold = true })
  hl("RetroFile", { fg = p.fg, bg = p.panel })
  hl("RetroMeta", { fg = p.dim, bg = p.panel })
  hl("RetroWarn", { fg = p.yellow, bg = p.panel })
  hl("RetroErr", { fg = p.red, bg = p.panel })
  hl("RetroPos", { fg = p.fg, bg = p.panel })
end

-- Three-letter mode names, Helix style
local short_modes = {
  n = "NOR",
  i = "INS",
  v = "SEL",
  V = "SEL",
  ["\22"] = "SEL",
  s = "SEL",
  S = "SEL",
  ["\19"] = "SEL",
  R = "REP",
  c = "CMD",
  r = "PRM",
  ["!"] = "SHL",
  t = "TERM",
}

function _G.retro_mode()
  local m = vim.api.nvim_get_mode().mode:sub(1, 1)
  return short_modes[m] or "NOR"
end

-- "● 2 ● 1" (warnings then errors), coloured per severity
function _G.retro_diag()
  local counts = vim.diagnostic.count(0)
  local warn = counts[vim.diagnostic.severity.WARN] or 0
  local err = counts[vim.diagnostic.severity.ERROR] or 0
  local out = ""
  if warn > 0 then out = out .. "%#RetroWarn# ● " .. warn end
  if err > 0 then out = out .. "%#RetroErr# ● " .. err end
  return out
end

-- Number of selected lines while in a visual mode
function _G.retro_sel()
  local m = vim.api.nvim_get_mode().mode:sub(1, 1)
  if m == "v" or m == "V" or m == "\22" then
    return (math.abs(vim.fn.line("v") - vim.fn.line(".")) + 1) .. " sel "
  end
  return ""
end

local function setup_retro_statusline()
  vim.o.statusline = table.concat({
    "%#RetroMode# %{v:lua.retro_mode()} ",
    "%#RetroMeta#⣿ ",
    "%#RetroFile#%f%m",
    "%#StatusLine#%=",
    "%{%v:lua.retro_diag()%}",
    "%#RetroMeta#  %{v:lua.retro_sel()}",
    "%#RetroPos# %l:%c ",
  })
end

apply_retro_ui()
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
            "",
            "",
            "",
            "",
            "you didn't open a file..........",
            "",
          },
          center = {
            { action = "Telescope find_files", desc = " Find file", icon = " ", key = "f" },
            { action = "Telescope oldfiles", desc = " Recent files", icon = " ", key = "r" },
            { action = "Telescope live_grep", desc = " Find text", icon = " ", key = "g" },
            { action = "Lazy", desc = " lazy.nvim", icon = " ", key = "l" },
            { action = "qa", desc = " Quit", icon = " ", key = "q" },
          },
          footer = function()
            return { "alr lil bro why are we even reading this type shi fr" }
          end,
        },
      })
    end,
  },

  -- [[ GIT GUTTER: the coloured bars left of the line numbers ]]
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "▁" },
        topdelete = { text = "▔" },
        changedelete = { text = "▎" },
        untracked = { text = "▎" },
      },
    },
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

  -- [[ MARKDOWN PREVIEW ]]
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

  -- [[ MARKDOWN IMAGES ]]
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
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
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
      "mason-org/mason.nvim",
      "mason-org/mason-lspconfig.nvim",
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

      -- Keybinds for all attached LSPs
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local bufnr = args.buf
          local function map(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, remap = false, desc = desc })
          end
          map("n", "gd", vim.lsp.buf.definition, "Go to definition")
          map("n", "K", vim.lsp.buf.hover, "Hover docs")
          map("n", "<leader>vws", vim.lsp.buf.workspace_symbol, "Workspace symbols")
          map("n", "<leader>vd", vim.diagnostic.open_float, "Diagnostics (float)")
          -- NOTE: your original had these two swapped ([d went to next)
          map("n", "[d", function() vim.diagnostic.jump({ count = -1, float = true }) end, "Prev diagnostic")
          map("n", "]d", function() vim.diagnostic.jump({ count = 1, float = true }) end, "Next diagnostic")
          map("n", "<leader>vca", vim.lsp.buf.code_action, "Code action")
          map("n", "<leader>vrr", vim.lsp.buf.references, "References")
          map("n", "<leader>vrn", vim.lsp.buf.rename, "Rename symbol")
          map("i", "<C-h>", vim.lsp.buf.signature_help, "Signature help")
        end,
      })

      -- Set up advanced capabilities for autocompletion
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

      -- Define default capabilities natively for all Neovim 0.11 LSP servers
      vim.lsp.config("*", {
        capabilities = capabilities,
      })

      -- Specific overrides:
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
