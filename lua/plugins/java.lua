local M = {}

-- 1. treesitter 语法高亮配置
-- 支持Java、XML（配置文件）、Properties（配置文件）
M.treesitter = {
  ensure_installed = { 'java', 'xml', 'properties', 'yaml' },
}

-- 2. LSP 服务器配置（jdtls - Java语言服务器）
M.lsp = {
  jdtls = {
    -- JDT-LS 启动命令（自动由mason安装）
    cmd = { 'jdtls' },

    -- 仅在Spring Boot项目根目录（有pom.xml或build.gradle）启动
    root_dir = function(fname)
      return require('lspconfig.util').root_pattern(
        '.git',
        'pom.xml',
        'build.gradle',
        'mvnw',
        'gradlew'
      )(fname)
    end,

    -- JDT-LS 配置
    settings = {
      java = {
        configuration = {
          -- 配置JDK路径（根据实际环境修改）
          runtimes = {
            {
              name = 'JavaSE-21',
              path = '/usr/lib/jvm/java-21-openjdk/', -- Linux示例
              -- path = 'C:/Program Files/Java/jdk-17/',  -- Windows示例
            }
          }
        },
        -- 启用Spring Boot支持
        spring = {
          boot = {
            support = {
              enabled = true
            }
          }
        },
        -- 代码补全提示优先级
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

    -- LSP附加到缓冲区时的回调（配置Java专属快捷键）
    on_attach = function(client, bufnr)
      local opts = { buffer = bufnr, desc = 'Spring Boot LSP快捷键' }

      -- === 基础 LSP 功能 ===
      vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)                -- 查看文档（类/方法说明）
      vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)          -- 跳转到定义（如接口实现、变量声明）
      vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)         -- 跳转到声明（如类定义处）
      vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)      -- 跳转到实现（如接口的所有实现类）
      vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)          -- 查看引用（谁调用了这个方法）
      vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)      -- 重命名（变量/方法/类，自动更新引用）
      vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts) -- 代码动作（自动修复、导入缺失类等）
      vim.keymap.set('n', '<leader>f', vim.lsp.buf.format, opts)       -- 格式化当前文件

      -- === Spring Boot 专属功能 ===
      vim.keymap.set('n', '<leader>jc', "<Cmd>lua require('jdtls').compile('full')<CR>", opts)           -- 全量编译项目
      vim.keymap.set('n', '<leader>jo', "<Cmd>lua require('jdtls').organize_imports()<CR>", opts)        -- 整理导入（自动删除无用import）
      vim.keymap.set('n', '<leader>je', "<Cmd>lua require('jdtls').extract_variable()<CR>", opts)        -- 提取变量（重构）
      vim.keymap.set('v', '<leader>jm', "<Esc><Cmd>lua require('jdtls').extract_method(true)<CR>", opts) -- 提取方法（可视模式选代码块）

      -- === 测试相关 ===
      vim.keymap.set('n', '<leader>jt', "<Cmd>lua require('jdtls').test_class()<CR>", opts)          -- 运行当前类的单元测试
      vim.keymap.set('n', '<leader>jm', "<Cmd>lua require('jdtls').test_nearest_method()<CR>", opts) -- 运行光标所在方法的测试

      -- === 构建工具快捷命令 ===
      vim.keymap.set('n', '<leader>mcc', '<Cmd>term mvn clean compile<CR>', opts)   -- Maven：清理并编译
      vim.keymap.set('n', '<leader>mcp', '<Cmd>term mvn clean package<CR>', opts)   -- Maven：打包（跳过测试）
      vim.keymap.set('n', '<leader>mrs', '<Cmd>term mvn spring-boot:run<CR>', opts) -- Maven：启动Spring Boot应用
      vim.keymap.set('n', '<leader>gr', '<Cmd>term gradle run<CR>', opts)           -- Gradle：启动应用
    end
  }
}

-- 3. 格式化配置（使用conform最新语法）
M.formatters = {
  items = {
    -- 格式化Java代码（google-java-format）
    { name = 'google_java_format' },
    -- 格式化XML配置文件
    { name = 'xmlformat' }
  }
  -- 不需要stop_after_first，按顺序执行所有格式化工具
}

-- 4. 调试配置（Java调试需要的额外设置）
-- 在 springboot.lua 中添加调试相关配置
M.dap = {
  -- 1. 调试适配器配置（依赖 java-debug-adapter）
  adapters = function()
    -- 查找 java-debug-adapter 的安装路径, vim.fn.stdpath('data'): 可根据不同环境获取data路径
    local debug_adapter_path = vim.fn.glob(
      vim.fn.stdpath('data') ..
      '/mason/packages/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar'
    )
    return {
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
  end,

  -- 2. 调试配置模板（可在启动调试时选择）
  configurations = {
    {
      type = 'java',
      name = 'Launch Spring Boot (Current File)',
      request = 'launch',
      mainClass = '${file}',                      -- 从当前打开的文件中获取主类（含 main 方法）
      projectName = '${workspaceFolderBasename}', -- 项目名称（自动获取）
      cwd = '${workspaceFolder}',                 -- 工作目录为项目根目录
      args = '--spring.profiles.active=dev',      -- 启动参数（指定开发环境）
      vmArgs = '-Xms512m -Xmx1024m'               -- JVM 参数（调整内存）
    },
    {
      type = 'java',
      name = 'Launch Spring Boot (Specify Class)',
      request = 'launch',
      mainClass = function()
        -- 手动输入主类全路径（如 com.example.DemoApplication）
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
      port = '5005' -- 远程调试端口（需在应用启动参数中添加 -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=5005）
    }
  },
  -- 新增：调试 UI 配置（仅在 Java 文件加载）
  setup_ui = function()
    -- 依赖检查：确保插件已安装
    local ok, dapui = pcall(require, 'dapui')
    if not ok then return end

    -- 配置调试 UI 布局
    dapui.setup({
      floating = { border = 'rounded' }, -- 圆角边框
      layouts = {
        {
          elements = { 'scopes', 'breakpoints', 'stacks' }, -- 左侧面板：变量、断点、调用栈
          size = 40,
          position = 'left'
        },
        {
          elements = { 'console', 'repl' }, -- 底部面板：控制台、交互终端
          size = 10,
          position = 'bottom'
        }
      }
    })

    -- 调试事件监听：自动显示/隐藏 UI
    local dap = require('dap')
    dap.listeners.after.event_initialized['dapui_config'] = function() dapui.open() end
    dap.listeners.before.event_terminated['dapui_config'] = function() dapui.close() end
    dap.listeners.before.event_exited['dapui_config'] = function() dapui.close() end

    -- Java 调试专属快捷键（仅在 Java 文件生效）
    vim.api.nvim_create_autocmd('FileType', {
      pattern = 'java',
      callback = function()
        local opts = { buffer = true, desc = 'Java 调试快捷键' }
        vim.keymap.set('n', '<F5>', dap.continue, opts)
        vim.keymap.set('n', '<F9>', dap.toggle_breakpoint, opts)
        vim.keymap.set('n', '<F10>', dap.step_over, opts)
        vim.keymap.set('n', '<F11>', dap.step_into, opts)
        vim.keymap.set('n', '<F12>', dap.step_out, opts)
        vim.keymap.set('n', '<leader>du', dapui.toggle, opts) -- 手动切换调试 UI 显示
      end
    })
  end
}

return M
