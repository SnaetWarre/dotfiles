return {
  'dmtrKovalenko/fff.nvim',
  build = function()
    require("fff.download").download_or_build_binary()
  end,
  lazy = false,
  keys = {
    { "ff", function() require('fff').find_files() end, desc = 'Find files' },
    { "fg", function() require('fff').live_grep() end, desc = 'Live grep' },
  },
  config = function()
    require("fff").setup({})
  end,
}