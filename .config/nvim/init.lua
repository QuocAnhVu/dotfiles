-- Neovim config (0.12+).
--
-- Plugins are installed by home-manager (programs.neovim.plugins in
-- home/full.nix), not a plugin manager. The server profile has none: each
-- plugin section below is skipped when its plugin isn't installed.
-- Language servers also come from home-manager (the same ones helix uses).

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
vim.g.have_nerd_font = true

------------------------------------------------------------
-- Options (only those that differ from Neovim's defaults)

vim.opt.clipboard = "unnamedplus" -- system clipboard (wl-clipboard on Wayland)
vim.opt.ignorecase = true         -- case-insensitive search...
vim.opt.smartcase = true          -- ...unless the pattern has capitals
vim.opt.confirm = true            -- ask to save instead of failing on unsaved changes
vim.opt.visualbell = true
vim.opt.cmdheight = 2             -- fewer "Press ENTER" prompts
vim.opt.signcolumn = "yes"        -- keep the sign column so text doesn't shift
vim.opt.timeoutlen = 500          -- which-key pops up after this delay

-- 4-space indentation
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.tabstop = 4

-- Soft wrap: break at word boundaries, indent continuation lines by 2 more
-- (for lines of at least 40 columns) and mark them with 'showbreak'
vim.opt.linebreak = true
vim.opt.breakindent = true
vim.opt.breakindentopt = { "shift:2", "min:40", "sbr" }

-- Completion menu for LSP completion (see LspAttach below)
vim.opt.completeopt = { "menuone", "noselect", "popup" }

-- Line numbers: relative in the focused window outside insert mode, absolute otherwise
vim.opt.number = true
local numbertoggle = vim.api.nvim_create_augroup("NumberToggle", { clear = true })
vim.api.nvim_create_autocmd({ "BufEnter", "FocusGained", "InsertLeave", "WinEnter" }, {
    group = numbertoggle,
    callback = function()
        if vim.wo.number and vim.api.nvim_get_mode().mode ~= "i" then
            vim.wo.relativenumber = true
        end
    end,
})
vim.api.nvim_create_autocmd({ "BufLeave", "FocusLost", "InsertEnter", "WinLeave" }, {
    group = numbertoggle,
    callback = function()
        if vim.wo.number then
            vim.wo.relativenumber = false
        end
    end,
})

-- Buck2 build files
vim.filetype.add({ filename = { BUCK = "starlark", TARGETS = "starlark" } })

------------------------------------------------------------
-- Mappings (Neovim already maps Y to y$, <C-L> to clear search highlights,
-- and gc/gcc to comment)

-- Expand braces: {<CR> -> {\n|\n}
vim.keymap.set("i", "{<CR>", "{<CR>}<Esc>O")
vim.keymap.set("i", "{;<CR>", "{<CR>};<Esc>O")
vim.keymap.set("i", "{,<CR>", "{<CR>},<Esc>O")

-- Diagnostics ([d / ]d to jump are built in)
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show diagnostic" })
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Diagnostics to location list" })

------------------------------------------------------------
-- Language servers
--
-- nvim-lspconfig provides each server's default settings; a server is enabled
-- only if its program is installed.

vim.lsp.config("rust_analyzer", {
    settings = { ["rust-analyzer"] = { check = { command = "clippy" } } },
})
vim.lsp.config("pyright", {
    settings = { python = { analysis = { typeCheckingMode = "standard" } } },
})

for _, name in ipairs({
    "clangd", "cssls", "dockerls", "html", "jsonls", "lua_ls", "pyright", "ruff",
    "rust_analyzer", "svelte", "tailwindcss", "taplo", "tinymist", "ts_ls", "wgsl_analyzer",
}) do
    local config = vim.lsp.config[name]
    local cmd = config and config.cmd
    if type(cmd) == "function" or (type(cmd) == "table" and vim.fn.executable(cmd[1]) == 1) then
        vim.lsp.enable(name)
    end
end

-- Built in once a server attaches: K (hover), grn (rename), gra (code action),
-- grr (references), gri (implementation), gO (symbols), <C-S> in insert mode
-- (signature help), gq (format via formatexpr).
vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("UserLsp", { clear = true }),
    callback = function(args)
        local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
        if client:supports_method("textDocument/completion") then
            vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })
        end
        local function map(lhs, rhs, desc)
            vim.keymap.set("n", lhs, rhs, { buffer = args.buf, desc = desc })
        end
        map("gd", vim.lsp.buf.definition, "Go to definition")
        map("gD", vim.lsp.buf.declaration, "Go to declaration")
        map("<leader>D", vim.lsp.buf.type_definition, "Go to type definition")
        map("<leader>F", function() vim.lsp.buf.format({ async = true }) end, "Format buffer")
    end,
})

