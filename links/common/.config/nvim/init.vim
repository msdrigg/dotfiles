call plug#begin()

Plug 'scrooloose/nerdtree'
Plug 'vim-airline/vim-airline'
Plug 'godlygeek/tabular'
Plug 'plasticboy/vim-markdown'
Plug 'pprovost/vim-ps1'
Plug 'udalov/kotlin-vim'
Plug 'tpope/vim-commentary'
Plug 'dense-analysis/ale'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/goyo.vim'
Plug 'amix/vim-zenroom2'


if has('nvim')
  Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
else
  Plug 'Shougo/deoplete.nvim'
  Plug 'roxma/nvim-yarp'
  Plug 'roxma/vim-hug-neovim-rpc'
endif

call plug#end()

" Tailor vim-markdown plugin
" Add markdown math
let g:vim_markdown_math = 1
" Add strikethrough
let g:vim_markdown_strikethrough = 1
" Stop folding by default
let g:vim_markdown_folding_disabled = 1

" Setting tab width to desired
set expandtab
set tabstop=4 shiftwidth=4

" Set autocommands like this to set tabstop and shiftwidth per file type
autocmd Filetype css setlocal tabstop=4 shiftwidth=4

" Have some extra lines after cursor
set scrolloff=5

" Sets how many lines of history VIM has to remember
set history=500

" Enable filetype plugins
filetype plugin on
filetype indent on

command! W execute 'w !sudo tee % > /dev/null' <bar> edit!

set wildmenu
set wildmode=longest:full,full

" Ignore case when searching
set ignorecase

" When searching try to be smart about cases
set smartcase

" Highlight search results
set hlsearch

" Makes search act like search in modern browsers
set incsearch

" Don't redraw while executing macros (good performance config)
set lazyredraw

" Show matching brackets when text indicator is over them
set showmatch
" How many tenths of a second to blink when matching brackets
set mat=2

" No annoying sound on errors
set noerrorbells
set novisualbell
set t_vb=
set tm=500

" Enable syntax highlighting
syntax enable

set ai "Auto indent
set si "Smart indent
set wrap "Wrap lines


" Return to last edit position when opening files (You want this!)
au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif

" Set font according to system
if has("mac") || has("macunix")
    set gfn=IBM\ Plex\ Mono:h14,Hack:h14,Source\ Code\ Pro:h15,Menlo:h15
elseif has("win16") || has("win32")
    set gfn=IBM\ Plex\ Mono:h14,Source\ Code\ Pro:h12,Bitstream\ Vera\ Sans\ Mono:h11
elseif has("gui_gtk2")
    set gfn=IBM\ Plex\ Mono\ 14,:Hack\ 14,Source\ Code\ Pro\ 12,Bitstream\ Vera\ Sans\ Mono\ 11
elseif has("linux")
    set gfn=IBM\ Plex\ Mono\ 14,:Hack\ 14,Source\ Code\ Pro\ 12,Bitstream\ Vera\ Sans\ Mono\ 11
elseif has("unix")
    set gfn=Monospace\ 11
endif

" Clipboard settings
" set clipboard+=unnamedplus

" ALE Settings
let g:ale_fix_on_save = 1
let g:ale_sign_column_always = 1

let g:ale_fixers = {
\   '*': ['trim_whitespace'],
\   'sh': ['shfmt'],
\   'python': ['black'],
\   'javascript': ['eslint', 'prettier'],
\   'rust': ['rustfmt'],
\   'markdown': [],
\}

let g:ale_linters = {
\   '*': ['trim_whitespace'],
\   'sh': ['shellcheck'],
\   'python': ['pylint', 'mypy'],
\   'javascript': ['eslint'],
\   'markdown': [],
\   'rust': ['analyzer'],
\   'tex': [],
\   'vim': [],
\}

" Setup used for working with diesel
" let g:ale_rust_analyzer_config = {
" \   'rust-analyzer.cargo.features': ['postgres'],
" \   'rust-analyzer.cargo.allFeatures': 0,
" \}

let g:airline#extensions#ale#enabled = 1

call deoplete#custom#option('sources', {
\ '_': ['ale'],
\})

let g:deoplete#enable_at_startup = 1

autocmd Filetype javascript setlocal tabstop=2 sts=2 sw=2

source /usr/share/doc/fzf/examples/fzf.vim
