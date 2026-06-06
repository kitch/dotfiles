return {
  -- LSP installer
  {
    "williamboman/mason.nvim",
    opts = {},
  },

  -- Bridge mason ↔ lspconfig
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    opts = {
      ensure_installed = {
        "gopls",        -- Go
        "lua_ls",       -- Lua
        "yamlls",       -- YAML / Kubernetes manifests
        "dockerls",     -- Dockerfile
        "bashls",       -- Shell scripts
        "terraformls",  -- Terraform
        "pyright",      -- Python
      },
      automatic_installation = true,
    },
  },

  -- LSP configs
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      local lspconfig = require("lspconfig")
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      local on_attach = function(_, buf)
        local map = function(keys, func, desc)
          vim.keymap.set("n", keys, func, { buffer = buf, desc = desc })
        end
        map("gd",         vim.lsp.buf.definition,      "Go to definition")
        map("gD",         vim.lsp.buf.declaration,     "Go to declaration")
        map("gi",         vim.lsp.buf.implementation,  "Implementation")
        map("gr",         "<cmd>Telescope lsp_references<cr>", "References")
        map("K",          vim.lsp.buf.hover,           "Hover docs")
        map("<leader>rn", vim.lsp.buf.rename,          "Rename")
        map("<leader>ca", vim.lsp.buf.code_action,     "Code action")
        map("<leader>f",  function() vim.lsp.buf.format({ async = true }) end, "Format")
      end

      -- Go
      lspconfig.gopls.setup({
        capabilities = capabilities,
        on_attach = on_attach,
        settings = {
          gopls = {
            analyses = { unusedparams = true, shadow = true },
            staticcheck = true,
            gofumpt = true,
          },
        },
      })

      -- YAML — with Kubernetes schema detection
      lspconfig.yamlls.setup({
        capabilities = capabilities,
        on_attach = on_attach,
        settings = {
          yaml = {
            schemas = {
              kubernetes = {
                "/*.k8s.yaml", "/*.k8s.yml",
                "/manifests/**/*.yaml", "/manifests/**/*.yml",
                "/deploy/**/*.yaml", "/deploy/**/*.yml",
                "/helm/**/*.yaml",
              },
            },
            schemaStore = { enable = true },
            validate = true,
          },
        },
      })

      -- Lua (for editing this config)
      lspconfig.lua_ls.setup({
        capabilities = capabilities,
        on_attach = on_attach,
        settings = {
          Lua = {
            diagnostics = { globals = { "vim" } },
            workspace = { checkThirdParty = false },
            telemetry = { enable = false },
          },
        },
      })

      -- Simple setups
      for _, server in ipairs({ "dockerls", "bashls", "terraformls", "pyright" }) do
        lspconfig[server].setup({ capabilities = capabilities, on_attach = on_attach })
      end

      -- Diagnostic signs
      vim.diagnostic.config({
        virtual_text = true,
        signs = true,
        underline = true,
        update_in_insert = false,
        severity_sort = true,
      })
    end,
  },

  -- Completion
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "rafamadriz/friendly-snippets",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      require("luasnip.loaders.from_vscode").lazy_load()

      cmp.setup({
        snippet = {
          expand = function(args) luasnip.lsp_expand(args.body) end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-j>"] = cmp.mapping.select_next_item(),
          ["<C-k>"] = cmp.mapping.select_prev_item(),
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then luasnip.expand_or_jump()
            else fallback() end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
        }),
      })
    end,
  },

  -- Formatting
  {
    "stevearc/conform.nvim",
    opts = {
      format_on_save = { timeout_ms = 500, lsp_fallback = true },
      formatters_by_ft = {
        go       = { "goimports", "gofmt" },
        lua      = { "stylua" },
        yaml     = { "prettier" },
        json     = { "prettier" },
        markdown = { "prettier" },
        sh       = { "shfmt" },
      },
    },
  },
}
