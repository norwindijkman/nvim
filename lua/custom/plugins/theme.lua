-- Load vs code theme

return {
  "Mofiqul/vscode.nvim",
  lazy = false,
  priority = 100,
  opts = {},
  config = function()
    require('vscode').load()
  end
}
