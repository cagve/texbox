" TEXBOX VIM
if exists('g:loaded_texbox') | finish | endif

let g:loaded_texbox=1
" Comandos
command! TXtelescopelabels lua require'texbox'.telescope_labels()
command! TXaddlabels lua require'texbox'.add_labels()
command! TXextractsection lua require'texbox'.extract_section()
