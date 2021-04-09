" returns the palette index to approximate the given R/G/B color levels
fun! s:color(r, g, b)
  " map greys directly (see xterm's 256colres.pl)
  if &t_Co == 256 && a:r == a:g && a:g == a:b && a:r > 3 && a:r < 243
    return (a:r - 8) / 10 + 232
  endif

  " get the closest grey
  let l:gx = s:grey_number(a:r)
  let l:gy = s:grey_number(a:g)
  let l:gz = s:grey_number(a:b)

  " get the closest color
  let l:x = s:rgb_number(a:r)
  let l:y = s:rgb_number(a:g)
  let l:z = s:rgb_number(a:b)

  if l:gx == l:gy && l:gy == l:gz
    " there are two possibilities
    let l:dgr = s:grey_level(l:gx) - a:r
    let l:dgg = s:grey_level(l:gy) - a:g
    let l:dgb = s:grey_level(l:gz) - a:b
    let l:dgrey = (l:dgr * l:dgr) + (l:dgg * l:dgg) + (l:dgb * l:dgb)
    let l:dr = s:rgb_level(l:gx) - a:r
    let l:dg = s:rgb_level(l:gy) - a:g
    let l:db = s:rgb_level(l:gz) - a:b
    let l:drgb = (l:dr * l:dr) + (l:dg * l:dg) + (l:db * l:db)
    if l:dgrey < l:drgb
      " use the grey
      return s:grey_color(l:gx)
    else
      " use the color
      return s:rgb_color(l:x, l:y, l:z)
    endif
  else
    " only one possibility
    return s:rgb_color(l:x, l:y, l:z)
  endif
endfun

fun! s:is_empty_or_none(str)
  return empty(a:str) || a:str ==? "NONE"
endfun

" returns the palette index to approximate the 'rrggbb' hex string
fun! s:rgb(rgb)
  if s:is_empty_or_none(a:rgb)
    return "NONE"
  endif
  let l:r = ("0x" . strpart(a:rgb, 0, 2)) + 0
  let l:g = ("0x" . strpart(a:rgb, 2, 2)) + 0
  let l:b = ("0x" . strpart(a:rgb, 4, 2)) + 0
  return s:color(l:r, l:g, l:b)
endfun

fun! s:prefix_highlight_value_with(prefix, color)
  if s:is_empty_or_none(a:color)
    return "NONE"
  else
    return a:prefix . a:color
  endif
endfun

fun! s:remove_italic_attr(attr)
  let l:attr = join(filter(split(a:attr, ","), "v:val !=? 'italic'"), ",")
  if empty(l:attr)
    let l:attr = "NONE"
  endif
  return l:attr
endfun

" sets the highlighting for the given group
fun! s:X(group, fg, bg, attr, lcfg, lcbg)
  if s:low_color
    let l:cmd = "hi ".a:group.
    \ " ctermfg=".s:prefix_highlight_value_with("", a:lcfg).
    \ " ctermbg=".s:prefix_highlight_value_with("", a:lcbg)
  else
    let l:cmd = "hi ".a:group.
    \ " guifg=".s:prefix_highlight_value_with("#", a:fg).
    \ " guibg=".s:prefix_highlight_value_with("#", a:bg)
    if !s:true_color
      let l:cmd = l:cmd.
      \ " ctermfg=".s:rgb(a:fg).
      \ " ctermbg=".s:rgb(a:bg)
    endif
  endif

  let l:attr = s:prefix_highlight_value_with("", a:attr)

  if exists("g:jellybeans_use_term_italics") && g:jellybeans_use_term_italics
    let l:cterm_attr = l:attr
  else
    let l:cterm_attr = s:remove_italic_attr(l:attr)
  endif

  if !exists("g:jellybeans_use_gui_italics") || g:jellybeans_use_gui_italics
    let l:gui_attr = l:attr
  else
    let l:gui_attr = s:remove_italic_attr(l:attr)
  endif

  let l:cmd = l:cmd." gui=".l:gui_attr." cterm=".l:cterm_attr
  exec l:cmd
endfun
" }}}

call s:X("Normal","e8e8d3",s:background_color,"","White","")
set background=dark

call s:X("CursorLine","","1c1c1c","","",s:termBlack)
call s:X("CursorColumn","","1c1c1c","","",s:termBlack)

