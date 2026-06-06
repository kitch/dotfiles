return {
  {
    "ray-x/go.nvim",
    dependencies = {
      "ray-x/guihua.lua",
      "neovim/nvim-lspconfig",
      "nvim-treesitter/nvim-treesitter",
    },
    ft = { "go", "gomod", "gowork", "gosum" },
    build = ':lua require("go.install").update_all_sync()',
    opts = {
      lsp_cfg = false,      -- we configure gopls in lsp.lua
      lsp_gofumpt = true,
      lsp_on_attach = false,
      dap_debug = true,
      test_runner = "go",
      run_in_floaterm = false,
      luasnip = true,
    },
  },
}
