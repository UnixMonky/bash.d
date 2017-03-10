" Matt's custom vimrc for windows

set nocompatible              " required for bug fixing
source $VIMRUNTIME/mswin.vim  " enable ^X,^C,^V for cut,copy,paste
behave xterm                  " enable xterm-style mouse (mswin|xterm)

set expandtab                 " Tab will insert spaces instead of ^I
set shiftwidth=4              " how far to indent tabs
set softtabstop=4             " how many columns text is indented with the reindent operations (<< and >>) 
set autoindent                " copy indent from previous line
set smartindent               " does the right thing (mostly) in programs
set cindent                   " stricter rules for C programs

set lines=36                  " set initial number of text lines
set columns=120               " set initial number of text columns
set textwidth=0               " disable auto line break

set backup                    " enable backing up file on open
set backupdir=c:\\tmp         " path of backup file
set directory=c:\\tmp         " path of swap file
set noundofile                " don't create an undo file


" Set Solarized Theme
syntax enable
set background=dark
colorscheme solarized

" Set the font
if has('gui_running')
  set guifont=Monoid:h9:cANSI
endif

" define Vim behavior when used for diffing two or more buffers
set diffexpr=MyDiff()
function MyDiff()
  let opt = '-a --binary '
  if &diffopt =~ 'icase' | let opt = opt . '-i ' | endif
  if &diffopt =~ 'iwhite' | let opt = opt . '-b ' | endif
  let arg1 = v:fname_in
  if arg1 =~ ' ' | let arg1 = '"' . arg1 . '"' | endif
  let arg2 = v:fname_new
  if arg2 =~ ' ' | let arg2 = '"' . arg2 . '"' | endif
  let arg3 = v:fname_out
  if arg3 =~ ' ' | let arg3 = '"' . arg3 . '"' | endif
  let eq = ''
  if $VIMRUNTIME =~ ' '
    if &sh =~ '\<cmd'
      let cmd = '""' . $VIMRUNTIME . '\diff"'
      let eq = '"'
    else
      let cmd = substitute($VIMRUNTIME, ' ', '" ', '') . '\diff"'
    endif
  else
    let cmd = $VIMRUNTIME . '\diff'
  endif
  silent execute '!' . cmd . ' ' . opt . arg1 . ' ' . arg2 . ' > ' . arg3 . eq
endfunction
