nnoremap ; :

map <C-H> <C-W>h
map <C-J> <C-W>j
map <C-K> <C-W>k
map <C-L> <C-W>l

map <S-H> <C-W>H
map <S-J> <C-W>J
map <S-K> <C-W>K
map <S-L> <C-W>L

map <silent> <C-n> :NERDTreeFocus<CR>

let g:airline#extensions#tabline#enabled=1
let g:airline_powerline_fonts=1
let g:airline_theme='base16_default'
let g:rainbow_active=1

set lcs+=space:·
set nu

call plug#begin()
  Plug 'airblade/vim-gitgutter'
  Plug 'frazrepo/vim-rainbow'
  Plug 'nordtheme/vim'
  Plug 'preservim/nerdtree'
  Plug 'Xuyuanp/nerdtree-git-plugin'
  Plug 'ycm-core/YouCompleteMe'
call plug#end()

colorscheme nord
