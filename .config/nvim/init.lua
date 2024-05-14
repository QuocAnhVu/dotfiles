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

-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.opt.clipboard = 'unnamedplus'
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

-- Instead of failing a command because of unsaved changes, instead raise a
-- dialogue asking if you wish to save changed files.
vim.opt.confirm = true

-- Use visual bell instead of beeping when doing something wrong
vim.opt.visualbell = true

-- Enable use of the mouse for all modes
vim.opt.mouse = 'a'

-- Always display the status line, even if only one window is displayed
vim.opt.laststatus = 2

-- Set the command window height to 2 lines, to avoid many cases of having to
-- "press <Enter> to continue"
vim.opt.cmdheight = 2

-- Display relative line numbers on focus, absolute in background
vim.opt.number = true
vim.api.nvim_create_augroup('NumberToggle', { clear = true })
vim.api.nvim_create_autocmd({ 'BufEnter', 'FocusGained', 'InsertLeave', 'WinEnter' }, {
	group = 'NumberToggle',
	pattern = '*',
	callback = function()
		if vim.opt.number and vim.api.nvim_get_mode() ~= 'i' then
			vim.opt.relativenumber = true
		end
	end,
})
vim.api.nvim_create_autocmd({ 'BufLeave', 'FocusLost', 'InsertEnter', 'WinLeave' }, {
	group = 'NumberToggle',
	pattern = '*',
	callback = function()
		if vim.opt.number then
			vim.opt.relativenumber = false
		end
	end,
})

-- Quickly time out on keycodes, but never time out on mappings
vim.opt.timeout = false
vim.opt.ttimeout = true
vim.opt.ttimeoutlen = 200

-- Keep sign column open so that UI stops jumping around
vim.opt.signcolumn = 'yes'

