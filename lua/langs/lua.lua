-- lua/langs/lua.lua
-- Lua 开发环境配置：语法高亮、LSP、补全、格式化等功能
return {
  -- Treesitter 高亮与增量选择
  {
    "nvim-treesitter/nvim-treesitter",
    ft = {"lua"},
    build = ":TSUpdate",
    opts = {
      ensure_installed = {"lua"},
      highlight = { enable = true },
      indent = { enable = true },
    },
  },

  -- Lua LSP (lua-language-server)
  {
    "neovim/nvim-lspconfig",
    ft = {"lua"},
    dependencies = { "williamboman/mason.nvim", "williamboman/mason-lspconfig.nvim" },
    config = function()
      -- 安装与配置 lua-language-server
      require("mason").setup()
      require("mason-lspconfig").setup({ ensure_installed = { "lua_ls" } })
      local nvim_lsp = require("lspconfig")
      nvim_lsp.lua_ls.setup({
        settings = {
          Lua = {
            runtime = { version = 'LuaJIT', path = vim.split(package.path, ';') },
            diagnostics = { globals = {'vim'} },
            workspace = { library = vim.api.nvim_get_runtime_file('', true) },
            telemetry = { enable = false },
          }
        },
        capabilities = require("cmp_nvim_lsp").default_capabilities(),
      })
    end,
  },

  -- 自动补全
  {
    "hrsh7th/nvim-cmp",
    ft = {"lua"},
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
    },
    config = function()
      local cmp = require('cmp')
      cmp.setup.buffer({
        snippet = { expand = function(args) require('luasnip').lsp_expand(args.body) end },
        mapping = cmp.mapping.preset.insert({ ['<C-Space>'] = cmp.mapping.complete(), ['<CR>'] = cmp.mapping.confirm({ select = true }) }),
        sources = cmp.config.sources({ { name = 'nvim_lsp' }, { name = 'buffer' }, { name = 'path' } }),
      })
    end,
  },

  -- 代码格式化 (Stylua)
  {
    "jose-elias-alvarez/null-ls.nvim",
    ft = {"lua"},
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local null_ls = require('null-ls')
      null_ls.setup({
        sources = { null_ls.builtins.formatting.stylua },
      })
    end,
  },

  -- Snippet 支持
  {
    "L3MON4D3/LuaSnip",
    ft = {"lua"},
    dependencies = { "rafamadriz/friendly-snippets" },
    config = function()
      require('luasnip.loaders.from_vscode').lazy_load()
    end,
  },
}

