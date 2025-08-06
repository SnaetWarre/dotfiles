return {
    {
        "rose-pine/neovim",
        name = "rose-pine",
        priority = 1000,
        config = function()
            require("rose-pine").setup({
                variant = "dawn",
                dark_variant = "main",
                bold_vert_split = false,
                dim_nc_background = false,
                disable_background = false,
                disable_float_background = false,
                disable_italics = true,
            })
            vim.cmd.colorscheme("rose-pine-dawn")
        end,
    },
}
