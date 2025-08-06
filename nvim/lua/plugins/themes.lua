-- Dynamic Theme Plugin Loader
-- This file loads theme plugins based on the current theme configuration

local theme_loader = require('theme-loader')

-- Load the current theme configuration
local theme_config = theme_loader.load_theme()

-- If we got a valid theme config, return it; otherwise return a default
if theme_config and type(theme_config) == "table" and #theme_config > 0 then
    return theme_config
else
    -- Default fallback theme
    return {
        {
            'folke/tokyonight.nvim',
            priority = 1000,
            config = function()
                require('tokyonight').setup {
                    styles = {
                        comments = { italic = false },
                    },
                }
                vim.cmd.colorscheme 'tokyonight-night'
            end,
        }
    }
end
