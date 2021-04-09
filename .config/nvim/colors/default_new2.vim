
hi clear Normal
set bg&

" Remove all existing highlighting and set the defaults.
hi clear

" Load the syntax highlighting defaults, if it's enabled.
if exists("syntax_on")
  syntax reset
endif

let colors_name = "default_new2"


hi Comment ctermfg=243
hi String term=bold cterm=bold ctermfg=65
"hi Number ctermfg=65
hi Pmenu ctermfg=none ctermbg=236

if !has('nvim')
    set cursorline
    set cursorlineopt=number
endif

highlight LineNR cterm=none ctermfg=240 ctermbg=none
highlight CursorLineNR cterm=bold ctermfg=255 ctermbg=none
