" in plugin/whid.vim
if exists('g:loaded_switcheroo') | finish | endif " prevent loading file twice

let s:save_cpo = &cpo " save user coptions
set cpo&vim " reset them to defaults

hi def link WhidHeader      Number
hi def link WhidSubHeader   Identifier

" command to run our plugin
command! Switcheroo lua require('switcheroo').switcheroo()

let &cpo = s:save_cpo " and restore after
unlet s:save_cpo

let g:loaded_switcheroo = 1
