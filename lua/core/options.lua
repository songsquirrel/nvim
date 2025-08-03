-- 基础编辑设置
vim.opt.number = true          -- 显示行号
vim.opt.relativenumber = true  -- 显示相对行号
vim.opt.mouse = 'a'            -- 启用鼠标支持
vim.opt.clipboard = 'unnamedplus'  -- 同步系统剪贴板

-- 缩进设置
vim.opt.tabstop = 2            -- Tab 显示为 2 个空格
vim.opt.shiftwidth = 2         -- 自动缩进为 2 个空格
vim.opt.expandtab = true       -- 将 Tab 转换为空格
vim.opt.smartindent = true     -- 智能缩进

-- 搜索设置
vim.opt.ignorecase = true      -- 搜索忽略大小写
vim.opt.smartcase = true       -- 包含大写字母时区分大小写
vim.opt.hlsearch = false       -- 搜索结果不高亮

-- 界面设置
vim.opt.signcolumn = 'yes'     -- 始终显示符号列（避免窗口跳动）
vim.opt.wrap = false           -- 不自动换行
vim.opt.scrolloff = 8          -- 光标上下保留 8 行
