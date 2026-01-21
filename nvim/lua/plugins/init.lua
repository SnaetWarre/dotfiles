return {
  -- Conform (formatter)
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    opts = require "configs.conform",
  },

  -- LSP configuration
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },

  -- Treesitter (syntax highlighting)
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "vim",
        "lua",
        "vimdoc",
        "html",
        "css",
        "javascript",
        "typescript",
        "tsx",
        "rust",
        "python",
        "go",
        "c",
        "cpp",
        "json",
        "yaml",
        "toml",
        "markdown",
      },
    },
  },

  -- Tmux integration (seamless navigation with Ctrl-hjkl)
  {
    "christoomey/vim-tmux-navigator",
    lazy = false,
    cmd = {
      "TmuxNavigateLeft",
      "TmuxNavigateDown",
      "TmuxNavigateUp",
      "TmuxNavigateRight",
      "TmuxNavigatePrevious",
    },
    keys = {
      { "<C-h>", "<cmd>TmuxNavigateLeft<cr>", desc = "Navigate left (tmux/nvim)" },
      { "<C-j>", "<cmd>TmuxNavigateDown<cr>", desc = "Navigate down (tmux/nvim)" },
      { "<C-k>", "<cmd>TmuxNavigateUp<cr>", desc = "Navigate up (tmux/nvim)" },
      { "<C-l>", "<cmd>TmuxNavigateRight<cr>", desc = "Navigate right (tmux/nvim)" },
    },
  },

  -- Oil.nvim (file manager like netrw but better)
  {
    "stevearc/oil.nvim",
    lazy = false,
    opts = {
      columns = {
        "icon",
        "permissions",
        "size",
        "mtime",
      },
      keymaps = {
        ["g?"] = "actions.show_help",
        ["<CR>"] = "actions.select",
        ["<C-v>"] = "actions.select_vsplit",
        ["<C-s>"] = "actions.select_split",
        ["<C-t>"] = "actions.select_tab",
        ["<C-p>"] = "actions.preview",
        ["<C-c>"] = "actions.close",
        ["<C-r>"] = "actions.refresh",
        ["-"] = "actions.parent",
        ["_"] = "actions.open_cwd",
        ["`"] = "actions.cd",
        ["~"] = "actions.tcd",
        ["gs"] = "actions.change_sort",
        ["gx"] = "actions.open_external",
        ["g."] = "actions.toggle_hidden",
        ["g\\"] = "actions.toggle_trash",
      },
      view_options = {
        show_hidden = true,
      },
    },
    keys = {
      { "-", "<cmd>Oil<cr>", desc = "Open parent directory" },
    },
  },



  -- Marks plugin (better mark visualization)
  {
    "chentoast/marks.nvim",
    lazy = false,
    opts = {
      builtin_marks = { "<", ">", "^" },
    },
  },

  -- LuaSnip snippets
  {
    "L3MON4D3/LuaSnip",
    config = function(plugin, opts)
      require("luasnip").setup { enable_autosnippets = true }
      require("luasnip.loaders.from_lua").load { paths = "~/.config/nvim/snippets/" }
    end,
  },

  -- Typst preview
  {
    "chomosuke/typst-preview.nvim",
    ft = "typst",
    build = function()
      require("typst-preview").update()
    end,
  },

  -- DAP (Debug Adapter Protocol)
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
    },
    config = function()
      local dap = require "dap"

      -- Codelldb adapter for Rust/C/C++
      dap.adapters.codelldb = {
        type = "server",
        port = "${port}",
        executable = {
          command = vim.fn.stdpath "data" .. "/mason/bin/codelldb",
          args = { "--port", "${port}" },
        },
      }

      -- Rust configuration
      dap.configurations.rust = {
        {
          name = "Launch",
          type = "codelldb",
          request = "launch",
          program = function()
            return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/target/debug/", "file")
          end,
          cwd = "${workspaceFolder}",
          stopOnEntry = false,
        },
      }

      -- C/C++ use same config as Rust
      dap.configurations.c = dap.configurations.rust
      dap.configurations.cpp = dap.configurations.rust
    end,
    keys = {
      { "<F5>", "<cmd>lua require'dap'.continue()<cr>", desc = "DAP Continue" },
      { "<F10>", "<cmd>lua require'dap'.step_over()<cr>", desc = "DAP Step Over" },
      { "<F11>", "<cmd>lua require'dap'.step_into()<cr>", desc = "DAP Step Into" },
      { "<F12>", "<cmd>lua require'dap'.step_out()<cr>", desc = "DAP Step Out" },
      { "<leader>db", "<cmd>lua require'dap'.toggle_breakpoint()<cr>", desc = "DAP Toggle Breakpoint" },
      { "<leader>dr", "<cmd>lua require'dap'.repl.open()<cr>", desc = "DAP REPL" },
    },
  },

  -- DAP UI
  {
    "rcarriga/nvim-dap-ui",
    dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
    config = function()
      require("dapui").setup()

      -- Auto-open DAP UI when debugging starts
      local dap, dapui = require "dap", require "dapui"
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end
    end,
    keys = {
      { "<leader>du", "<cmd>lua require'dapui'.toggle()<cr>", desc = "DAP UI Toggle" },
    },
  },
}
