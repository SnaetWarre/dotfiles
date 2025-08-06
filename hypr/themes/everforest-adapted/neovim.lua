return {
    {
        "neanias/everforest-nvim",
        priority = 1000,
        config = function()
            require("everforest").setup({
                background = "soft",
                transparent_background_level = 0,
                italics = false,
                disable_italic_comments = true,
                sign_column_background = "none",
                ui_contrast = "low",
                dim_inactive_windows = false,
                diagnostic_text_highlight = false,
                diagnostic_virtual_text = "coloured",
                diagnostic_line_highlight = false,
                spell_foreground = false,
                show_eob = true,
                float_style = "bright",
                inlay_hints_background = "none",
                on_highlights = function(hl, palette)
                    -- Custom highlight overrides can go here
                end,
                colours_override = function(palette)
                    -- Custom color overrides can go here
                    return {}
                end,
            })
            vim.cmd.colorscheme("everforest")
        end,
    },
}
