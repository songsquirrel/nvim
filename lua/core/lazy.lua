-- lua/core/lazy.lua
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
-- 如果本地还没安装 lazy.nvim，就从 GitHub 克隆
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git", "clone", "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git", lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)  -- 把插件管理器加入运行时路径

-- 动态获取所有plugins langs 目录下lua文件
local config_path = vim.fn.stdpath('config') .. "/lua"
local spec_modules = {}

for _, sub in ipairs({ "plugins", "langs"}) do
  local dir = config_path .. "/" .. sub
  if vim.loop.fs_stat(dir) then
    for _, fname in ipairs(vim.fn.readdir(dir)) do
      if fname:match("%.lua$") then
        -- 去除后缀并替换为 module 名称
        local mod = sub .. "." .. fname:gsub("%.lua$", "")
        table.insert(spec_modules, { import = mod })
      end
    end
  end
end
-- 调用 lazy.nvim.setup 来声明所有插件
require("lazy").setup({
  spec = spec_modules,
  defaults = {
    lazy = true,
    version= false,
  },
  install = { colorscheme = { "gruvbox", "onedark" } },
  checker = 
  { enabled = true,  -- 自动检查插件更新 
  notify = false -- 不弹窗提示，仅日志
},
})

