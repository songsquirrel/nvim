-- 1. 加载基础设置（选项，快捷键，自动命令）
require('core.options')
require('core.keymaps')
require('core.autocmds')

-- ================安装 lazy.nvim 插件管理器===================
local lazypath = vim.fn.stdpath('data') .. 'lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  -- 自动克隆 lazy.nvim 到本地
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable',
    lazypath,
  })
end
-- 将 lazy.nvim 添加到neovim的运行路径
vim.opt.rtp:prepend(lazypath)

-- 自动加载 plugins 目录下所有插件配置
local plugins = require('plugins')

-- 启动 lazy.nvim 并加载所有插件
require('lazy').setup(plugins)

-- ===========加载语言配置--------
local langs_config = require('langs')

-- 配置并加载所有插件
require('lazy').setup({
  -- 基础工具插件
  'nvim-lua/plenary.nvim', -- provide lua tool function
  -- 语法高亮
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    config = function()
      require('nvim-treesitter.configs').setup({
        ensure_installed = langs_config.treesitter_parsers, -- 从语言配置获取解析器
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },

  -- LSP相关插件
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      'williamboman/mason.nvim',           -- lsp installer
      'williamboman/mason-lspconfig.nvim', -- bridge mason and lspconfig
    },
    config = function()
      -- init mason
      require('mason').setup({
        ensure_installed = vim.tbl_keys(langs_config.lsp_servers), -- 安装语言配置中的LSP
      })

      -- 逐个配置LSP服务器
      for server, opts in pairs(langs_config.lsp_servers) do
        require('lspconfig')[server].setup(opts)
      end
    end,
  },

  -- 代码格式化工具
  {
    'stevearc/conform.nvim',
    config = function()
      require('conform').setup({
        formatters_by_ft = langs_config.formatters_by_ft,
        format_on_save = { enabled = true, timeout_ms = 500, lsp_format = 'fallback' },
      })
    end,
  },
  -- 基础调试框架（全局共用）
  {
    'mfussenegger/nvim-dap',
    lazy = true, -- 延迟加载，由具体语言触发
    dependencies = {
      -- 调试 UI（全局共用基础配置）
      {
        'rcarriga/nvim-dap-ui',
        config = function()
          -- 所有语言共用的调试 UI 基础布局
          require('dapui').setup({
            floating = { border = 'rounded' },
            layouts = {
              {
                elements = { 'scopes', 'breakpoints', 'stacks' },
                size = 40,
                position = 'left'
              },
              {
                elements = { 'console', 'repl' },
                size = 10,
                position = 'bottom'
              }
            }
          })

          -- 全局调试事件（所有语言共用）
          local dap = require('dap')
          local dapui = require('dapui')
          dap.listeners.after.event_initialized['dapui_config'] = function() dapui.open() end
          dap.listeners.before.event_terminated['dapui_config'] = function() dapui.close() end
        end
      },
      -- 调试时显示变量值（全局共用）
      'theHamsta/nvim-dap-virtual-text',
    }
  },
  -- java/springboot 调试
  {
    'mfussenegger/nvim-jdtls',
    ft = 'java', -- 触发条件：打开 .java 文件
    dependencies = { 'mfussenegger/nvim-dap' },
    config = function()
      -- 调用 java.lua 中的调试配置
      local java_dap = require('langs.java').dap
      -- 配置调试适配器
      require('dap').adapters.java = java_dap.adapters()
      -- 加载调试配置模板
      require('dap').configurations.java = java_dap.configurations
      -- 初始化 Java 调试 UI 和快捷键
      java_dap.setup_ui()
    end
  },

})
