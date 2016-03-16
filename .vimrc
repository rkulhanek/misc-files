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

" Disable screen flashing on error by making all bells visual, then making them do nothing. (At least, I think that's how this works.)
set visualbell
set t_vb=

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
noremap <S-Up> <Nop>
noremap <S-Down> <Nop>

" Possible security issues, and I never use them anyway
set modelines=0
set nomodeline

" A few of these actually do things in regular vim, but they aren't interesting things.
" So make them work like gedit so things work when I forget which editor I'm in.

"TODO: Maybe only remap <C-V> in insert mode.  Or make <A-V> do visual block selection instead
"nnoremap <C-V> "+gP
"vnoremap <C-X> "+x"
"vnoremap <C-C> "+y
"if has('gui_running')
	" If running from a terminal, I want to be able to get back to the command
	" line.  But for gvim, that's useless and I'd rather have increased
	" compatability with e.g. gedit
"	nnoremap <C-Z> u
"endif
" But it's fine if I need to go to normal mode to do so.  And in insert mode,
" it's nice to have a quick undo command
inoremap <C-Z> <ESC>ui
nnoremap <SPACE> :noh<CR>

" 0 is the default vi yank register.  * is the 'highlighted text with mouse (or visual mode)' register.  + is the select 'copy' from a menu register
set mouse=a
nnoremap <MiddleMouse> :set paste<CR>"*p<Esc>l:set nopaste<CR>
inoremap <MiddleMouse> <Esc>:set paste<CR>"*p<Esc>l:set nopaste<CR>i

noremap <2-MiddleMouse> <Nop>
noremap <3-MiddleMouse> <Nop>
noremap <4-MiddleMouse> <Nop>

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

syntax manual

function FileSize()
	let b:filesize = getfsize(expand("<afile>"))
	if b:filesize > 1024 * 1024 * 10 || -2 == b:filesize
		let b:filesize = "large"
		set syntax=OFF
	else
		let b:filesize = "small"
		if "" != &filetype
			set syntax=ON
		endif
	endif
endfunction

function TextFile()
	if "small" == b:filesize
		setlocal textwidth=70 spell spelllang=en_us
	endif
endfunction

autocmd BufRead,BufNewFile * call FileSize()
autocmd BufRead,BufNewFile *.txt,*.tex,*.notes call TextFile()

" Make ctrl-a work like in bash. ctrl-e already does.
cnoremap <C-a> <Home>

