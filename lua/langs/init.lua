-- 初始化聚合配置表
local M = {
  treesitter_parsers = {}, -- 所有语言需要的 treesitter 解析器
  lsp_servers = {},        -- 所有语言的 LSP 服务器配置
  formatters_by_ft = {},   -- 按文件类型分类的格式化工具配置
}

-- 需要加载的语言列表（新增语言时在此添加）
local enabled_langs = {
  'lua',  -- 加载 lua.lua 配置
  'java', -- 按需启用其他语言
  -- 'go',
}

-- 遍历并合并所有语言配置
for _, lang in ipairs(enabled_langs) do
  -- 加载对应语言的配置文件（如 require('langs.lua')）
  local lang_config = require('langs.' .. lang)

  -- 合并 treesitter 解析器配置
  if lang_config.treesitter and lang_config.treesitter.ensure_installed then
    -- 支持 table 及 单个配置
    local parsers = lang_config.treesitter.ensure_installed
    if type(parsers) == 'table' then
      for _, parser in pairs(parsers) do
        table.insert(M.treesitter_parsers, parser)
      end
    else
      table.insert(M.treesitter_parsers, parsers)
    end
  end

  -- 合并 LSP 服务器配置（键为 LSP 服务器名称，值为配置）
  if lang_config.lsp then
    for server_name, server_opts in pairs(lang_config.lsp) do
      M.lsp_servers[server_name] = server_opts
    end
  end

  -- 合并格式化工具配置（按文件类型映射）
  if lang_config.formatters then
    M.formatters_by_ft[lang] = lang_config.formatters
  end
end

return M -- 导出聚合后的配置
