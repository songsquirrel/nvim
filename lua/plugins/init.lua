local M = {}

-- 自动加载 plugins 目录下所有非 init.lua 的 .lua 文件
function M.load()
  -- 获取 plugins 目录的路径
  local plugin_dir = vim.fn.stdpath('config') .. '/lua/plugins'

  -- 扫描目录下所有 .lua 文件（不包括 init.lua 自身）
  local files = vim.fn.globpath(plugin_dir, '*.lua', false, true)

  for _, file in ipairs(files) do
    -- 跳过 init.lua 自身
    if not file:match('init.lua$') then
      -- 提取文件名（如 "nvim-tree.lua" → "nvim-tree"）
      local plugin_name = file:match('([^/]+)%.lua$')

      -- 加载插件配置（如 require('plugins.nvim-tree')）
      local ok, config = pcall(require, 'plugins.' .. plugin_name)
      if ok and type(config) == 'table' then
        -- 如果配置是一个表，将其作为插件配置返回
        table.insert(M, config)
      elseif not ok then
        -- 打印加载错误信息
        vim.notify('Failed to load plugin config: ' .. plugin_name .. '\n' .. config, vim.log.levels.ERROR)
      end
    end
  end
end

-- 执行加载
M.load()

return M
