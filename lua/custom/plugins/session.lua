vim.o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"
vim.o.title = true

local Path = require 'plenary.path'
local session_dir = vim.fn.expand("~/.config/nvim/sessions/")

vim.api.nvim_create_user_command('OpenTerminal', function()
    local current_file = vim.api.nvim_buf_get_name(0)
    local current_dir = vim.fn.fnamemodify(current_file, ':p:h')
    local terminal_command = "gnome-terminal --working-directory=" .. current_dir
    vim.api.nvim_command('!' .. terminal_command)
end, {})
vim.api.nvim_set_keymap('n', '<C-A-T>', ':OpenTerminal<CR>', { noremap = true, silent = true })


-- Ensure session directory exists
Path:new(session_dir):mkdir({
    parents = true
})

function ChangeParentShellDir(dir)
    local temp_file = "/tmp/neovim_cd.txt"
    local file = io.open(temp_file, "w")
    if file then
        file:write(dir)
        file:close()
    end
end
vim.api.nvim_create_user_command('ChangeDir', function(input)
    ChangeParentShellDir(input.args)
end, {
    nargs = 1
})

local function open_tree()
    vim.cmd('Neotree reveal')
end

-- Function to save the current session
local function save_session()
    local sanitized_cwd = string.gsub(vim.fn.getcwd(), '/', '%%2F')
    local session_file = session_dir .. sanitized_cwd .. '.vim'
    vim.cmd('Neotree close')
    vim.cmd("mksession! " .. vim.fn.fnameescape(session_file))
    print("Saved current session")
end

-- Function to list and load sessions using Telescope
local function open_telescope()
    local function entry_maker(entry)
        local filename = entry:match("([^/]+)$")
        str = string.gsub(filename, "%%2F", "/")
        str = string.gsub(str, "^/home/penguin/", "~/")
        local filebasename = string.sub(str, 1, -5)
        return {
            value = filename,
            display = filebasename,
            ordinal = filebasename,
        }
    end

    -- Function to handle Enter key
    local function handle_enter(bufnr)
        local selection = require'telescope.actions.state'.get_selected_entry(bufnr)
        require'telescope.actions'.close(bufnr)
        local session_file = vim.fn.fnameescape("~/.config/nvim/sessions/" .. selection.value)
        vim.cmd('SaveSession')
        vim.cmd("%bd!")
        vim.cmd("source " .. session_file)
        vim.cmd("Neotree " .. selection.display)
        vim.o.titlestring = "NeoVim " .. selection.display
        print("nav to " .. vim.fn.expand('%:p'))
    end

    -- Function to handle Delete key
    local function handle_delete(bufnr)
        local selection = require'telescope.actions.state'.get_selected_entry(bufnr)
        require'telescope.actions'.close(bufnr)
        local session_file_path = "~/.config/nvim/sessions/" .. selection.value
        local full_path = vim.fn.expand(session_file_path)
        vim.fn.delete(full_path)
        print("Deleted session: " .. full_path)
    end

    require'telescope.builtin'.find_files({
        prompt_title = "Load Session",
        cwd = session_dir,
        entry_maker = entry_maker,
        previewer = false,
        initial_mode = 'normal',
        find_command = { 'find', session_dir, '-type', 'f', '-exec', 'ls', '-1a', '{}', '+' },
        sorting_strategy = "ascending",
        attach_mappings = function(_, map)
            -- Map Enter key in both Insert and Normal mode
            map('i', '<CR>', handle_enter)
            map('n', '<CR>', handle_enter)

            -- Map Delete key in both Insert and Normal mode
            map('i', '<Del>', handle_delete)
            map('n', '<Del>', handle_delete)

            return true
        end
    })
end

-- Create Vim commands
vim.api.nvim_create_user_command('SaveSession', save_session, {})
vim.api.nvim_create_user_command('LoadSession', open_telescope, {})
vim.keymap.set("n", "<C-A-s>", open_telescope, {
    noremap = true,
    silent = true
})

vim.api.nvim_create_autocmd("VimLeavePre", {
    pattern = "*",
    callback = function()
        vim.cmd('Neotree close')
        vim.cmd("mksession! ~/.config/nvim/session.vim")
    end
})

if #vim.fn.argv() == 0 then
    local session_file = vim.fn.expand("~/.config/nvim/session.vim")
    if vim.fn.filereadable(session_file) == 1 then
        vim.cmd("source " .. session_file)
        vim.o.titlestring = "NeoVim " .. string.gsub(vim.fn.getcwd(), "^/home/penguin/", "~/")
        vim.schedule(open_tree)
    end
end

return {}
