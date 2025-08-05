-- Java (Spring Boot) 开发环境配置
return {
  -- 1. Treesitter 语法支持
  {
    "nvim-treesitter/nvim-treesitter",
    ft = {"java", "xml", "properties", "yaml"},
    opts = {
      ensure_installed = {"java", "xml", "properties", "yaml"},
      highlight = { enable = true },
      indent = { enable = true },
    },
  },

  -- 2. LSP 配置 (jdtls)
  {
    "mfussenegger/nvim-jdtls",
    ft = {"java"},
    dependencies = {
      "neovim/nvim-lspconfig",
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/nvim-cmp",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      local jdtls = require('jdtls')
      local lsp_core = require('core.lsp')
      local home = os.getenv('HOME')
      local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')
      local workspace_dir = home .. '/.local/share/eclipse/' .. project_name
      
      -- 导入通用 CMP 配置
      require('core.cmp')
      
      local config = {
        cmd = { 
          'jdtls',
          '-data', workspace_dir
        },
        root_dir = require('jdtls.setup').find_root({ 
          'pom.xml', 'build.gradle', 'mvnw', 'gradlew', '.git' 
        }),
        settings = {
          java = {
            configuration = {
              runtimes = {
                { 
                  name = 'JavaSE-21',
                  path = '/usr/lib/jvm/java-21-openjdk/' 
                }
              }
            },
            spring = {
              boot = {
                support = { enabled = true }
              }
            },
            completion = {
              favoriteStaticMembers = {
                'org.junit.Assert.*',
                'org.junit.jupiter.api.Assertions.*',
                'org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*',
                'org.springframework.test.web.servlet.result.MockMvcResultMatchers.*'
              }
            }
          }
        },
        capabilities = lsp_core.capabilities,
        on_attach = function(client, bufnr)
          -- 调用通用 on_attach
          lsp_core.on_attach(client, bufnr)
          
          local opts = { buffer = bufnr, desc = 'Spring Boot LSP 快捷键' }
          
          -- Java 专属 LSP 功能
          vim.keymap.set('n', '<leader>jc', "<Cmd>lua require('jdtls').compile('full')<CR>", opts)
          vim.keymap.set('n', '<leader>jo', "<Cmd>lua require('jdtls').organize_imports()<CR>", opts)
          vim.keymap.set('n', '<leader>je', "<Cmd>lua require('jdtls').extract_variable()<CR>", opts)
          vim.keymap.set('v', '<leader>jm', "<Esc><Cmd>lua require('jdtls').extract_method(true)<CR>", opts)
          
          -- 测试相关
          vim.keymap.set('n', '<leader>jt', "<Cmd>lua require('jdtls').test_class()<CR>", opts)
          vim.keymap.set('n', '<leader>jm', "<Cmd>lua require('jdtls').test_nearest_method()<CR>", opts)
          
          -- 构建工具快捷命令
          vim.keymap.set('n', '<leader>mcc', '<Cmd>term mvn clean compile<CR>', opts)
          vim.keymap.set('n', '<leader>mcp', '<Cmd>term mvn clean package<CR>', opts)
          vim.keymap.set('n', '<leader>mrs', '<Cmd>term mvn spring-boot:run<CR>', opts)
          vim.keymap.set('n', '<leader>gr', '<Cmd>term gradle run<CR>', opts)
        end,
        init_options = { bundles = {} }
      }
      
      jdtls.start_or_attach(config)
    end
  },

  -- 3. 格式化配置 (使用 none-ls 替代 null-ls)
  {
    "nvimtools/none-ls.nvim",  -- 替换原 null-ls 插件
    ft = {"java", "xml"},
    dependencies = { 
      "nvim-lua/plenary.nvim",
      "williamboman/mason.nvim"
    },
    config = function()
      -- 导入通用 none-ls 配置
      local none_ls = require("core.none_ls")
      
      -- 注册 Java 相关的格式化工具
      none_ls.register({
        none_ls.builtins.formatting.google_java_format,
        none_ls.builtins.formatting.xmlformat
      })
    end
  },

  -- 4. 调试配置
  {
    "mfussenegger/nvim-dap",
    ft = {"java"},
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "williamboman/mason.nvim",
      "nvim-neotest/nvim-nio",
    },
    config = function()
      local dap = require('dap')
      local dapui = require('dapui')
      
      -- 配置调试 UI
      dapui.setup({
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
      
      -- 调试事件监听
      dap.listeners.after.event_initialized['dapui_config'] = function() dapui.open() end
      dap.listeners.before.event_terminated['dapui_config'] = function() dapui.close() end
      dap.listeners.before.event_exited['dapui_config'] = function() dapui.close() end
      
      -- 配置 Java 调试适配器
      local debug_adapter_path = vim.fn.glob(
        vim.fn.stdpath('data') ..
        '/mason/packages/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar'
      )
      
      dap.adapters.java = {
        type = 'server',
        host = 'localhost',
        port = '${port}',
        cmd = {
          'java',
          '-jar',
          debug_adapter_path,
          '--server=native',
          '--port=${port}'
        }
      }
      
      -- 调试配置模板
      dap.configurations.java = {
        {
          type = 'java',
          name = 'Launch Spring Boot (Current File)',
          request = 'launch',
          mainClass = '${file}',
          projectName = '${workspaceFolderBasename}',
          cwd = '${workspaceFolder}',
          args = '--spring.profiles.active=dev',
          vmArgs = '-Xms512m -Xmx1024m'
        },
        {
          type = 'java',
          name = 'Launch Spring Boot (Specify Class)',
          request = 'launch',
          mainClass = function()
            return vim.fn.input('Main Class: ')
          end,
          projectName = '${workspaceFolderBasename}',
          cwd = '${workspaceFolder}',
          args = '--spring.profiles.active=dev'
        },
        {
          type = 'java',
          name = 'Attach to Remote JVM',
          request = 'attach',
          hostName = 'localhost',
          port = '5005'
        }
      }
      
      -- Java 调试快捷键
      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'java',
        callback = function()
          local opts = { buffer = true, desc = 'Java 调试快捷键' }
          vim.keymap.set('n', '<F5>', dap.continue, opts)
          vim.keymap.set('n', '<F9>', dap.toggle_breakpoint, opts)
          vim.keymap.set('n', '<F10>', dap.step_over, opts)
          vim.keymap.set('n', '<F11>', dap.step_into, opts)
          vim.keymap.set('n', '<F12>', dap.step_out, opts)
          vim.keymap.set('n', '<leader>du', dapui.toggle, opts)
        end
      })
    end
  },

  -- 5. 安装调试所需包
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "jdtls",
        "java-debug-adapter",
        "google-java-format",
        "xmlformatter"
      })
    end
  }
}

