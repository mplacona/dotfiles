 set nocompatible          " Be improved
 filetype off              " filetype detection[ON] plugin[ON] indent[ON]

 set t_Co=256              " enable 256-color mode.
 set number                " show line numbers
 set laststatus=2          " last window always has a statusline
 set nohlsearch            " Don't continue to highlight searched phrases.
 set incsearch             " But do highlight as you type your search.
 set ignorecase            " Make searches case-insensitive.
 set ruler                 " Always show info along bottom.
 set autoindent            " auto-indent
 set tabstop=4             " tab spacing
 set softtabstop=4         " unify
 set shiftwidth=4          " indent/outdent by 4 columns
 set shiftround            " always indent/outdent to the nearest tabstop
 set expandtab             " use spaces instead of tabs
 set smarttab              " use tabs at the start of a line, spaces elsewhere
 set nowrap                " don't wrap text

 set rtp+=~/.vim/bundle/vundle
 call vundle#rc()
 Bundle 'gmarik/vundle'
 Bundle "pangloss/vim-javascript"
 Bundle "digitaltoad/vim-jade"
 Bundle "scrooloose/nerdtree"
 Bundle 'scrooloose/syntastic'

 filetype plugin indent on     " required!

 let g:syntastic_enable_signs=1
 let g:syntastic_auto_jump=1
 let g:syntastic_stl_format = '[%E{Err: %fe #%e}%B{, }%W{Warn: %fw #%w}]'

 set statusline+=%#warningmsg#
 set statusline+=%{SyntasticStatuslineFlag()}
 set statusline+=%*

 :command NT NERDTree
