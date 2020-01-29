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
Plugin 'lyuts/vim-rtags'
Plugin 'tomtom/tcomment_vim'
Plugin 'JazzCore/ctrlp-cmatcher'
Plugin 'rking/ag.vim'
Plugin 'ntpeters/vim-better-whitespace'
Plugin 'ervandew/supertab'
Plugin 'soramugi/auto-ctags.vim'
Plugin 'joshukraine/dragvisuals'
Plugin 'machakann/vim-sandwich'

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required

let python_highlight_all=1

colorscheme afterglow
set relativenumber
set number
set syntax=on
set cindent
set textwidth=100
set clipboard=unnamed
set incsearch
set cursorline
hi CursorLine term=bold cterm=bold
set colorcolumn=+1
set foldmethod=indent
set foldlevel=99
set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab
set autoindent

"split navigations
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

"search for text
nmap <F3>1 :silent Ag <C-R><C-W> --cc<CR>:redr!<CR>:copen<CR>
nmap <F3>2 :silent Ag <C-R><C-W> --cpp<CR>:redr!<CR>:copen<CR>
nmap <F3>u2 :silent Ag <C-R><C-W> --cpp -U<CR>:redr!<CR>:copen<CR>
nmap <F3>3 :silent Ag <C-R><C-W> --python<CR>:redr!<CR>:copen<CR>
nmap <F3>4 :silent Ag <C-R><C-W> *<CR>:redr!<CR>:copen<CR>
nmap <F3>0 :silent Ag <C-R><C-W>
nmap <F3>pf :silent Ag "def <C-R><C-W>" --python<CR>:redr!<CR>:copen<CR>
nmap <F8> :TagbarToggle<CR>

nmap <leader>o :copen<CR>
nmap <leader>c :cclose<CR>
nmap <leader>r :redraw!<CR>
nmap <leader>f :FZF<CR>
nmap <leader>fr :%s/<C-R><C-W>//gc<LEFT><LEFT><LEFT>
nmap <leader>b :ls<CR>:b 
nmap <leader>id :r !date<CR>
nmap <leader>s :source ~/.vimrc<CR>

nmap <leader>t :tabnew<CR>
nmap <leader>l :tablast<CR>

runtime bundle/dragvisuals/plugins/dragvisuals.vim
vmap  <expr> <C-h> DVB_Drag('left')
vmap  <expr> <C-l> DVB_Drag('right')
vmap  <expr> <C-j> DVB_Drag('down')
vmap  <expr> <C-k> DVB_Drag('up')
let g:DVB_TrimWS = 1

au WinEnter,BufNewFile,BufRead *.py
	\ nmap pdb A<CR>import pdb; pdb.set_trace()

let &t_ti.="\e[1 q"
let &t_SI.="\e[5 q"
let &t_EI.="\e[1 q"
let &t_te.="\e[0 q"


if executable('ag')
	set grepprg=ag\ --nogroup\ --nocolor
	let g:ctrlp_user_command = 'ag %s -i --nocolor --nogroup --ignore ''.git'' --ignore ''.DS_Store'' --ignore ''node_modules'' --hidden -g ""'
endif

let g:ctrlp_match_func = {'match' : 'matcher#cmatch' }
let g:better_whitespace_enabled=1
