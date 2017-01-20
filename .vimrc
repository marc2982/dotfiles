" This line should not be removed as it ensures that various options are
" properly set to work with the Vim-related packages available in Debian.
runtime! debian.vim

syntax on

" -- vim only settings --
if !has('nvim')
    set autoindent
    set backspace=2  " same as ":set backspace=indent,eol,start"
    set encoding=utf-8
    set hlsearch
    set incsearch
    set laststatus=2  " statusline is always shown
    set nocompatible  " unlock cool vim stuff
    set smarttab
    set t_Co=256  " set number of colours available
    set vb t_vb= " turn off visual bell
    set wildmenu
endif

call pathogen#infect()
call pathogen#helptags()

" tabs
set expandtab
set tabstop=4
set shiftwidth=4
set softtabstop=4

set ignorecase
set smartcase
set showmatch " Show matching brackets

set mouse= " disable mouse support

" word wrap
set wrap
set textwidth=79

set colorcolumn=80

" searching
set scs " smart search (override ignorecase when pattern has uppers)

hi Search ctermbg=4

" clear search highlighting
noremap <leader><space> :noh<cr>

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

" maps to quickly find unicode characters within the document
map ,uni :match Error /[^ -~]/<CR>
map ,uni2 /[^ -~]<CR>

" find all unicode characters
nmap <F6> /[^ -~^I]<CR>

" highlight characters over 120 characters
highlight OverLength ctermfg=0 ctermbg=15 cterm=bold
match OverLength /\%>121v.\+/

" tab complete bash-like behaviour when opening files / running vim commands
set wildmode=longest,list,full

" turn on line numbers
nnoremap <F2> :set nonumber!<CR>:set foldcolumn=0<CR>

" display the syntax highlighting groups for the item under the cursor
map <F8> :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") .
    \ '> trans<' . synIDattr(synID(line("."),col("."),0),"name") . "> lo<"
    \ . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>

" Removes whitespace at the end of a line before saving
autocmd BufWritePre *.* :%s/\s\+$//e
" Removes trailing whitespace lines from the end of the file
autocmd BufWritePre *.py :%s/\($\n\s*\)\+\%$//e

filetype on            " enables filetype detection
filetype plugin on     " enables filetype-specific plugins
filetype indent on     " enables filetype-specific indentation

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

" syntastic stuff -- COMMENTED OUT, REPLACED BY NEOMAKE
"set statusline+=%#warningmsg#
"set statusline+=%{SyntasticStatuslineFlag()}
"set statusline+=%*
"let g:syntastic_error_signs=1
"let g:syntastic_check_on_open=1
"let g:syntastic_check_on_save=1
"let g:syntastic_aggregate_errors=1
"let g:syntastic_always_populate_loc_list=1
"let g:syntastic_python_checkers=['flake8', 'pep257']
"let g:syntastic_javascript_checkers=['jslint.vim']
"let g:syntastic_mode_map = { 'mode': 'passive',
"                           \ 'active_filetypes': ['python', 'javascript'],
"                           \ 'passive_filetypes': [] }
"let g:syntastic_python_flake8_args='--ignore=E501'

" neomake stuff
let g:neomake_python_pydocstyle_maker = {
    \ 'errorformat': '%E%f:%l%.%#,%C%m',
    \ 'buffer_output': 1,
    \ 'ignore': 'D211',
    \ }
let g:neomake_python_enabled_makers = ['pylama', 'pydocstyle']
hi MarcErrMsg ctermfg=0 ctermbg=1
let g:neomake_error_sign = {'texthl': 'MarcErrMsg'}
hi MarcWarnMsg ctermfg=0 ctermbg=11
let g:neomake_warning_sign = {'texthl': 'MarcWarnMsg'}
autocmd! BufReadPost,FileReadPost,BufWritePost * Neomake

" source .vimrc on command
nnoremap <leader>sv :source $MYVIMRC<cr>

" Filetypes
au BufNewFile,BufRead *.yaml,*.yml    setf yaml  " YAML
au BufRead,BufNewFile *.tap set filetype=tap     " TAP

" Powerline
"let g:Powerline_symbols = 'fancy'
"set rtp+=~/.vim/bundle/powerline/powerline/bindings/vim

" vim-airline
"let g:airline_powerline_fonts=1
"let g:airline_left_sep=''
"let g:airline_right_sep=''

" vim-gitgutter
let g:gitgutter_realtime=0
let g:gitgutter_eager=0

" vim-youcompleteme
"let g:ycm_complete_in_comments=0
"let g:ycm_collect_identifiers_from_comments_and_strings=0
let g:ycm_server_keep_logfiles = 1
let g:ycm_server_log_level = 'debug'
let g:ycm_path_to_python_interpreter = '/usr/bin/python'

" vim-tap
hi begin ctermbg=blue ctermfg=black

" use ctrl-space to complete like ctrl-p and ctrl-n
inoremap <Nul> <C-n>

" set encryption method for VimCrypt (':h :X' for more info)
" set cm=blowfish " commented out for nvim

" ~/.vim/syntax/python.vim options
let python_version_2 = 1
let python_highlight_all = 1

" probe
let g:probe_use_gitignore = 1

" rut
let g:rut_projects = [{
    \'pattern': '/vats$',
    \'test_dir': 'tests',
    \'source2unit': ['\v.*/vats/(.*)/([^/]*)', '\1/test_\2'],
    \'unit2source': ['\v.*/tests/(.*)/test_([^/]*)', 'vats/\1/\2'],
    \'runner': 'nosetests',
    \'errorformat': '%C %.%#,%A  File "%f"\, line %l%.%#,%Z%[%^ ]%\@=%m',
\}]

" vim-argwrap
nnoremap <silent> <leader>a :ArgWrap<CR>
let g:argwrap_tail_comma = 1

" automatically source .vimrc so don't have to restart vim
autocmd! bufwritepost .vimrc source $MYVIMRC
