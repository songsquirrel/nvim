-- 通用 LSP 配置
local M = {}

-- 通用 on_attach 函数
M.on_attach = function(client, bufnr)
  local opts = { buffer = bufnr, silent = true }

  -- 基础 LSP 功能快捷键
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
  vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
  vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
  
  -- 格式化
  if client.supports_method('textDocument/formatting') then
    vim.keymap.set('n', '<leader>f', function()
      vim.lsp.buf.format({ async = true })
    end, opts)
  end
end

-- 通用 capabilities 配置
M.capabilities = require('cmp_nvim_lsp').default_capabilities()

return M
