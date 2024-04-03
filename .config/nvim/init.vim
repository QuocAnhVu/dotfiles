" URL: http://vim.wikia.com/wiki/Example_vimrc
" Authors: http://vim.wikia.com/wiki/Vim_on_Freenode
" Description: A minimal, but feature rich, example .vimrc. If you are a
"              newbie, basing your first .vimrc on this file is a good choice.
"              If you're a more advanced user, building your own .vimrc based
"              on this file is still a good idea.

"------------------------------------------------------------

let mapleader=" "

"------------------------------------------------------------
" Plugins {{{1

" Ensure Plug is installed
if empty(glob('~/.vim/autoload/plug.vim'))
    silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
                \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif


call plug#begin('~/.local/share/nvim/plugged')

    " Theme: Gruvbox Material
    Plug 'sainnhe/gruvbox-material'

    " powerline/airline
    Plug 'vim-airline/vim-airline'
        let g:airline_powerline_fonts = 1
        " if has('nvim')
        "     Plug 'vim-airline/vim-airline'
        "     let g:airline_powerline_fonts = 1
        " elseif !has('nvim')
        "     python3 from powerline.vim import setup as powerline_setup
        "     python3 powerline_setup()
        "     python3 del powerline_setup
        " endif
        let g:airline_theme = 'gruvbox_material'

    " Syntax highlighting
    " A collection of language packs for Vim syntax highlighting.
    Plug 'sheerun/vim-polyglot'

    " Indent line
    " This plugin adds indentation guides to Neovim. It uses Neovim's virtual text feature and no conceal
    Plug 'lukas-reineke/indent-blankline.nvim'

    " Code context
    " A Vim plugin that shows the context of the currently visible buffer contents.
    Plug 'wellle/context.vim'

    " Git gutter
    " Signify (or just Sy) uses the sign column to indicate added, modified and removed lines in a file that is managed by a version control system (VCS).
    Plug 'mhinz/vim-signify'
        " default updatetime 4000ms is not good for async update
        set updatetime=100

    " Comment automation
    " Use gcc to comment out a line (takes a count), gc to comment out the target of a motion (for example, gcap to comment out a paragraph), gc in visual mode to comment out the selection, and gc in operator pending mode to target a comment. You can also use it as a command, either with a range like :7,17Commentary, or as part of a :global invocation like with :g/TODO/Commentary.
    Plug 'tpope/vim-commentary'

    " Traverse file
    Plug 'easymotion/vim-easymotion'
        let g:EasyMotion_do_mapping = 0 " Disable default mappings
        " Jump to anywhere you want with minimal keystrokes, with just one key binding.
        " `s{char}{char}{label}`
        nmap ss <Plug>(easymotion-overwin-f2)
        " Turn on case-insensitive feature
        let g:EasyMotion_smartcase = 1
        " HJKL motions: Line motions
        map sh <Plug>(easymotion-linebackward)
        map sj <Plug>(easymotion-j)
        map sk <Plug>(easymotion-k)
        map sl <Plug>(easymotion-lineforward)

    " Open files
    Plug 'ctrlpvim/ctrlp.vim'
        if executable('rg')
            set grepprg=rg\ --color=never
            let g:ctrlp_user_command = 'rg %s --files --color=never --glob ""'
            let g:ctrlp_use_caching = 0
        endif
        let g:ctrlp_map = '<c-p>'
        let g:ctrlp_cmd = 'CtrlP'
        let g:ctrlp_user_command = ['.git', 'cd %s && git ls-files -co --exclude-standard']
        let g:ctrlp_working_path_mode = 'ra'
        let g:ctrlp_custom_ignore = 'node_modules\|DS_Store\|git'

    " Search in files
    Plug 'mileszs/ack.vim'
        " Use ripgrep for searching ⚡️
        " Options include:
        " --vimgrep -> Needed to parse the rg response properly for ack.vim
        " --type-not sql -> Avoid huge sql file dumps as it slows down the search
        " --smart-case -> Search case insensitive if all lowercase pattern, Search case sensitively otherwise
        let g:ackprg = 'rg --vimgrep --type-not sql --smart-case'
        " Auto close the Quickfix list after pressing '<enter>' on a list item
        let g:ack_autoclose = 1
        " Any empty ack search will search for the work the cursor is on
        let g:ack_use_cword_for_empty_search = 1
        " Don't jump to first match
        cnoreabbrev Ack Ack!
        " Maps <leader>/ so we're ready to type the search keyword
        nnoremap <Leader>/ :Ack!<Space>
        " Navigate quickfix list with ease
        nnoremap <silent> [q :cprevious<CR>
        nnoremap <silent> ]q :cnext<CR>

    " Writing mode
    Plug 'QuocAnhVu/write.vim'
        let g:write_auto=['markdown', 'help', 'text!']
call plug#end()

"------------------------------------------------------------
" Features {{{1
"
" These options and commands enable some very useful features in Vim, that
" no user should have to live without.

" Set 'nocompatible' to ward off unexpected things that your distro might
" have made, as well as sanely reset options when re-sourcing .vimrc
set nocompatible

