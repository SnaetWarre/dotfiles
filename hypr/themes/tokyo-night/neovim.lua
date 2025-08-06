return {
    {
        "folke/tokyonight.nvim",
        priority = 1000,
        config = function()
            require("tokyonight").setup({
                style = "night",
                transparent = false,
                terminal_colors = true,
                styles = {
                    comments = { italic = false },
                    keywords = { italic = false },
                    functions = {},
                    variables = {},
                    sidebars = "dark",
                    floats = "dark",
                },
            })
            vim.cmd.colorscheme("tokyonight-night")
        end,
    },
}
