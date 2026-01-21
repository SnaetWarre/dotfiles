require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

-- Save file
map({ "n", "i", "v" }, "<C-s>", "<cmd>w<cr>", { desc = "Save file" })

-- Oil.nvim file manager
map("n", "-", "<cmd>Oil<cr>", { desc = "Open parent directory" })

-- DAP (debugging) keybindings
map("n", "<F5>", "<cmd>lua require'dap'.continue()<cr>", { desc = "DAP Continue" })
map("n", "<F10>", "<cmd>lua require'dap'.step_over()<cr>", { desc = "DAP Step Over" })
map("n", "<F11>", "<cmd>lua require'dap'.step_into()<cr>", { desc = "DAP Step Into" })
map("n", "<F12>", "<cmd>lua require'dap'.step_out()<cr>", { desc = "DAP Step Out" })
map("n", "<leader>db", "<cmd>lua require'dap'.toggle_breakpoint()<cr>", { desc = "DAP Toggle Breakpoint" })
map("n", "<leader>dr", "<cmd>lua require'dap'.repl.open()<cr>", { desc = "DAP REPL" })
map("n", "<leader>du", "<cmd>lua require'dapui'.toggle()<cr>", { desc = "DAP UI Toggle" })

-- Better window navigation (Tmux navigator handles C-hjkl)
-- These are fallbacks for when not using Tmux
-- map("n", "<C-h>", "<C-w>h", { desc = "Navigate to left window" })
-- map("n", "<C-j>", "<C-w>j", { desc = "Navigate to down window" })
-- map("n", "<C-k>", "<C-w>k", { desc = "Navigate to up window" })
-- map("n", "<C-l>", "<C-w>l", { desc = "Navigate to right window" })

-- Resize windows with arrows
map("n", "<C-Up>", ":resize -2<CR>", { desc = "Resize window up" })
map("n", "<C-Down>", ":resize +2<CR>", { desc = "Resize window down" })
map("n", "<C-Left>", ":vertical resize -2<CR>", { desc = "Resize window left" })
map("n", "<C-Right>", ":vertical resize +2<CR>", { desc = "Resize window right" })

-- Better indenting
map("v", "<", "<gv", { desc = "Indent left" })
map("v", ">", ">gv", { desc = "Indent right" })

-- Move text up and down
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move text down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move text up" })

-- Keep cursor centered when scrolling
map("n", "<C-d>", "<C-d>zz", { desc = "Scroll down and center" })
map("n", "<C-u>", "<C-u>zz", { desc = "Scroll up and center" })
map("n", "n", "nzzzv", { desc = "Next search result (centered)" })
map("n", "N", "Nzzzv", { desc = "Previous search result (centered)" })

-- Paste without yanking in visual mode
map("x", "<leader>p", '"_dP', { desc = "Paste without yanking" })