" Some of Terminal.app's default themes have a cursor color
" too close to Jellybeans' preferred MatchParen background
" color to be easily distinguishable. Other terminals tend
" to use a brighter cursor color.
"
" Use a more distinct color in Terminal.app, and also in
" low-color terminals if the preferred background color is
" not available.
if !has('gui_running') && $TERM_PROGRAM == "Apple_Terminal"
    let s:matchParenGuiFg = "dd0093"
    let s:matchParenGuiBg = "000000"
else
    let s:matchParenGuiFg = "ffffff"
    let s:matchParenGuiBg = "556779"
endif
if s:termBlack != "Black"
    let s:matchParenTermFg = "Magenta"
    let s:matchParenTermBg = ""
else
    let s:matchParenTermFg = ""
    let s:matchParenTermBg = s:termBlack
endif
call s:X("Comment","888888","","italic","Grey","")
call s:X("String","d29968","","","Green","")
" Debugger.vim

call s:X("DbgCurrent","DEEBFE","345FA8","","White","DarkBlue")
call s:X("DbgBreakPt","","4F0037","","","DarkMagenta")

" vim-indent-guides

if !exists("g:indent_guides_auto_colors")
  let g:indent_guides_auto_colors = 0
endif
call s:X("IndentGuidesOdd","","232323","","","")
call s:X("IndentGuidesEven","","1b1b1b","","","")

" Plugins, etc.

hi! link TagListFileName Directory
call s:X("PreciseJumpTarget","B9ED67","405026","","White","Green")

" Manual overrides for 256-color terminals. Dark colors auto-map badly.
if !s:low_color
  hi StatusLineNC ctermbg=235
  hi Folded ctermbg=236
  hi DiffText ctermfg=81
  hi DbgBreakPt ctermbg=53
  hi IndentGuidesOdd ctermbg=235
  hi IndentGuidesEven ctermbg=234
endif

if !empty("s:overrides")
  fun! s:current_attr(group)
    let l:synid = synIDtrans(hlID(a:group))
    let l:attrs = []
    for l:attr in ["bold", "italic", "reverse", "standout", "underline", "undercurl"]
      if synIDattr(l:synid, l:attr, "gui") == 1
        call add(l:attrs, l:attr)
      endif
    endfor
    return join(l:attrs, ",")
  endfun
  fun! s:current_color(group, what, mode)
    let l:color = synIDattr(synIDtrans(hlID(a:group)), a:what, a:mode)
    if l:color == -1
      return ""
    else
      return substitute(l:color, "^#", "", "")
    endif
  endfun
  fun! s:load_color_def(group, def)
    call s:X(a:group, get(a:def, "guifg", s:current_color(a:group, "fg", "gui")),
    \                 get(a:def, "guibg", s:current_color(a:group, "bg", "gui")),
    \                 get(a:def, "attr", s:current_attr(a:group)),
    \                 get(a:def, "ctermfg", s:current_color(a:group, "fg", "cterm")),
    \                 get(a:def, "ctermbg", s:current_color(a:group, "bg", "cterm")))
    if !s:low_color
      for l:prop in ["ctermfg", "ctermbg"]
        let l:override_key = "256".l:prop
        if has_key(a:def, l:override_key)
          exec "hi ".a:group." ".l:prop."=".a:def[l:override_key]
        endif
      endfor
    endif
  endfun
  fun! s:load_colors(defs)
    for [l:group, l:def] in items(a:defs)
      if l:group == "background"
        call s:load_color_def("LineNr", l:def)
        call s:load_color_def("NonText", l:def)
        call s:load_color_def("Normal", l:def)
      else
        call s:load_color_def(l:group, l:def)
      endif
      unlet l:group
      unlet l:def
    endfor
  endfun
  call s:load_colors(s:overrides)
  delf s:load_colors
  delf s:load_color_def
  delf s:current_color
  delf s:current_attr
endif

" delete functions {{{
delf s:X
delf s:remove_italic_attr
delf s:prefix_highlight_value_with
delf s:rgb
delf s:is_empty_or_none
delf s:color
delf s:rgb_color
delf s:rgb_level
delf s:rgb_number
delf s:grey_color
delf s:grey_level
delf s:grey_number
" }}}
