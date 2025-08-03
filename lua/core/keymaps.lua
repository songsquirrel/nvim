--  leader 键设置为空格
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.keymap.set('i', 'bb', '<Esc>', { desc = '快速退出插入模式' })
-- 快速保存
vim.keymap.set('n', '<leader>w', '<cmd>w<CR>', { desc = '保存当前文件' })

-- 快速退出
vim.keymap.set('n', '<leader>q', '<cmd>q<CR>', { desc = '退出当前窗口' })

-- 窗口切换（Ctrl + hjkl）
vim.keymap.set('n', '<C-h>', '<C-w>h', { desc = '切换到左窗口' })
vim.keymap.set('n', '<C-j>', '<C-w>j', { desc = '切换到下窗口' })
vim.keymap.set('n', '<C-k>', '<C-w>k', { desc = '切换到上窗口' })
vim.keymap.set('n', '<C-l>', '<C-w>l', { desc = '切换到右窗口' })

-- 取消搜索高亮
vim.keymap.set('n', '<ESC>', '<cmd>nohlsearch<CR>', { desc = '取消搜索高亮' })
