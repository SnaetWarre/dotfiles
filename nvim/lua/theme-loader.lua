-- Theme Loader for Neovim
-- This module loads theme configurations directly from theme directories

local M = {}

-- Get the current theme name from environment or file
local function get_current_theme()
    -- First try environment variable
    local theme = os.getenv("THEME_NAME")
    if theme then
        return theme
    end

    -- Fallback to reading from current_theme file
    local theme_file = io.open(os.getenv("HOME") .. "/.config/hypr/current_theme", "r")
    if theme_file then
        theme = theme_file:read("*line")
        theme_file:close()
        return theme
    end

    -- Default fallback
    return "tokyo-night"
end

-- Load theme configuration from theme directory
function M.load_theme()
    local theme_name = get_current_theme()
    local theme_path = os.getenv("HOME") .. "/.config/hypr/themes/" .. theme_name .. "/neovim.lua"

    -- Check if theme file exists
    local file = io.open(theme_path, "r")
    if not file then
        print("Theme file not found: " .. theme_path)
        print("Falling back to default theme")
        return {}
    end
    file:close()

    -- Load the theme configuration
    local ok, theme_config = pcall(dofile, theme_path)
    if not ok then
        print("Error loading theme config: " .. theme_config)
        return {}
    end

    return theme_config or {}
end

-- Apply static monochrome colors to NvimTree
function M.apply_static_nvimtree_colors()
    -- Static monochrome color scheme for NvimTree (never changes)
    vim.api.nvim_set_hl(0, 'NvimTreeNormal', { bg = '#1a1a1a', fg = '#d0d0d0' })
    vim.api.nvim_set_hl(0, 'NvimTreeEndOfBuffer', { bg = '#1a1a1a' })
    vim.api.nvim_set_hl(0, 'NvimTreeWinSeparator', { bg = '#1a1a1a', fg = '#404040' })

    -- Folder colors
    vim.api.nvim_set_hl(0, 'NvimTreeFolderName', { fg = '#a0a0a0', bold = true })
    vim.api.nvim_set_hl(0, 'NvimTreeOpenedFolderName', { fg = '#ffffff', bold = true })
    vim.api.nvim_set_hl(0, 'NvimTreeEmptyFolderName', { fg = '#606060' })
    vim.api.nvim_set_hl(0, 'NvimTreeRootFolder', { fg = '#ffffff', bold = true })

    -- File colors
    vim.api.nvim_set_hl(0, 'NvimTreeFileName', { fg = '#d0d0d0' })
    vim.api.nvim_set_hl(0, 'NvimTreeExecFile', { fg = '#ffffff', bold = true })
    vim.api.nvim_set_hl(0, 'NvimTreeSpecialFile', { fg = '#c0c0c0', underline = true })

    -- Git colors (monochrome)
    vim.api.nvim_set_hl(0, 'NvimTreeGitDirty', { fg = '#909090' })
    vim.api.nvim_set_hl(0, 'NvimTreeGitStaged', { fg = '#b0b0b0' })
    vim.api.nvim_set_hl(0, 'NvimTreeGitNew', { fg = '#e0e0e0' })
    vim.api.nvim_set_hl(0, 'NvimTreeGitDeleted', { fg = '#707070' })
    vim.api.nvim_set_hl(0, 'NvimTreeGitIgnored', { fg = '#505050' })

    -- Indent and cursor
    vim.api.nvim_set_hl(0, 'NvimTreeIndentMarker', { fg = '#404040' })
    vim.api.nvim_set_hl(0, 'NvimTreeCursorLine', { bg = '#2a2a2a' })
    vim.api.nvim_set_hl(0, 'NvimTreeCursorColumn', { bg = '#2a2a2a' })

    -- Symbols
    vim.api.nvim_set_hl(0, 'NvimTreeSymlink', { fg = '#a0a0a0', italic = true })
    vim.api.nvim_set_hl(0, 'NvimTreeImageFile', { fg = '#b0b0b0' })

    -- Window title
    vim.api.nvim_set_hl(0, 'NvimTreeWindowPicker', { bg = '#404040', fg = '#ffffff', bold = true })
end

return M