" Attempt to determine the type of a file based on its name and possibly its
" contents. Use this to allow intelligent auto-indenting for each filetype,
" and for plugins that are filetype specific.
filetype indent plugin on

" Enable syntax highlighting
syntax on


"------------------------------------------------------------
" Must have options {{{1
"
" These are highly recommended options.

" Vim with default settings does not allow easy switching between multiple files
" in the same editor window. Users can use multiple split windows or multiple
" tab pages to edit multiple files, but it is still best to enable an option to
" allow easier switching between files.
"
" One such option is the 'hidden' option, which allows you to re-use the same
" window and switch from an unsaved buffer without saving it first. Also allows
" you to keep an undo history for multiple files when re-using the same window
" in this way. Note that using persistent undo also lets you undo in multiple
" files even in the same window, but is less efficient and is actually designed
" for keeping undo history after closing Vim entirely. Vim will complain if you
" try to quit without saving, and swap files will keep you safe if your computer
" crashes.
set hidden

" Note that not everyone likes working this way (with the hidden option).
" Alternatives include using tabs or split windows instead of re-using the same
" window as mentioned above, and/or either of the following options:
" set confirm
" set autowriteall

" Better command-line completion
set wildmenu

" Show partial commands in the last line of the screen
set showcmd

" Highlight searches (use <C-L> to temporarily turn off highlighting; see the
" mapping of <C-L> below)
set hlsearch

" Modelines have historically been a source of security vulnerabilities. As
" such, it may be a good idea to disable them and use the securemodelines
" script, <http://www.vim.org/scripts/script.php?script_id=1876>.
" set nomodeline


"------------------------------------------------------------
" Usability options {{{1
"
" These are options that users frequently set in their .vimrc. Some of them
" change Vim's behaviour in ways which deviate from the true Vi way, but
" which are considered to add usability. Which, if any, of these options to
" use is very much a personal preference, but they are harmless.

" Use case insensitive search, except when using capital letters
set ignorecase
set smartcase

" Allow backspacing over autoindent, line breaks and start of insert action
set backspace=indent,eol,start

" When opening a new line and no filetype-specific indenting is enabled, keep
" the same indent as the line you're currently on. Useful for READMEs, etc.
set autoindent

" Stop certain movements from always going to the first character of a line.
" While this behaviour deviates from that of Vi, it does what most users
" coming from other editors would expect.
set nostartofline

" Display the cursor position on the last line of the screen or in the status
" line of a window
set ruler

" Always display the status line, even if only one window is displayed
set laststatus=2

" Instead of failing a command because of unsaved changes, instead raise a
" dialogue asking if you wish to save changed files.
set confirm

" Use visual bell instead of beeping when doing something wrong
set visualbell

" And reset the terminal code for the visual bell. If visualbell is set, and
" this line is also included, vim will neither flash nor beep. If visualbell
" is unset, this does nothing.
set t_vb=

" Enable use of the mouse for all modes
set mouse=a

" Set the command window height to 2 lines, to avoid many cases of having to
" "press <Enter> to continue"
set cmdheight=2

" Display line numbers on the left
set number

" Quickly time out on keycodes, but never time out on mappings
set notimeout ttimeout ttimeoutlen=200

" Use <F11> to toggle between 'paste' and 'nopaste'
set pastetoggle=<F11>


"------------------------------------------------------------
" Indentation options {{{1
"
" Indentation settings according to personal preference.

" Indentation settings for using 4 spaces instead of tabs.
set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab

" Indentation settings for using hard tabs for indent. Display tabs as
" four characters wide.
"set shiftwidth=4
"set tabstop=4

" Set indentation when soft-wrapping
" Indents word-wrapped lines as much as the 'parent' line
set breakindent
" Ensures word-wrap does not split words
set formatoptions=l
set lbr
" ident by an additional 2 characters on wrapped lines, when line >= 40 characters, put 'showbreak' at start of line
set breakindentopt=shift:2,min:40,sbr

"------------------------------------------------------------
" Mappings {{{1
"
" Useful mappings

" Map Y to act like D and C, i.e. to yank until EOL, rather than act as yy,
" which is the default
map Y y$

" Map <C-L> (redraw screen) to also turn off search highlighting until the
" next search
nnoremap <C-L> :nohl<CR><C-L>

" We can use different key mappings for easy navigation between splits to save a keystroke. So instead of ctrl-w then j, it’s just ctrl-j
" nnoremap <C-J> <C-W><C-J>
" nnoremap <C-K> <C-W><C-K>
" nnoremap <C-L> <C-W><C-L>
" nnoremap <C-H> <C-W><C-H>

" Autoclose brackets
" inoremap " ""<left>
" inoremap ' ''<left>
" inoremap ( ()<left>
" inoremap [ []<left>
" inoremap { {}<left>
inoremap {<CR> {<CR>}<ESC>O
inoremap {;<CR> {<CR>};<ESC>O

"------------------------------------------------------------
" Fixes {{{1
"
" Environment specific fixes.

" Set correct python3
let g:python3_host_prog = expand('$HOME/.local/share/asdf/shims/python3')

"------------------------------------------------------------
