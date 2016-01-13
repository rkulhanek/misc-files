set hlsearch
set enc=utf-8
set fenc=utf-8
set termencoding=utf-8
set nocompatible
set autoindent
set tabstop=4
set shiftwidth=4
set t_Co=256
syntax on
set number

" Syntax highlighting
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
hi Normal ctermfg=white
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

hi clear SpellBad
hi SpellBad cterm=underline gui=undercurl ctermfg=red guisp=red

" Since I have never once used this feature intentionally and Pg(Up|Down) do the same thing...
map <S-Up> <Nop>
map <S-Down> <Nop>

" Possible security issues, and I never use them anyway
set modelines=0
set nomodeline

" A few of these actually do things in regular vim, but they aren't interesting things.
" So make them work like gedit so things work when I forget which editor I'm in.

"TODO: Maybe only remap <C-V> in insert mode.  Or make <A-V> do visual block selection instead
nmap <C-V> "+gP
vmap <C-X> "+x"
vmap <C-C> "+y
if has('gui_running')
	" If running from a terminal, I want to be able to get back to the command
	" line.  But for gvim, that's useless and I'd rather have increased
	" compatability with e.g. gedit
	nmap <C-Z> u
endif
" But it's fine if I need to go to normal mode to do so.  And in insert mode,
" it's nice to have a quick undo command
imap <C-Z> <ESC>ui
nmap <SPACE> :noh<CR>

" Function keys switch between tabs.  F1 is the only one that normally does
" something, and I can type :help well enough without it.
nnoremap <F1> 1gt
nnoremap <F2> 2gt
nnoremap <F3> 3gt
nnoremap <F4> 4gt
nnoremap <F5> 5gt
nnoremap <F6> 6gt
nnoremap <F7> 7gt
nnoremap <F8> 8gt
nnoremap <F9> 9gt
nnoremap <F10> 10gt

nnoremap <F12> :tabnew<CR>:make<CR>

let g:LargeFile = 1024 * 1024 * 10
autocmd BufReadPre * let f=getfsize(expand("<afile>")) | if f > g:LargeFile || -2 == f | call LargeFile() | else | call SmallFile() | endif

function SmallFile()
	" Automatic linebreaks and spellchecking for text files but not code
	autocmd BufRead,BufNewFile *.txt,*.tex,*.notes setlocal textwidth=70
	autocmd BufRead,BufNewFile *.txt,*.tex,*.notes setlocal spell spelllang=en_us
endfunction

function LargeFile()
	syntax off
endfunction

" Make ctrl-a work like in bash. ctrl-e already does.
cnoremap <C-a> <Home>

