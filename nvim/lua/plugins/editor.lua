return {
  -- Fuzzy finder
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    config = function()
      local telescope = require("telescope")
      telescope.setup({
        defaults = {
          path_display = { "truncate" },
          file_ignore_patterns = { ".git/", "node_modules/", "vendor/" },
        },
      })
      telescope.load_extension("fzf")
    end,
  },

  -- Syntax highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    main = "nvim-treesitter.config",
    opts = {
      ensure_installed = {
        "go", "gomod", "gowork", "gosum",
        "lua", "vim", "vimdoc",
        "yaml", "json", "toml",
        "bash", "dockerfile",
        "markdown", "markdown_inline",
        "python", "rust",
        "hcl",
      },
      highlight = { enable = true },
      indent = { enable = true },
    },
  },

  -- Auto pairs
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {},
  },

  -- Comment toggling
  {
    "numToStr/Comment.nvim",
    opts = {},
  },

  -- Surround motions
  {
    "kylechui/nvim-surround",
    event = "VeryLazy",
    opts = {},
  },

  -- Better f/t motions
  {
    "smoka7/hop.nvim",
    keys = {
      { "s", "<cmd>HopChar2<cr>", desc = "Hop 2 chars" },
    },
    opts = {},
  },
}
