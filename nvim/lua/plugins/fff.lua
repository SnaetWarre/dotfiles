return {
  'dmtrKovalenko/fff.nvim',
  build = function()
    require("fff.download").download_or_build_binary()
  end,
  lazy = false,
  config = function()
    require("fff").setup({
      -- Use sensible defaults
    })
    -- Map <leader>f to open fff file finder
    vim.keymap.set("n", "<leader>f", ":Fff<CR>", { noremap = true, silent = true })
  end,
}