set nocompatible
set number
set showcmd
set showmatch
set mouse=a
set autoread

colorscheme molokai
map <Space> :
" Mapped through iTerm2, S-Space -> C-\
" Mapped through Mac, CapsLock -> Esc

call plug#begin()
Plug 'Valloric/YouCompleteMe'
Plug 'scrooloose/nerdcommenter'
Plug 'vim-airline/vim-airline'
call plug#end()

filetype plugin indent on
syntax on
