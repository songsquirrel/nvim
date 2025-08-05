-- 安装 telescope 插件及依赖
return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "BurntSushi/ripgrep",  -- 提供高效的正则搜索支持
    },
    cmd = "Telescope",
    keys = {
      -- 基础文件搜索（非正则）
      { "<leader>ff", "<cmd>Telescope find_files<CR>", desc = "查找文件" },
      -- 正则表达式搜索文件（核心功能）
      { "<leader>ffr", "<cmd>lua require('plugins.telescope').regex_files()<CR>", desc = "正则搜索文件" },
      -- 搜索当前项目所有文件内容（支持正则）
      { "<leader>fr", "<cmd>Telescope live_grep<CR>", desc = "正则搜索内容" },
    },
    config = function()
      local telescope = require("telescope")
      local actions = require("telescope.actions")
      
      telescope.setup({
        defaults = {
          prompt_prefix = "🔍 ",
          selection_caret = "➤ ",
          mappings = {
            i = {
              ["<ESC>"] = actions.close,  -- 按 ESC 退出搜索
              ["<CR>"] = actions.select_default,  -- 按回车打开文件
              ["<C-x>"] = actions.select_horizontal,  -- 水平分屏打开
              ["<C-v>"] = actions.select_vertical,    -- 垂直分屏打开
            },
          },
          vimgrep_arguments = {
            "rg",
            "--color=never",
            "--no-heading",
            "--with-filename",
            "--line-number",
            "--column",
            "--smart-case",
            "--hidden",  -- 搜索隐藏文件
            "--glob=!.git/",  -- 排除 .git 目录
          },
        },
        pickers = {
          find_files = {
            hidden = true,
            -- 排除不需要搜索的目录
            file_ignore_patterns = { "node_modules/", "target/", ".git/" },
          },
          live_grep = {
            -- 支持正则搜索内容
            additional_args = function(opts)
              return { "--hidden" }
            end,
          },
        },
      })
    end,
    -- 自定义正则文件搜索函数
    regex_files = function()
      local telescope = require("telescope.builtin")
      local dir = vim.fn.input("请输入要搜索的目录 (默认当前目录): ")
      
      -- 如果用户未输入目录，使用当前目录
      if dir == "" then
        dir = "."
      end
      
      -- 验证目录是否存在
      if vim.fn.isdirectory(dir) == 0 then
        print("目录不存在: " .. dir)
        return
      end
      
      local pattern = vim.fn.input("请输入正则表达式: ")
      if pattern == "" then
        print("正则表达式不能为空")
        return
      end
      
      -- 使用 find_files 结合正则过滤
      telescope.find_files({
        cwd = dir,
        file_pattern = pattern,  -- 正则匹配文件名
        hidden = true,
        file_ignore_patterns = { "node_modules/", "target/", ".git/" },
      })
    end
  }
}
