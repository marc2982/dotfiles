runtime! debian.vim
syntax on
set nocompatible

call pathogen#infect()

" tabs
set expandtab
set tabstop=4
set shiftwidth=4
set softtabstop=4
set smarttab
set scs " smart search (override ignorecase when pattern has uppers)
set bs=2
set vb t_vb= " turn off visual bell
set ignorecase
set smartcase
set backspace=eol,start,indent
set autoindent
set showmatch " Show matching brackets

" searching
set incsearch
set hlsearch

hi Search ctermbg=4

" maps <leader> (in my case, \) + space to clear a search to remove highlighting
:noremap <leader><space> :noh<cr>

"set t_Co=16
"colorscheme darkblue
set t_Co=256
set background=dark
colorscheme molokai

" map jf in insert mode to ESC
inoremap jf <ESC>
inoremap <ESC> <nop>

" map < and > to repeat tabbing action without losing highlight
vnoremap < <gv
vnoremap > >gv

" remap F1 to ESC because I hit it accidentally
inoremap <F1> <ESC>
vnoremap <F1> <ESC>
nnoremap <F1> <ESC>

" use ctrl-space to complete like ctrl-p and ctrl-n
inoremap <Nul> <C-n>

" indentation
filetype indent on

" maps to quickly find unicode characters within the document
map ,uni :match Error /[^ -~]/<CR>
map ,uni2 /[^ -~]<CR>

" find all unicode characters
nmap <F6> /[^ -~^I]<CR>

" highlight characters over 120 characters
highlight OverLength ctermfg=0 ctermbg=15 cterm=bold
match OverLength /\%>121v.\+/

" tab complete bash-like behaviour when opening files
set wildmode=longest,list,full
set wildmenu

" turn on line numbers
nnoremap <F2> :set nonumber!<CR>:set foldcolumn=0<CR>

" load unit test file!
nnoremap <F3> :LoadUnitTestFile<CR>

" enable pylint checking (requires pylint.vim plugin in ~/.vim/compiler/
" By default, this opens a 'Quick Fix' window  with pylint violations every
" time the buffer is written
autocmd FileType python compiler pylint
nmap <F5> :Pylint<CR>

" Removes whitespace at the end of a line before saving
autocmd BufWritePre *.* :%s/\s\+$//e
" Removes trailing whitespace lines from the end of the file
autocmd BufWritePre *.py :%s/\($\n\s*\)\+\%$//e

filetype on            " enables filetype detection
filetype plugin on     " enables filetype specific plugins

" Folding
set foldmethod=indent
set foldnestmax=2       " don't nest more than 2 folds
set foldlevel=10        " start with all folds open

python << EOL
import vim
def createSphinxDocs():
    variables = ''.join(vim.current.range)
    indentationLevel = " "*(len(variables) - len(variables.strip()) + 4)
    variables = variables[variables.index('(')+1:variables.index(')')]
    variables = [var.strip() for var in variables.split(',') if var != "self"]
    currentBuffer = vim.current.buffer
    row, col = vim.current.window.cursor
    currentBuffer[row:row] = [indentationLevel + "\"\"\""]
    for var in reversed(variables):
        currentBuffer[row:row] = [indentationLevel + "    :type %s:" % var]
        currentBuffer[row:row] = [indentationLevel + "    :param %s:" % var]
        currentBuffer[row:row] = [""]
    currentBuffer[row:row] = [indentationLevel + "\"\"\" "]
    vim.current.window.cursor = (row+1,9+len(indentationLevel))

EOL

map <leader>d :py createSphinxDocs()<cr>

" syntastic stuff
"set statusline+=%#warningmsg#
"set statusline+=%{SyntasticStatuslineFlag()}
"set statusline+=%*
let g:syntastic_error_signs=1
let g:syntastic_check_on_open=1
let g:syntastic_mode_map = { 'mode': 'passive',
                           \ 'active_filetypes': ['python'],
                           \ 'passive_filetypes': [] }


" source .vimrc on command
nnoremap <leader>sv :source $MYVIMRC<cr>

" automatically source .vimrc so don't have to restart vim
autocmd! bufwritepost .vimrc source $MYVIMRC

" Yaml
au BufNewFile,BufRead *.yaml,*.yml    setf yaml

" Powerline
set laststatus=2
"let g:Powerline_symbols = 'fancy'
