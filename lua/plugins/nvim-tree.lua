-- 插件配置格式：与直接写在 lazy.setup 中的单个插件配置完全一致
return {
  'nvim-tree/nvim-tree.lua',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  keys = {
    { '<leader>e', '<cmd>NvimTreeToggle<CR>', desc = '切换文件树' },
    { '<leader>f', '<cmd>NvimTreeFindFile<CR>', desc = '定位当前文件' },
  },
  config = function()
    require('nvim-tree').setup({
      filters = {
        -- 过滤掉 Spring Boot 项目中的编译目录
        custom = { '^target$', '^.git$', '^.idea$' },
      },
      view = {
        width = 30, -- 侧边栏宽度
      },
      actions = {
        open_file = {
          quit_on_open = false, -- 打开文件后不自动关闭文件树
        },
      },
    })
  end,
}

