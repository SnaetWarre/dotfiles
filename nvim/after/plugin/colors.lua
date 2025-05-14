function ColorMyPencils(color)
    color = color or "rose-pine"
    local status_ok, _ = pcall(vim.cmd.colorscheme, color)
    if not status_ok then
        vim.cmd.colorscheme("default")
        return
    end

    vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
    vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
end

ColorMyPencils() 