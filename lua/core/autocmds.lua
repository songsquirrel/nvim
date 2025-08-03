-- 创建自动命令组（避免重复定义）
local augroup = vim.api.nvim_create_augroup('user_cmds', { clear = true })

-- 保存文件时自动创建父目录（如果不存在）
vim.api.nvim_create_autocmd('BufWritePre', {
  group = augroup,
  pattern = '*',
  callback = function(event)
    local file = vim.loop.fs_realpath(event.match) or event.match
    local dir = vim.fn.fnamemodify(file, ':p:h')
    -- 检查目录是否存在，不存在则创建
    if not vim.loop.fs_stat(dir) then
      vim.fn.mkdir(dir, 'p')  -- 'p' 表示递归创建
    end
  end,
  desc = '自动创建文件的父目录',
})

-- 复制文本时高亮显示
vim.api.nvim_create_autocmd('TextYankPost', {
  group = augroup,
  pattern = '*',
  callback = function()
    vim.hl.on_yank({ timeout = 200 })  -- 高亮 200ms
  end,
  desc = '复制时高亮文本',
})
