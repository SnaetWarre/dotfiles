-- Keymaps
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

-- NvimTree
vim.keymap.set("n", "<C-n>", ":NvimTreeToggle<CR>")
vim.keymap.set("n", "<leader>e", ":NvimTreeFocus<CR>")

-- Terminal
vim.keymap.set("n", "<leader>tf", ":ToggleTerm direction=float<CR>")
vim.keymap.set("n", "<leader>th", ":ToggleTerm direction=horizontal<CR>")
vim.keymap.set("n", "<leader>tv", ":ToggleTerm direction=vertical<CR>")

-- Custom terminal for opencode AI CLI
local Terminal = require('toggleterm.terminal').Terminal
local opencode_term = Terminal:new({
  cmd = "opencode",
  dir = "git_dir",
  direction = "vertical",
  size = 80,
  close_on_exit = false,
  on_open = function(term)
    vim.cmd("startinsert!")
    vim.api.nvim_buf_set_keymap(term.bufnr, "n", "q", "<cmd>close<CR>", {noremap = true, silent = true})
  end,
  on_close = function(term)
    vim.cmd("startinsert!")
  end,
})

function _opencode_toggle()
  opencode_term:toggle()
end

vim.keymap.set("n", "<leader>oc", "<cmd>lua _opencode_toggle()<CR>")

-- Toggle file tree only
vim.keymap.set("n", "<leader>w", ":NvimTreeToggle<CR>")

-- Telescope
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})

-- Harpoon
local mark = require("harpoon.mark")
local ui = require("harpoon.ui")

vim.keymap.set("n", "<leader>a", mark.add_file)
vim.keymap.set("n", "<C-e>", ui.toggle_quick_menu)

vim.keymap.set("n", "<C-h>", function() ui.nav_file(1) end)
vim.keymap.set("n", "<C-t>", function() ui.nav_file(2) end)
vim.keymap.set("n", "<C-m>", function() ui.nav_file(3) end)
vim.keymap.set("n", "<C-s>", function() ui.nav_file(4) end)

-- Undotree
vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle)

-- Fugitive
vim.keymap.set("n", "<leader>gs", vim.cmd.Git)

-- LSP
local lsp = require('lsp-zero').preset({})

lsp.on_attach(function(client, bufnr)
  lsp.default_keymaps({buffer = bufnr})
end)

-- (Optional) Configure lua language server for neovim
require('lspconfig').lua_ls.setup(lsp.nvim_lua_ls())

lsp.setup()

-- Treesitter
require('nvim-treesitter.configs').setup({
  ensure_installed = { "lua", "vim", "vimdoc" },
  auto_install = true,
  highlight = { enable = true },
  indent = { enable = true },
})

-- Comment
require('Comment').setup()

-- Set colorscheme
vim.cmd.colorscheme "catppuccin"

-- Disable netrw for nvim-tree
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Auto-open file tree on startup
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    -- Open file tree
    vim.cmd("NvimTreeOpen")
  end,
})
