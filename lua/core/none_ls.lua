local none_ls = require("null-ls")

-- 确保只初始化一次
if none_ls.is_registered() then
  return
end

-- 通用 none-ls 配置
none_ls.setup({
  border = "rounded",
  debug = false,
  log_level = "warn",
  update_in_insert = false,
  
  -- 默认格式化快捷键
  on_attach = function(client, bufnr)
    if client.supports_method("textDocument/formatting") then
      vim.keymap.set("n", "<leader>f", function()
        vim.lsp.buf.format({
          bufnr = bufnr,
          filter = function(c)
            return c.name == "none-ls"
          end
        })
      end, { buffer = bufnr, desc = "使用 none-ls 格式化文档" })
    end
  end
})

return none_ls

