" TEXBOX VIM
if exists('g:loaded_texbox') | finish | endif

let g:loaded_texbox=1
" Comandos
command! TXtelescopelabels lua require'texbox.latex'.labels_telescope()
command! TXaddlabels lua require'texbox.latex'.add_labels()
command! TXextractsection lua require'texbox'.extract_section()
command! TXnewcommand lua require'texbox.latex'.new_command()
command! TXaddconceal lua require'texbox.latex'.add_conceal()

