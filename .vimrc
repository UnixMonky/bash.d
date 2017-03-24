" Matt's custom vimrc for linux

set expandtab         " Tab will insert spaces instead of ^I
set shiftwidth=4        " how far to indent tabs
set softtabstop=4       " how many columns text is indented with the reindent operations (<< and >>)
set tabstop=4         " how many columns text is indented with the reindent operations (<< and >>)
set autoindent        " copy indent from previous line
set smartindent         " does the right thing (mostly) in programs
set cindent           " stricter rules for C programs
set expandtab         " use spaces instead of tabs
set ignorecase        " case insesitive searching
set hlsearch          " search result highlighting
set incsearch         " make search act like modern browsers
set ffs=unix,dos,mac      " unix as standard filetype
set textwidth=0         " disable auto line break
set wrapmargin=0        " these two lines prevent physical linewrap

set backup          " enable backing up file on open
set backupdir=/tmp      " path of backup file
set directory=/tmp      " path of swap file

" Set Solarized Theme
syntax enable
set background=dark
colorscheme solarized

" set font
if has('gui_running')
  set guifont=Monoisome\ Semi-Condensed\ 10
  set lines=36 columns=120
endif

" Removes trailing spaces
map <F12> :call TrimWhiteSpace()<CR>
func! TrimWhiteSpace()
  %s/\s*$//
  ''
:endfunction

" Returns true if paste mode is enabled
function! HasPaste()
  if &paste
    return 'PASTE MODE  '
  en
  return ''
endfunction

" add write as root
cnoremap w!! w !sudo tee >/dev/null %

" Return to the last edit position when opening files.
augroup vimrcEx
  autocmd!
  autocmd BufReadPost *
    \ if line("'\"") > 0 && line("'\"") <= line("$") |
    \   exe "normal g`\"" |
    \ endif
augroup END

" Ensure cursor is at the top of the file, if editing a git commit message:
au FileType gitcommit au! BufEnter COMMIT_EDITMSG call setpos('.', [0, 1, 1, 0])

" always show the status line
set laststatus=2

" Format the status line
set statusline=\ %{HasPaste()}%F%m%r%h\ %w\ \ CWD:\ %r%{getcwd()}%h\ \ \ Line:\ %l\ \Col:\ %c

" Delete trailing white space on save, useful for (Python)
func! DeleteTrailingWS()
  exe "normal mz"
  %s/\s\+$//ge
  exe "normal `z"
endfunc
autocmd BufWrite *.py :call DeleteTrailingWS()

" Highlight trailing whitespace in red
match ErrorMsg /\s\+\%#\@<!$/
