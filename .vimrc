set hlsearch
set enc=utf-8
set fenc=utf-8
set termencoding=utf-8
set nocompatible
set autoindent
set tabstop=4
set shiftwidth=4
"set textwidth=120
set t_Co=256
syntax on
set number

hi Statement ctermfg=white
hi Delimiter ctermfg=white
hi Special ctermfg=white
hi PreProc ctermfg=white
hi Constant ctermfg=white
hi Search ctermfg=black ctermbg=yellow
hi Visual ctermfg=black ctermbg=white
hi Comment ctermfg=darkgreen
hi Type ctermfg=white
hi Identifier ctermfg=white
hi String ctermfg=blue

hi texStatement ctermfg=blue
hi texDelimiter ctermfg=blue
hi texBeginEnd ctermfg=blue
hi texSection ctermfg=blue
hi texDocType ctermfg=blue
hi texNewCmd ctermfg=blue
hi texSpecialChar ctermfg=blue

hi texInputFile ctermfg=white
hi texInputFileOpt ctermfg=white

hi texOption ctermfg=cyan
hi texTypeStyle ctermfg=cyan
hi texTypeSize ctermfg=cyan
hi texMathZoneV ctermfg=blue
hi texMathZoneW ctermfg=blue
hi texMathOper ctermfg=blue

hi DiffAdd cterm=bold ctermfg=white ctermbg=DarkBlue gui=none guifg=bg guibg=Red
hi DiffDelete cterm=bold ctermfg=white ctermbg=DarkBlue gui=none guifg=bg guibg=Red
hi DiffChange cterm=bold ctermfg=white ctermbg=DarkBlue gui=none guifg=bg guibg=Red
hi DiffText cterm=bold ctermfg=white ctermbg=Red gui=none guifg=bg guibg=Red

" Since I have never once used this feature intentionally and Pg(Up|Down) do the same thing...
map <S-Up> <Nop>
map <S-Down> <Nop>

set modelines=0

" A few of these actually do things in regular vim, but they aren't interesting things.  So make them work like gedit so things work when I forget which editor I'm in.
nmap <C-V> "+gP
imap <C-V> <ESC><C-V>i
vmap <C-X> "+x"
vmap <C-C> "+y
nmap <C-Z> u
imap <C-Z> <ESC>ui
