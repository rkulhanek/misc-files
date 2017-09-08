set hlsearch
set enc=utf-8
set fenc=utf-8
set termencoding=utf-8
set nocompatible
set autoindent
set tabstop=4
set shiftwidth=4
set copyindent
set t_Co=256
set number

" Disable screen flashing on error by making all bells visual, then making them do nothing. (At least, I think that's how this works.)
set visualbell
set t_vb=

" Syntax highlighting
function! Highlight()
	let g:syntax_cmd = "skip" " Keeps it from overriding my color scheme with the defaults
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
	hi texMathZoneV cterm=bold gui=bold
	hi link texMathZoneW texMathZoneV
	hi link texMathZoneX texMathZoneV
	hi link texMathZoneY texMathZoneV
	hi texMathOper ctermfg=blue

	hi htmlH1 ctermfg=blue guifg=blue gui=bold

	hi DiffAdd cterm=bold ctermfg=white ctermbg=DarkBlue gui=none guifg=bg guibg=Red
	hi DiffDelete cterm=bold ctermfg=white ctermbg=DarkBlue gui=none guifg=bg guibg=Red
	hi DiffChange cterm=bold ctermfg=white ctermbg=DarkBlue gui=none guifg=bg guibg=Red
	hi DiffText cterm=bold ctermfg=white ctermbg=Red gui=none guifg=bg guibg=Red

	hi clear SpellBad
	hi SpellBad cterm=underline gui=undercurl ctermfg=red guisp=red
	"hi SpellCap cterm=bold ctermbg=black gui=undercurl ctermfg=blue
	"hi SpellLocal cterm=bold ctermbg=black gui=undercurl ctermfg=blue
	hi SpellCap ctermbg=black ctermfg=white
	hi SpellLocal ctermbg=black ctermfg=white
endfunction

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
" If +xterm_clipboard isn't compiled in, this won't work right over ssh. (vim-gtk package has it)
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

function! MakeTex()
	tabnew
	make
	"if 1 == line('$') && '' == getline(1)
		q
	"endif
endfunction

nnoremap <F12> :call MakeTex()<CR>

" Uncomment when debugging
"noremap <F10> :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<' . synIDattr(synID(line("."),col("."),0),"name") . "> lo<" . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>

syntax manual

function! FileSize()
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

function! TextFile()
	if "small" == b:filesize
		setlocal spell spelllang=en_us
	endif
endfunction

function! SetFolds(usesyntax)
	if "small" == b:filesize
		" TODO: foldmethod should be indent for python and any other languages where the syntax file doesn't define folds.
		" Figure out how to grep the syntax files for "fold" from vimrc.
		if 0 == a:usesyntax
			setlocal foldmethod=indent
		else
			setlocal foldmethod=syntax
		endif
		
		set foldlevel=99
	endif
endfunction

function! Python()
	" This is modified from Jon Franklin's python_fn plugin.
	" TODO: Ideally, I want [[, and ]] to act as follows:
	" Define a scope to include the line that starts it, e.g. def foo():, if foo:, for foo in bar:
	" [[ jumps to the first line of the current scope
	" ]] jumps to the line *after* the last line of the current scope.  Or possibly to the last line itself.
	"
	" Exceptions:
	" If I'm on the first line of a scope and hit [[, it goes to the first line of the *previous* scope.

	" Go to a block boundary (-1: previous, 1: next)
	" Returns line number
	function! PythonBoB(line, direction)
		let ln = a:line
		let ind = indent(ln)
		let mark = ln
		let indent_valid = strlen(getline(ln))

		" If we jump backwards from the first line of a function of class scope, we override
		" the normal behavior and instead of jumping to the start of the scope, we jump to the
		" start of the *previous* scope.  And if we jump forward, we jump to the beginning of the next scope
		let re_def = '^\s*\(def\|class\) .*:\s*\(#.*\)*$'
		"let re = ':\s*$' " uncomment to make this behavior also kick in for if, for, etc.
		if (-1 != match(getline(a:line), re_def))
			if 1 == a:direction
				let n = search(re_def, 'W')
			else
				let n = search(re_def, 'Wb')
			endif
			if 0 == n
				let n = a:line "do nothing
			endif
			return n
		endif

		" We're inside the initial declarations, of the if __main__ bit.
		" Find the next class/def or EOF, respectively.
		if 0 == indent(a:line)
			let n = search(re_def, 'Wb')
			if 0 != n && -1 == a:direction
				return n " We're NOT at the beginning. We're at a blank line in the middle somewhere. Go to the previous class/def
			endif
			return search(re_def, 'W')
		endif

		" We're inside a scope.  Jump to beginning or end
		let ln = ln + a:direction
		while ((ln >= 1) && (ln <= line('$')))
			if (match(getline(ln), "^\\s*#") == -1)
				if (!indent_valid)
					let indent_valid = strlen(getline(ln))
					let ind = indent(ln)
					let mark = ln
				else
					if (strlen(getline(ln)))
						if (indent(ln) < ind)
							return mark
						endif
						let mark = ln
					endif
				endif
			endif
			let ln = ln + a:direction
		endwhile
	endfunction
	
	map  [[   :PBoB<CR>
	vmap [[   :<C-U>PBOB<CR>m'gv``
	map  ]]   :PEoB<CR>
	vmap ]]   :<C-U>PEoB<CR>m'gv``

	" TODO: Could I set % to work like ]] if the current line contains a trailing /: *$/ and [[ otherwise?

	:com! PBoB execute "normal ".PythonBoB(line('.'), -1)."G"
	:com! PEoB execute "normal ".PythonBoB(line('.'), 1)."G"
endfunction

function! MarkdownRegions()
    " $$ block math $$
    syn region math start=/\$\$/ end=/\$\$/
    " $ inline math $
    syn match math_block '\$[^$]\(\\.\|[^$]\)*\$'
    " BUG: $x_i$ _{ $x_i$ doesn't highlight the second x_i.
    "      $x_i$ _{ $$x_i$$ considers the block to start after
    "      the *second* $$. Closing the { doesn't help.

    " ``` code blocks in github-flavored markdown ```
    syn region github_code_block start='```' end='```'

    hi link math texMathZoneY
    hi link math_block texMathZoneX
    hi github_code_block cterm=bold
endfunction

autocmd BufRead,BufNewFile * call FileSize()
autocmd BufRead,BufNewFile *.txt,*.tex,*.notes,*.md call TextFile()
autocmd BufRead,BufNewFile * call SetFolds(1)
autocmd BufRead,BufNewFile *.py call SetFolds(0)
autocmd BufRead,BufNewFile *.py call Python()
autocmd BufRead,BufNewFile *.lua call SetFolds(0)
autocmd BufRead,BufNewFile *.md call MarkdownRegions()

call Highlight()
syntax on

" Make ctrl-a work like in bash. ctrl-e already does.
cnoremap <C-a> <Home>

