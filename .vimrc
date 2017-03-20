" Matt's custom vimrc for linux

set expandtab                 " Tab will insert spaces instead of ^I
set shiftwidth=4              " how far to indent tabs
set softtabstop=4             " how many columns text is indented with the reindent operations (<< and >>) 
set autoindent                " copy indent from previous line
set smartindent               " does the right thing (mostly) in programs
set cindent                   " stricter rules for C programs

set textwidth=0               " disable auto line break

set backup                    " enable backing up file on open
set backupdir=/tmp            " path of backup file
set directory=/tmp            " path of swap file


" Set Solarized Theme
syntax enable
set background=dark
colorscheme solarized
