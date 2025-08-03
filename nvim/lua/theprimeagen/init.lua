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
local status_ok, toggleterm = pcall(require, 'toggleterm.terminal')
if status_ok then
  local Terminal = toggleterm.Terminal
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
end

-- Toggle file tree only
vim.keymap.set("n", "<leader>w", ":NvimTreeToggle<CR>")

-- Telescope
local status_ok, builtin = pcall(require, 'telescope.builtin')
if status_ok then
  vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
  vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
  vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
  vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
end

-- Harpoon
local status_ok, mark = pcall(require, "harpoon.mark")
local status_ok2, ui = pcall(require, "harpoon.ui")
if status_ok and status_ok2 then
  vim.keymap.set("n", "<leader>a", mark.add_file)
  vim.keymap.set("n", "<C-e>", ui.toggle_quick_menu)

  vim.keymap.set("n", "<C-h>", function() ui.nav_file(1) end)
  vim.keymap.set("n", "<C-t>", function() ui.nav_file(2) end)
  vim.keymap.set("n", "<C-m>", function() ui.nav_file(3) end)
  vim.keymap.set("n", "<C-s>", function() ui.nav_file(4) end)
end

-- Undotree
vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle)

-- Fugitive
vim.keymap.set("n", "<leader>gs", vim.cmd.Git)

-- Spectre (search and replace)
vim.keymap.set("n", "<leader>S", "<cmd>lua require('spectre').open()<CR>")
vim.keymap.set("n", "<leader>sw", "<cmd>lua require('spectre').open_visual({select_word=true})<CR>")
vim.keymap.set("v", "<leader>sw", "<cmd>lua require('spectre').open_visual()<CR>")

-- Buffer navigation
vim.keymap.set("n", "<leader>bp", "<cmd>BufferLinePick<CR>")
vim.keymap.set("n", "<leader>bc", "<cmd>BufferLinePickClose<CR>")
vim.keymap.set("n", "<leader>bl", "<cmd>BufferLineCloseLeft<CR>")
vim.keymap.set("n", "<leader>br", "<cmd>BufferLineCloseRight<CR>")

-- Project navigation
vim.keymap.set("n", "<leader>pp", "<cmd>lua require('telescope').extensions.projects.projects()<CR>")

-- Treesitter
local status_ok, treesitter = pcall(require, 'nvim-treesitter.configs')
if status_ok then
  treesitter.setup({
    ensure_installed = { "lua", "vim", "vimdoc" },
    auto_install = true,
    highlight = { enable = true },
    indent = { enable = true },
  })
end

-- Comment
local status_ok, comment = pcall(require, 'Comment')
if status_ok then
  comment.setup()
end

-- Set colorscheme
vim.cmd.colorscheme "catppuccin"

-- Disable netrw for nvim-tree
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Auto-open file tree on startup (commented out to avoid potential issues)
-- vim.api.nvim_create_autocmd("VimEnter", {
--   callback = function()
--     -- Open file tree
--     vim.cmd("NvimTreeOpen")
--   end,
-- })
