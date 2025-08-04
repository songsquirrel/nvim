-- lua/plugins/nvim-tree.lua
return {
  "nvim-tree/nvim-tree.lua",
  dependencies = { "nvim-tree/nvim-web-devicons" },  -- 依赖图标插件
  cmd = "NvimTreeToggle",  -- 懒加载：只有执行命令时才加载
  keys = {
    { "<leader>e", "<cmd>NvimTreeToggle<CR>", desc = "切换文件树" }  -- 快捷键
  },
  opts = {
    -- 基本配置
    auto_reload_on_write = true,
    disable_netrw = false,
    hijack_cursor = false,
    hijack_netrw = true,
    hijack_unnamed_buffer_when_opening = false,
    sort_by = "name",
    
    -- 窗口配置
    view = {
      adaptive_size = true,
      width = 30,
      side = "left",
      signcolumn = "yes",
    },
    
    -- 渲染配置（图标和缩进）
    renderer = {
      indent_markers = {
        enable = true,  -- 显示缩进线
        inline_arrows = true,
      },
      icons = {
        webdev_colors = true,
        git_placement = "before",
      },
    },
    
    -- 项目根目录检测
    sync_root_with_cwd = true,
    respect_buf_cwd = true,
    
    -- 自动定位当前文件
    update_focused_file = {
      enable = true,
      update_root = true,
    },
    
    -- 过滤隐藏文件
    filters = {
      custom = { "node_modules", ".git" },  -- 隐藏不需要的目录
    },
  }
}

