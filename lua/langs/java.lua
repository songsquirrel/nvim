-- lua/langs/java.lua
-- Java (Spring Boot) 开发环境配置：高亮、LSP、补全、格式化、调试等功能
return {
  -- 1. Treesitter 支持 Java 语法高亮与语法功能
  {
    "nvim-treesitter/nvim-treesitter",
    ft = {"java"},
    build = ":TSUpdate",
    opts = {
      ensure_installed = {"java"},
      highlight = { enable = true },
      indent = { enable = true },
    },
  },

  -- 2. Java LSP: nvim-jdtls
  {
    "mfussenegger/nvim-jdtls",
    ft = {"java"},
    dependencies = { "neovim/nvim-lspconfig" },
    config = function()
      local jdtls = require('jdtls')
      local home = os.getenv('HOME')
      local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')
      local workspace_dir = home .. '/.local/share/eclipse/' .. project_name
      
      local config = {
        cmd = { 'jdtls' },
        root_dir = require('jdtls.setup').find_root({ 'mvnw', 'gradlew', '.git' }),
        settings = {
          java = {
            configuration = {
              runtimes = {{ name = 'JavaSE-17', path = '/usr/lib/jvm/java-17-openjdk' }}
            }
          }
        },
        init_options = { bundles = {} },
      }
      jdtls.start_or_attach(config)
    end,
  },

  -- 3. 通用 LSP 配置 (mason + lspconfig)
  {
    "neovim/nvim-lspconfig",
    ft = {"java"},
    dependencies = { "williamboman/mason.nvim", "williamboman/mason-lspconfig.nvim" },
    config = function()
      require('mason').setup()
      require('mason-lspconfig').setup({ ensure_installed = { 'jdtls' } })
      local lspconfig = require('lspconfig')
      lspconfig.jdtls.setup({
        capabilities = require('cmp_nvim_lsp').default_capabilities(),
      })
    end,
  },

  -- 4. 自动补全 (cmp)
  {
    "hrsh7th/nvim-cmp",
    ft = {"java"},
    dependencies = { "hrsh7th/cmp-nvim-lsp", "hrsh7th/cmp-buffer" },
    config = function()
      local cmp = require('cmp')
      cmp.setup.buffer({
        snippet = { expand = function(args) require('luasnip').lsp_expand(args.body) end },
        mapping = cmp.mapping.preset.insert({ ['<C-Space>'] = cmp.mapping.complete(), ['<CR>'] = cmp.mapping.confirm({ select = true }) }),
        sources = cmp.config.sources({ { name = 'nvim_lsp' }, { name = 'buffer' } }),
      })
    end,
  },

  -- 5. 格式化 (google-java-format)
  {
    "jose-elias-alvarez/null-ls.nvim",
    ft = {"java"},
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local null_ls = require('null-ls')
      null_ls.setup({
        sources = { null_ls.builtins.formatting.google_java_format },
      })
    end,
  },

  -- 6. 调试支持 (DAP)
  {
    "mfussenegger/nvim-jdtls", -- jdtls 本身支持 DAP
    ft = {"java"},
    config = function()
      -- jdtls 启动后自动配置 DAP
      -- 确保安装 vscode-java-debug 并在 init_options.bundles 中加入 debug 插件路径
    end,
  },
}

