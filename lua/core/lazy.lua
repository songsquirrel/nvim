-- lua/core/lazy.lua
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git", "clone", "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git", lazypath,
    })
end

vim.opt.rtp:prepend(lazypath)

-- 确保安装基础插件
local base_plugins = {
  -- 基础 UI 组件库
  { "nvim-lua/plenary.nvim" },
  
  -- 图标支持
  { "nvim-tree/nvim-web-devicons" },
  
  -- 自动补全核心
  { "hrsh7th/nvim-cmp" },
  { "hrsh7th/cmp-nvim-lsp" },
  { "hrsh7th/cmp-buffer" },
  { "hrsh7th/cmp-path" },
  
  -- Snippet 引擎
  { "L3MON4D3/LuaSnip" },
  { "rafamadriz/friendly-snippets" },
  
  -- LSP 基础
  { "neovim/nvim-lspconfig" },
  { "williamboman/mason.nvim" },
  { "williamboman/mason-lspconfig.nvim" },
  
  -- 格式化工具 (使用 none-ls 替代 null-ls)
  { 
    "nvimtools/none-ls.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",  -- none-ls 必需的依赖
    },
  },
  
  -- 语法高亮
  { 
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate"
  },
}

-- 动态获取所有 plugins 和 langs 目录下的配置
local config_path = vim.fn.stdpath('config') .. "/lua"
local spec_modules = {}

-- 先添加基础插件
vim.list_extend(spec_modules, base_plugins)

-- 再添加自定义插件和语言配置
for _, sub in ipairs({ "plugins", "langs"}) do
  local dir = config_path .. "/" .. sub
  if vim.loop.fs_stat(dir) then
    for _, fname in ipairs(vim.fn.readdir(dir)) do
      if fname:match("%.lua$") then
        local mod = sub .. "." .. fname:gsub("%.lua$", "")
        table.insert(spec_modules, { import = mod })
      end
    end
  end
end

-- 配置 lazy.nvim
require("lazy").setup({
  spec = spec_modules,
  defaults = {
    lazy = true,
    version = false,
  },
  install = { 
    colorscheme = { "gruvbox", "onedark" } 
  },
  checker = { 
    enabled = true,  -- 自动检查插件更新
    notify = false   -- 不弹窗提示，仅日志
  },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})

