" TEXBOX VIM
if exists('g:loaded_texbox') | finish | endif

let g:loaded_texbox=1
" Comandos
command! TXgetlabels lua require'texbox.telescope_latex'.labels_telescope()
command! TXaddlabels lua require'texbox.latex'.add_labels()
