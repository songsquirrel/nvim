-- Lua 开发环境配置
return {
  -- 1. Treesitter 支持
  {
    "nvim-treesitter/nvim-treesitter",
    ft = {"lua"},
    opts = {
      ensure_installed = {"lua"},
      highlight = { enable = true },
      indent = { enable = true },
    },
  },

  -- 2. LSP 配置
  {
    "neovim/nvim-lspconfig",
    ft = {"lua"},
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
    config = function()
      local lspconfig = require("lspconfig")
      local lsp_core = require('core.lsp')
      
      -- 导入通用 CMP 配置
      require('core.cmp')
      
      require("mason-lspconfig").setup({ 
        ensure_installed = { "lua_ls" } 
      })
      
      lspconfig.lua_ls.setup({
        settings = {
          Lua = {
            runtime = { version = 'LuaJIT', path = vim.split(package.path, ';') },
            diagnostics = { globals = {'vim'} },
            workspace = { library = vim.api.nvim_get_runtime_file('', true) },
            telemetry = { enable = false },
          }
        },
        on_attach = lsp_core.on_attach,
        capabilities = lsp_core.capabilities,
      })
    end
  },

  -- 3. 代码格式化 (使用 none-ls 替代 null-ls)
  {
    "nvimtools/none-ls.nvim",  -- 替换原 null-ls 插件
    ft = {"lua"},
    dependencies = { 
      "nvim-lua/plenary.nvim",
      "williamboman/mason.nvim"
    },
    config = function()
      -- 导入通用 none-ls 配置
      local none_ls = require("core.none_ls")
      
      -- 注册 Lua 相关的格式化工具
      none_ls.register({
        none_ls.builtins.formatting.stylua
      })
    end
  },

  -- 4. Snippet 支持
  {
    "L3MON4D3/LuaSnip",
    ft = {"lua"},
    dependencies = { "rafamadriz/friendly-snippets" },
    config = function()
      require('luasnip.loaders.from_vscode').lazy_load()
    end,
  },

  -- 5. 确保安装必要工具
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "lua-language-server",
        "stylua"
      })
    end
  }
}

