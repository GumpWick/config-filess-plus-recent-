set mouse=a
set encoding=utf-8
set expandtab
colorscheme default_new2

set number relativenumber

source $HOME/.config/nvim/plug-config/coc.vim

hi MatchParen cterm=none ctermbg=DarkCyan ctermfg=white
" set tabs to have 4 spaces
set ts=4

" indent when moving to the next line while writing code
filetype plugin indent on
set autoindent

" WSL yank support
let s:clip = '/mnt/c/Windows/System32/clip.exe'  " change this path according to your mount point
if executable(s:clip)
	augroup WSLYank
		autocmd!
		autocmd TextYankPost * if v:event.operator ==# 'y' | call system(s:clip, @0) | endif
	augroup END
endif

set clipboard=unnamed

autocmd TextYankPost * call system('win32yank.exe -i --crlf', @")
function! Paste(mode)
	let @" = system('win32yank.exe -o --lf')
	return a:mode
endfunction

map <expr> p Paste('p')
map <expr> P Paste('P')


"automatically complete parentheses and quotes
"Fait bugué la documentation des autocompletes de coc.vim mais tant mieux (ça gène pas comme ça)"
inoremap ( ()<Esc>i
inoremap { {}<Esc>i
inoremap {<CR> {<CR>}<Esc>O
inoremap [ []<Esc>i
inoremap < <><Esc>i
inoremap ' ''<Esc>i
inoremap " ""<Esc>i


call plug#begin()


"PLUGINS"
Plug 'https://github.com/tpope/vim-commentary' " For Commenting gcc & gc
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'https://github.com/terryma/vim-multiple-cursors' " CTRL + N for multiple cursors

call plug#end()

inoremap <expr> <Tab> pumvisible() ? coc#_select_confirm() : "<Tab>"