-- Use Nerd fonts for features enabled
vim.g.have_nerd_font = true

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
vim.keymap.set('i', '{,<CR>', '{<CR>},<ESC>O')

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
		'chentoast/marks.nvim',
		config = function()
			require('marks').setup()
		end,

	},
	'tpope/vim-commentary',
	{
		'easymotion/vim-easymotion',
		config = function()
			-- Disable default mappings
			vim.g.EasyMotion_do_mapping = 0
			-- Jump to anywhere you want with minimal keystrokes, with just one key binding.
			-- `s{char}{char}{label}`
			vim.keymap.set('', 'gs', '<Plug>(easymotion-overwin-f2)')
			-- Turn on case-insensitive feature
			vim.g.EasyMotion_smartcase = 1
			-- HJKL motions: Line motions
			vim.keymap.set('n', 'gh', '<plug>(easymotion-linebackward)')
			vim.keymap.set('n', 'gj', '<plug>(easymotion-j)')
			vim.keymap.set('n', 'gk', '<plug>(easymotion-k)')
			vim.keymap.set('n', 'gl', '<plug>(easymotion-lineforward)')
		end,
	},
	{
		'akinsho/bufferline.nvim',
		version = "*",
		dependencies = 'nvim-tree/nvim-web-devicons'
	},
	{
		'stevearc/oil.nvim',
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("oil").setup()
			vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
		end,
	},
	{
		'nvim-telescope/telescope.nvim',
		tag = '0.1.6',
		dependencies = {
			{     -- If encountering errors, see telescope-fzf-native README for installation instructions
				'nvim-telescope/telescope-fzf-native.nvim',

				-- `build` is used to run some command when the plugin is installed/updated.
				-- This is only run then, not every time Neovim starts up.
				build = 'make',

				-- `cond` is a condition used to determine whether this plugin should be
				-- installed and loaded.
				cond = function()
					return vim.fn.executable 'make' == 1
				end,
			},
			'nvim-lua/plenary.nvim',
			'nvim-telescope/telescope-ui-select.nvim',
			{ 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },

		},
		config = function()
			require('telescope').setup({
				pickers = {
					find_files = {
						hidden = true,
						find_command = {
							'rg',
							'--files',
							'--hidden',
							'--glob', '!**/.git/*',
							'--glob', '!**/node%_modules/*',
						},
					}
				},
				extensions = {
					['ui-select'] = {
						require('telescope.themes').get_dropdown(),
					},
				},
			})

			pcall(require('telescope').load_extension, 'fzf')
			pcall(require('telescope').load_extension, 'ui-select')

			local builtin = require('telescope.builtin')
			vim.keymap.set('n', 'ff', builtin.find_files, {})
			vim.keymap.set('n', 'fg', builtin.live_grep, {})
			vim.keymap.set('n', 'fb', builtin.buffers, {})
			vim.keymap.set('n', 'fh', builtin.help_tags, {})
		end,
	},
	{
		"folke/noice.nvim",
		event = "VeryLazy",
		dependencies = {
			"MunifTanjim/nui.nvim",
			"rcarriga/nvim-notify",
		},
		config = function()
			require('noice').setup({
				lsp = {
					-- override markdown rendering so that **cmp** and other plugins use **Treesitter**
					override = {
						["vim.lsp.util.convert_input_to_markdown_lines"] = true,
						["vim.lsp.util.stylize_markdown"] = true,
						["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
					},
				},
				-- you can enable a preset for easier configuration
				presets = {
					bottom_search = true,    -- use a classic bottom cmdline for search
					command_palette = true,  -- position the cmdline and popupmenu together
					long_message_to_split = true, -- long messages will be sent to a split
					inc_rename = false,      -- enables an input dialog for inc-rename.nvim
					lsp_doc_border = true,   -- add a border to hover docs and signature help
				},
			})
		end
	},
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		init = function()
			vim.o.timeout = true
			vim.o.timeoutlen = 500
		end,
		opts = {
			triggers_blacklist = {
				i = {
					'{',
				},
			},
		},
	},
	{
		'nvim-treesitter/nvim-treesitter',
		build = ':TSUpdate',
		config = function()
			vim.filetype.add {
				extension = {
					-- Buck2 Extensions
					BUCK = 'starlark',
					TARGETS = 'starlark',
				}
			}
		end,
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
	{
		'nvim-treesitter/nvim-treesitter-textobjects',
		dependencies = { 'nvim-treesitter/nvim-treesitter' },
	},
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
		build = function()
			vim.cmd('TSInstall markdown')
			vim.cmd('TSInstall markdown_inline')
		end,
		config = function()
			require('lspsaga').setup({
				lightbulb = {
					virtual_text = false
				},
			})
		end,
	},
	{
		'hrsh7th/nvim-cmp',
		dependencies = {
			'neovim/nvim-lspconfig',
			'hrsh7th/cmp-nvim-lsp',
			'hrsh7th/cmp-buffer',
			'hrsh7th/cmp-path',
			'hrsh7th/cmp-cmdline',
			'hrsh7th/nvim-cmp',
		},
		config = function()
			local cmp = require 'cmp'
			cmp.setup({
				snippet = {
					-- REQUIRED - you must specify a snippet engine
					expand = function(args)
						-- vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
						-- require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
						-- require('snippy').expand_snippet(args.body) -- For `snippy` users.
						-- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
						vim.snippet.expand(args.body) -- For native neovim snippets (Neovim v0.10+)
					end,
				},
				window = {
					completion = cmp.config.window.bordered(),
					documentation = cmp.config.window.bordered(),
				},
				mapping = cmp.mapping.preset.insert({
					['<C-b>'] = cmp.mapping.scroll_docs(-4),
					['<C-f>'] = cmp.mapping.scroll_docs(4),
					['<C-Space>'] = cmp.mapping.complete(),
					['<C-e>'] = cmp.mapping.abort(),
					['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
				}),
				sources = cmp.config.sources({
					{ name = 'nvim_lsp' },
					-- { name = 'vsnip' }, -- For vsnip users.
					-- { name = 'luasnip' }, -- For luasnip users.
					-- { name = 'ultisnips' }, -- For ultisnips users.
					-- { name = 'snippy' }, -- For snippy users.
				}, {
					{ name = 'buffer' },
				})
			})

			-- Set configuration for specific filetype.
			cmp.setup.filetype('gitcommit', {
				sources = cmp.config.sources({
					{ name = 'git' }, -- You can specify the `git` source if [you were installed it](https://github.com/petertriho/cmp-git).
				}, {
					{ name = 'buffer' },
				})
			})

			-- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
			cmp.setup.cmdline({ '/', '?' }, {
				mapping = cmp.mapping.preset.cmdline(),
				sources = {
					{ name = 'buffer' }
				}
			})

			-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
			cmp.setup.cmdline(':', {
				mapping = cmp.mapping.preset.cmdline(),
				sources = cmp.config.sources({
					{ name = 'path' }
				}, {
					{ name = 'cmdline' }
				}),
				matching = { disallow_symbol_nonprefix_matching = false }
			})

			-- Set up lspconfig.
			local capabilities = require('cmp_nvim_lsp').default_capabilities()
			-- Replace <YOUR_LSP_SERVER> with each lsp server you've enabled.
			require('lspconfig')['rust_analyzer'].setup {
				capabilities = capabilities
			}
		end
	},
	{
		"chrishrb/gx.nvim",
		keys = { { "gx", "<cmd>Browse<cr>", mode = { "n", "x" } } },
		cmd = { "Browse" },
		init = function()
			vim.g.netrw_nogx = 1 -- disable netrw gx
		end,
		dependencies = { "nvim-lua/plenary.nvim" },
		submodules = false, -- not needed, submodules are required only for tests
		config = function()
			require("gx").setup {
				handlers = {
					plugin = true,       -- open plugin links in lua (e.g. packer, lazy, ..)
					github = true,       -- open github issues
					brewfile = true,     -- open Homebrew formulaes and casks
					package_json = true, -- open dependencies from package.json
					search = true,       -- search the web/selection on the web if nothing else is found
					rust = {             -- custom handler to open rust's cargo packages
						name = "rust",     -- set name of handler
						filetype = { "toml" }, -- you can also set the required filetype for this handler
						filename = "Cargo.toml", -- or the necessary filename
						handle = function(mode, line, _)
							local crate = require("gx.helper").find(line, mode, "(%w+)%s-=%s")

							if crate then
								return "https://crates.io/crates/" .. crate
							end
						end,
					},
				},
				handler_options = {
					search_engine = "google", -- you can select between google, bing, duckduckgo, and ecosia
					select_for_search = false, -- if your cursor is e.g. on a link, the pattern for the link AND for the word will always match. This disables this behaviour for default so that the link is opened without the select option for the word AND link
				},
			}
		end,
	},
}, {})

------------------------------------------------------------
