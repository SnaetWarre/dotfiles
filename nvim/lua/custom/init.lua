-- Set leader key to space
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Load remaps
require("custom.remap")

-- Load packer configuration
require("custom.packer") 