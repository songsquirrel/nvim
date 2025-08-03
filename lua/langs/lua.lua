-- lua develop config
local M = {}
-- config lua language server
M.lsp = {
  -- key必须与LSP 服务器名称一致，lua_ls 为官方 LSP
  lua_ls = {
    settings = {
      Lua = {
        runtime = { version = 'LuaJIT' },
        diagnostics = { globals = { 'vim' } },              --识别neovim全局变量
        workspace = {
          checkThirdParty = false,                          -- 关闭第三方库检查，减少干扰
          libary = vim.api.nvim_get_runtime_file('', true), -- 包含 Neovim API
        },
        telemetry = { enable = false },                     -- 禁用遥测
      },
    },
    -- lsp 附加到缓冲区时的回调
    on_attach = function(client, bufnr)
      -- 仅在当前 Lua 缓冲区生效的快捷键
      local opts = { buffer = bufnr, desc = 'Lua LSP' }
      vim.keymap.set('n', '<leader>ld', '<cmd>lua vim.diagnostics.open_float()<CR>', opts) --显示诊断详情
    end,
  },
}
-- 3. 格式化配置（直接使用conform最新语法）
-- 格式说明：
-- - items: 格式化工具列表（按执行顺序排列）
-- - stop_after_first: 若为true，遇到第一个可用工具就停止（可选）
M.formatters = {
  items = {
    {
      name = 'stylua', -- 格式化工具名称
      opts = {         -- 工具参数（可选）
        args = { '--config-path', vim.fn.expand('~/.config/nvim/.stylua.toml') }
      }
    }
    -- 如需添加更多工具，按顺序放在这里（如{ name = '另一个工具' }）
  },
  stop_after_first = true -- 启用"第一个可用工具即停止"
}

return M