------------------------------------------------------------
-- Plugins

-- require() a plugin if it's installed; nil otherwise
local function plugin(name)
    local ok, mod = pcall(require, name)
    return ok and mod or nil
end

-- Theme: switch with ./theme.sh in the dotfiles repo (or swap by hand).
vim.g.everforest_background = "medium"
if plugin("gruvbox") then require("gruvbox").setup({ contrast = "soft" }) end
vim.g.nord_contrast = true
vim.g.nord_borders = true
vim.g.nord_uniform_diff_background = true
-- pcall(vim.cmd.colorscheme, "nord")
-- pcall(vim.cmd.colorscheme, "gruvbox")
pcall(vim.cmd.colorscheme, "everforest")

-- Treesitter: highlighting for every filetype with a parser (installed by home-manager)
vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("UserTreesitter", { clear = true }),
    callback = function() pcall(vim.treesitter.start) end,
})

if plugin("nvim-treesitter-textobjects") then
    require("nvim-treesitter-textobjects").setup({ select = { lookahead = true } })
    local select = require("nvim-treesitter-textobjects.select")
    for keys, object in pairs({
        af = "@function.outer", ["if"] = "@function.inner",
        ac = "@class.outer", ic = "@class.inner",
        aa = "@parameter.outer", ia = "@parameter.inner",
    }) do
        vim.keymap.set({ "x", "o" }, keys, function()
            select.select_textobject(object, "textobjects")
        end, { desc = object })
    end
end

if plugin("treesitter-context") then
    require("treesitter-context").setup()
    vim.keymap.set("n", "[c", function()
        require("treesitter-context").go_to_context(vim.v.count1)
    end, { silent = true, desc = "Go to context" })
end

if plugin("telescope") then
    require("telescope").setup({
        pickers = {
            find_files = {
                find_command = { "rg", "--files", "--hidden", "--glob", "!**/.git/*", "--glob", "!**/node_modules/*" },
            },
        },
        extensions = { ["ui-select"] = { require("telescope.themes").get_dropdown() } },
    })
    pcall(require("telescope").load_extension, "fzf")
    pcall(require("telescope").load_extension, "ui-select")
    local builtin = require("telescope.builtin")
    vim.keymap.set("n", "<leader>f", builtin.find_files, { desc = "Find files" })
    vim.keymap.set("n", "<leader>g", builtin.live_grep, { desc = "Grep" })
    vim.keymap.set("n", "<leader>b", builtin.buffers, { desc = "Buffers" })
    vim.keymap.set("n", "<leader>h", builtin.help_tags, { desc = "Help" })
end

if plugin("oil") then
    require("oil").setup()
    vim.keymap.set("n", "-", "<Cmd>Oil<CR>", { desc = "Open parent directory" })
end

if plugin("gitsigns") then require("gitsigns").setup() end
if plugin("lualine") then require("lualine").setup() end
if plugin("ibl") then require("ibl").setup() end
if plugin("marks") then require("marks").setup() end
if plugin("which-key") then require("which-key").setup() end

-- EasyMotion (Vimscript): read before the plugin loads, so set unconditionally
vim.g.EasyMotion_do_mapping = 0 -- no default mappings
vim.g.EasyMotion_smartcase = 1
vim.keymap.set("", "gs", "<Plug>(easymotion-overwin-f2)", { desc = "Jump to 2 characters" })
vim.keymap.set("n", "gh", "<Plug>(easymotion-linebackward)")
vim.keymap.set("n", "gj", "<Plug>(easymotion-j)")
vim.keymap.set("n", "gk", "<Plug>(easymotion-k)")
vim.keymap.set("n", "gl", "<Plug>(easymotion-lineforward)")
