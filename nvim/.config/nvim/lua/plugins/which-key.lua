return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  init = function()
    vim.o.timeout = true
    vim.o.timeoutlen = 500
  end,
  opts = {
    -- Only trigger which-key for leader in NORMAL mode
    triggers = {
      { "<leader>", mode = { "n" } },
    },
  },
}

