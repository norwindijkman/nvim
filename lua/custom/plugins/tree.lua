-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- set termguicolors to enable highlight groups
vim.opt.termguicolors = trouble

vim.cmd([[ let g:neo_tree_remove_legacy_commands = 1 ]])
vim.api.nvim_set_keymap('n', '<A-t>', ':Neotree toggle reveal<CR>', {noremap = true, silent = true})

vim.wo.relativenumber = true
vim.o.scrolloff = 999

-- Function to refresh git status using neo-tree
local function refreshGitStatus()
  -- Running the neo-tree git status refresh command
  require('neo-tree.sources.git_status').refresh()

  -- Schedule the next execution of this function after 1 second (1000 ms)
  vim.defer_fn(refreshGitStatus, 500)
end

-- Start the recurring refreshGitStatus function after an initial delay of 4 seconds (4000 ms)
vim.defer_fn(refreshGitStatus, 4000)

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
      default_component_configs = {
	  git_status = {
	     symbols = {
		-- Change type
		added     = "󰙴", 
		deleted   = "󰩹",
		modified  = "󰏫",
		renamed   = "󰏫",
		-- Status type
		untracked = "󰙴",
		ignored   = "",
		unstaged  = "",
		staged    = "",
		conflict  = "",
	     }
	  }
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
