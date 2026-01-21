-- This file needs to have same structure as nvconfig.lua
-- https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua
-- Please read that file to know all available options :(

---@type ChadrcConfig
local M = {}

M.base46 = {
  -- NvChad built-in themes:
  -- onedark, gruvbox, nord, tokyonight, catppuccin, decay, everforest
  -- rosepine, dracula, github_dark, ayu_dark, ayu_light, etc.
  -- Use :Telescope themes or :NvCheatsheet to see all available themes
  theme = "ayu_dark", -- Dark theme with good contrast

  transparency = true, -- Enable transparency

  hl_override = {
    Comment = { italic = true },
    ["@comment"] = { italic = true },
  },
}

M.ui = {
  statusline = {
    theme = "default", -- default/vscode/vscode_colored/minimal
    separator_style = "default", -- default/round/block/arrow
  },

  tabufline = {
    enabled = true,
    lazyload = false,
  },

  -- NvDash (dashboard)
  nvdash = {
    load_on_startup = false, -- Don't show dashboard on startup
  },
}

return M
