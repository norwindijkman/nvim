-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- set termguicolors to enable highlight groups
vim.opt.termguicolors = trouble

vim.cmd([[ let g:neo_tree_remove_legacy_commands = 1 ]])
vim.api.nvim_set_keymap('n', '<A-t>', ':Neotree toggle reveal<CR>', {noremap = true, silent = true})

vim.wo.relativenumber = true
vim.o.scrolloff = 999

return {
  "nvim-neo-tree/neo-tree.nvim",
  version = "*",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
    "MunifTanjim/nui.nvim",
  },
  config = function ()
    require('neo-tree').setup({
      auto_clean_after_session_restore = true,
      event_handlers = {
        {
          event = "after_render",
          handler = function()
            vim.cmd('setlocal relativenumber')
          end,
        },
--        {
--          event = "neo_tree_buffer_enter",
--         handler = function()
--            vim.cmd('lcd %:p:h')
--          end,
--        },
        {
          event = "neo_tree_window_after_open",
          handler = function()
            vim.cmd('setlocal relativenumber')
          end,
        },
        {
          event = "neo_tree_buffer_enter",
          handler = function()
            vim.cmd('setlocal relativenumber')
          end,
        },
      },
      filesystem = {
        window = {
          mappings = {
            ["/"] = "",
          }
        }
      }
    })
  end,
}
