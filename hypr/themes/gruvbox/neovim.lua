return {
    {
        "ellisonleao/gruvbox.nvim",
        priority = 1000,
        config = function()
            require("gruvbox").setup({
                contrast = "hard",
                transparent_mode = false,
                palette_overrides = {},
                overrides = {},
                dim_inactive = false,
                terminal_colors = true,
            })
            vim.cmd.colorscheme("gruvbox")
        end,
    },
}
