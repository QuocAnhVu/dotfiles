------------------------------------------------------------
-- Must have options
--
-- These are highly recommended options.

-- Vim with default settings does not allow easy switching between multiple files
-- in the same editor window. Users can use multiple split windows or multiple
-- tab pages to edit multiple files, but it is still best to enable an option to
-- allow easier switching between files.
--
-- One such option is the 'hidden' option, which allows you to re-use the same
-- window and switch from an unsaved buffer without saving it first. Also allows
-- you to keep an undo history for multiple files when re-using the same window
-- in this way. Note that using persistent undo also lets you undo in multiple
-- files even in the same window, but is less efficient and is actually designed
-- for keeping undo history after closing Vim entirely. Vim will complain if you
-- try to quit without saving, and swap files will keep you safe if your computer
-- crashes.
vim.opt.hidden = true

-- Note that not everyone likes working this way (with the hidden option).
-- Alternatives include using tabs or split windows instead of re-using the same
-- window as mentioned above, and/or either of the following options:
-- vim.opt.confirm = true
-- vim.opt.autowriteall = true

-- Better command-line completion
vim.opt.wildmenu = true

-- Show partial commands in the last line of the screen
vim.opt.showcmd = true
-- Highlight searches (use <C-L> to temporarily turn off highlighting; see the
-- mapping of <C-L> below)
vim.opt.hlsearch = true

-- Modelines have historically been a source of security vulnerabilities. As
-- such, it may be a good idea to disable them and use the securemodelines
-- script, <http://www.vim.org/scripts/script.php?script_id=1876>.
-- vim.opt.nomodeline = true

-- UTF-8
vim.opt.encoding = 'utf-8'
vim.opt.fileencoding = 'utf-8'

------------------------------------------------------------
-- Usability options
--
-- These are options that users frequently set in their .vimrc. Some of them
-- change Vim's behaviour in ways which deviate from the true Vi way, but
-- which are considered to add usability. Which, if any, of these options to
-- use is very much a personal preference, but they are harmless.

-- Use case insensitive search, except when using capital letters
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Allow backspacing over autoindent, line breaks and start of insert action
vim.opt.backspace = { 'indent', 'eol', 'start' }

-- When opening a new line and no filetype-specific indenting is enabled, keep
-- the same indent as the line you're currently on. Useful for READMEs, etc.
vim.opt.autoindent = true

-- Display the cursor position on the last line of the screen or in the status
-- line of a window
vim.opt.ruler = true

-- Always display the status line, even if only one window is displayed
vim.opt.laststatus = 2

-- Instead of failing a command because of unsaved changes, instead raise a
-- dialogue asking if you wish to save changed files.
vim.opt.confirm = true

-- Use visual bell instead of beeping when doing something wrong
vim.opt.visualbell = true

-- Enable use of the mouse for all modes
vim.opt.mouse = 'a'

-- Set the command window height to 2 lines, to avoid many cases of having to
-- "press <Enter> to continue"
vim.opt.cmdheight = 2

-- Display line numbers on the left
vim.opt.number = true

-- Quickly time out on keycodes, but never time out on mappings
vim.opt.timeout = false
vim.opt.ttimeout = true
vim.opt.ttimeoutlen = 200

------------------------------------------------------------
-- Indentation options
--
-- Indentation settings according to personal preference.

-- Indentation settings for using 4 spaces instead of tabs.
vim.opt.softtabstop = 4
vim.opt.expandtab = true

-- Indentation settings for using hard tabs for indent. Display tabs as
-- four characters wide.
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4

-- Set indentation when soft-wrapping
-- Indents word-wrapped lines as much as the 'parent' line
vim.opt.breakindent = true
-- Ensures word-wrap does not split words
vim.opt.formatoptions = 'l'
vim.opt.lbr = true
-- ident by an additional 2 characters on wrapped lines, when line >= 40 characters, put 'showbreak' at start of line
vim.opt.breakindentopt = { 'shift:2', 'min:40', 'sbr' }

------------------------------------------------------------
-- Mappings
--
-- Useful mappings

-- Remapping mapleader
vim.g.mapleader = " "
vim.g.localmapleader = "\\"

-- Map Y to act like D and C, i.e. to yank until EOL, rather than act as yy,
-- which is the default
vim.keymap.set('', 'Y', 'y$')

-- Map <C-L> (redraw screen) to also turn off search highlighting until the
-- next search
vim.keymap.set('n', '<C-L>', ':nohl<CR><C-L>')

-- We can use different key mappings for easy navigation between splits to save a keystroke. So instead of ctrl-w then j, it’s just ctrl-j
-- vim.keymap.set('n', '<C-J>', '<C-W><C-J>')
-- vim.keymap.set('n', '<C-K>', '<C-W><C-K>')
-- vim.keymap.set('n', '<C-L>', '<C-W><C-L>')
-- vim.keymap.set('n', '<C-H>', '<C-W><C-H>')

