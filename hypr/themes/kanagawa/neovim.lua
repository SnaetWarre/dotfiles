return {
    {
        "rebelot/kanagawa.nvim",
        priority = 1000,
        config = function()
            require("kanagawa").setup({
                compile = false,
                undercurl = true,
                commentStyle = { italic = false },
                functionStyle = {},
                keywordStyle = {},
                statementStyle = {},
                typeStyle = {},
                transparent = false,
                dimInactive = false,
                terminalColors = true,
                colors = {
                    theme = {
                        all = {
                            ui = {
                                bg_gutter = "none"
                            }
                        }
                    }
                },
                overrides = function(colors)
                    return {}
                end,
                theme = "wave",
                background = {
                    dark = "wave",
                    light = "lotus"
                },
            })
            vim.cmd.colorscheme("kanagawa")
        end,
    },
}
