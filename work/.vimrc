set nocompatible              " required
filetype off                  " required

autocmd BufNewFile,BufRead Engineering.py let b:tagbar_ignore = 1
" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'gmarik/Vundle.vim'

" add all your plugins here (note older versions of Vundle
" used Bundle instead of Plugin)

Plugin 'vim-scripts/indentpython.vim'
Plugin 'rafi/awesome-vim-colorschemes'
Plugin 'altercation/vim-colors-solarized'
Plugin 'kien/ctrlp.vim'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plugin 'junegunn/fzf.vim'
Plugin 'majutsushi/tagbar'
Plugin 'sjl/badwolf'
Plugin 'FelikZ/ctrlp-py-matcher'
Plugin 'nixprime/cpsm'
Plugin 'JazzCore/ctrlp-cmatcher'
Plugin 'rking/ag.vim'

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required

let python_highlight_all=1

set relativenumber
set number
set syntax=on
set cindent

set foldmethod=indent
set foldlevel=99

"split navigations
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

"search for text
nmap <F3>1 :silent grep! <C-R><C-W> --c<CR>:redr!<CR>:copen<CR>
nmap <F3>2 :silent grep! <C-R><C-W> --cpp<CR>:redr!<CR>:copen<CR>
nmap <F3>u2 :silent grep! <C-R><C-W> --cpp -U<CR>:redr!<CR>:copen<CR>
nmap <F3>3 :silent grep! <C-R><C-W> --python<CR>:redr!<CR>:copen<CR>
nmap <F3>4 :silent grep! <C-R><C-W> *<CR>:redr!<CR>:copen<CR>
nmap <F3>0 :silent grep! <C-R><C-W>
nmap <F3>pf :silent grep! "def <C-R><C-W>" --python<CR>:redr!<CR>:copen<CR>
nmap <F8> :TagbarToggle<CR>

nmap <space> za
nmap <leader>o :copen<CR>
nmap <leader>c :cclose<CR>
nmap <leader>r :redraw!<CR>
nmap <leader>f :FZF<CR>
nmap <leader>fr :%s/<C-R><C-W>//gc<LEFT><LEFT><LEFT>
nmap <leader>b :ls<CR>:b 
nmap <leader>id :r !date<CR>
nmap <leader>s :source ~/.vimrc<CR>
nmap ,jt <ESC>ggi======================<CR>
			\ISSUE<CR>======================<CR><ESC>kk0llll

nmap <TAB><TAB> :tabnew<CR>
nmap <TAB>l :tablast<CR>

set tabstop=4
set shiftwidth=4
set textwidth=200

"python PEP8 indentation
au WinEnter,BufNewFile,BufRead *.py
	\ set tabstop=4 |
	\ set softtabstop=4 |
	\ set shiftwidth=4 |
	\ set textwidth=150 |
	\ set expandtab |
	\ set autoindent |
	\ nmap pdb A<CR>import pdb; pdb.set_trace()|
    \ colorscheme gruvbox |
	\ nmap <leader>g I// <ESC>

au WinEnter,BufNewFile,BufRead *.cpp
	\ set tabstop=4 |
	\ set softtabstop=4 |
	\ set shiftwidth=4 |
	\ set textwidth=150 |
	\ set expandtab |
	\ set autoindent |
    \ colorscheme afterglow |
	\ nmap <leader>g I// <ESC>

au WinEnter,BufNewFile,BufRead *.hpp
	\ set tabstop=4 |
	\ set softtabstop=4 |
	\ set shiftwidth=4 |
	\ set textwidth=150 |
	\ set expandtab |
	\ set autoindent |
    \ colorscheme afterglow |
	\ nmap <leader>g I// <ESC>

au WinEnter,BufNewFile,BufRead *.c
	\ set tabstop=4 |
	\ set softtabstop=4 |
	\ set shiftwidth=4 |
	\ set textwidth=150 |
	\ set expandtab |
	\ set autoindent |
	\ set fileformat=dos |
    \ colorscheme afterglow |
	\ nmap <leader>g I// <ESC>

au WinEnter,BufNewFile,BufRead *.h
	\ set tabstop=4 |
	\ set softtabstop=4 |
	\ set shiftwidth=4 |
	\ set textwidth=150 |
	\ set expandtab |
	\ set autoindent |
	\ set fileformat=dos |
    \ colorscheme afterglow |
	\ nmap <leader>g I// <ESC>

set clipboard=unnamed

if has('gui_running')
  set background=dark
  colorscheme solarized
else
  colorscheme afterglow
endif

set incsearch

"Flag whitespaces
highlight BadWhitespace ctermbg=darkgreen guibg=lightgreen
au BufRead,BufNewFile *.cpp,*.hpp,*.py,*.pyw,*.c,*.h match BadWhitespace /\s\+$/

let &t_ti.="\e[1 q"
let &t_SI.="\e[5 q"
let &t_EI.="\e[1 q"
let &t_te.="\e[0 q"

set incsearch
set cursorline
hi CursorLine term=bold cterm=bold

if executable('ag')
	set grepprg=ag\ --nogroup\ --nocolor
	let g:ctrlp_user_command = 'ag %s -i --nocolor --nogroup --ignore ''.git'' --ignore ''.DS_Store'' --ignore ''node_modules'' --hidden -g ""'
endif

let g:ctrlp_match_func = {'match' : 'matcher#cmatch' }