-- Autoclose brackets
-- vim.keymap.set('i', '"', '""<left>')
-- vim.keymap.set('i', ''', '''<left>')
-- vim.keymap.set('i', '(', '()<left>')
-- vim.keymap.set('i', '[', '[]<left>')
-- vim.keymap.set('i', '{', '{}<left>')
vim.keymap.set('i', '{<CR>', '{<CR>}<ESC>O')
vim.keymap.set('i', '{;<CR>', '{<CR>};<ESC>O')

------------------------------------------------------------
-- Fixes
--
-- Environment specific fixes.

-- Set correct python3
vim.g.python3_host_prog = '$HOME/.local/share/asdf/shims/python3'

------------------------------------------------------------
-- Plugins
--
-- Additional third-party functionality

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

-- Initialize plugins
require('lazy').setup({
    {
        'shaunsingh/nord.nvim',
        priority = 1000,
        config = function()
            vim.g.nord_contrast = true
            vim.g.nord_borders = true
            vim.g.nord_disable_background = false
            vim.g.nord_enable_sidebar_background = false
            vim.g.nord_uniform_diff_background = true
            vim.g.nord_italic = true
            vim.g.nord_bold = true
            vim.cmd('colorscheme nord')
        end,
    },
    {
        'nvim-lualine/lualine.nvim',
        dependencies = { 'nvim-tree/nvim-web-devicons', opt = true },
        config = function()
            require('lualine').setup()
        end
    },
    {
        "lukas-reineke/indent-blankline.nvim",
        main = "ibl",
        opts = {},
        config = function()
            require("ibl").setup()
        end
    },
    {
        'lewis6991/gitsigns.nvim',
        config = function()
            require('gitsigns').setup()
        end,
    },
    {
        'numToStr/Comment.nvim',
        opts = {},
        lazy = false,
    },
    {
        'easymotion/vim-easymotion',
        config = function()
            -- Disable default mappings
            vim.g.EasyMotion_do_mapping = 0
            -- Jump to anywhere you want with minimal keystrokes, with just one key binding.
            -- `s{char}{char}{label}`
            vim.keymap.set('', 'ss', '<Plug>(easymotion-overwin-f2)')
            -- Turn on case-insensitive feature
            vim.g.EasyMotion_smartcase = 1
            -- HJKL motions: Line motions
            vim.keymap.set('n', 'sh', '<plug>(easymotion-linebackward)')
            vim.keymap.set('n', 'sj', '<plug>(easymotion-j)')
            vim.keymap.set('n', 'sk', '<plug>(easymotion-k)')
            vim.keymap.set('n', 'sl', '<plug>(easymotion-lineforward)')
        end,
    },
    {
        'stevearc/oil.nvim',
        opts = {},
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("oil").setup()
            vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
        end,
    },
    {
        'nvim-telescope/telescope.nvim',
        tag = '0.1.6',
        dependencies = { 'nvim-lua/plenary.nvim' },
        config = function()
            local builtin = require('telescope.builtin')
            vim.keymap.set('n', 'ff', builtin.find_files, {})
            vim.keymap.set('n', 'fg', builtin.live_grep, {})
            vim.keymap.set('n', 'fb', builtin.buffers, {})
            vim.keymap.set('n', 'fh', builtin.help_tags, {})
        end,
    },
    'sheerun/vim-polyglot',
    {
        'nvim-treesitter/nvim-treesitter',
        build = { ':TSUpdate', ':TSInstall all' },
    },
    {
        'nvim-treesitter/nvim-treesitter-context',
        dependencies = { 'nvim-treesitter/nvim-treesitter' },
        config = function()
            vim.keymap.set("n", "[c", function()
                require("treesitter-context").go_to_context(vim.v.count1)
            end, { silent = true })
        end
    },
    --    {
    --        'nvim-treesitter/nvim-treesitter-textobjects',
    --		dependencies = { 'nvim-treesitter/nvim-treesitter' },
    --    },
    'williamboman/mason.nvim',
    {
        'williamboman/mason-lspconfig.nvim',
        dependencies = { 'williamboman/mason.nvim' },
    },
    {
        'neovim/nvim-lspconfig',
        dependencies = { 'williamboman/mason-lspconfig.nvim' },
        config = function()
            -- Setup language servers.
            require('mason').setup()
            require('mason-lspconfig').setup()
            require('mason-lspconfig').setup_handlers {
                -- The first entry (without a key) will be the default handler
                -- and will be called for each installed server that doesn't have
                -- a dedicated handler.
                function(server_name) -- default handler (optional)
                    require('lspconfig')[server_name].setup {}
                end
            }

            -- Global mappings.
            -- See `:help vim.diagnostic.*` for documentation on any of the below functions
            vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float)
            vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
            vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
            vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist)

            -- Use LspAttach autocommand to only map the following keys
            -- after the language server attaches to the current buffer
            vim.api.nvim_create_autocmd('LspAttach', {
                group = vim.api.nvim_create_augroup('UserLspConfig', {}),
                callback = function(ev)
                    -- Enable completion triggered by <c-x><c-o>
                    vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

                    -- Buffer local mappings.
                    -- See `:help vim.lsp.*` for documentation on any of the below functions
                    local opts = { buffer = ev.buf }
                    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
                    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
                    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
                    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
                    vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
                    vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, opts)
                    vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, opts)
                    vim.keymap.set('n', '<leader>wl', function()
                        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
                    end, opts)
                    vim.keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, opts)
                    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
                    vim.keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, opts)
                    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
                    vim.keymap.set('n', '<leader>f', function()
                        vim.lsp.buf.format { async = true }
                    end, opts)
                end,
            })
        end
    },
    {
        'nvimdev/lspsaga.nvim',
        dependencies = {
            'nvim-treesitter/nvim-treesitter',
            'nvim-tree/nvim-web-devicons',
        },
        config = function()
            require('lspsaga').setup({})
        end,
    },
    --    {
    --        'hrsh7th/nvim-cmp',
    --        config = function()
    --            -- so much things
    --        end
    --    },
}, {})

------------------------------------------------------------
