scriptencoding utf-8

" Copyright (c) 2018 Filip Szymański. All rights reserved.
" Use of this source code is governed by an MIT license that can be
" found in the LICENSE file.

let s:keep_cpo = &cpoptions
set cpoptions&vim

function! s:error_type(type, number) abort
  if a:type ==? 'W'
    let l:msg = ' warning'
  elseif a:type ==? 'I'
    let l:msg = ' info'
  elseif a:type ==? 'E' || (a:type ==# "\0" && a:number > 0)
    let l:msg = ' error'
  elseif a:type ==# "\0" || a:type ==# "\1"
    let l:msg = ''
  else
    let l:msg = ' ' . a:type
  endif

  if a:number <= 0
    return l:msg
  endif

  return printf('%s %3d', l:msg, a:number)
endfunction

function! s:format_error(item) abort
  return (a:item.bufnr ? bufname(a:item.bufnr) : '')
        \ . '|' . (a:item.lnum  ? a:item.lnum : '')
        \ . (a:item.col ? ' col ' . a:item.col : '')
        \ . s:error_type(a:item.type, a:item.nr)
        \ . '|' . substitute(a:item.text, '\v^\s*', ' ', '')
endfunction

function! s:get_quickfix_errors() abort
  return map(getqflist(), 's:format_error(v:val)')
endfunction

function! s:error_handler(err) abort
  let l:match = matchlist(a:err, '\v^([^|]+)\|(\d+)\scol\s(\d+).*\|')[1:3]
  if empty(l:match)
    return
  endif

  execute 'buffer' l:match[0]
  call cursor(l:match[1], l:match[2])
  normal! zvzz
endfunction

function! fzf_quickfix#run() abort
  let l:opts = {
        \ 'source': s:get_quickfix_errors(),
        \ 'sink': function('s:error_handler'),
        \ 'options': '--prompt="Error> "'
        \ }
  call extend(l:opts, get(g:, 'fzf_layout', {'down': '~40%'}))
  call fzf#run(l:opts)
endfunction

let &cpoptions = s:keep_cpo
unlet s:keep_cpo
