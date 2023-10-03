" TEXBOX VIM
if exists('g:loaded_texbox') | finish | endif

let g:loaded_texbox=1
let g:bib_file="/home/caguiler/Phd/Database/Bib/karubib.bib"

command! TXtelescopelabels lua require'texbox.telescope'.telescope_labels()
command! TXtelescopeheadings lua require'texbox.telescope'.telescope_headings()
command! TXtelescopecommands lua require'texbox.telescope'.telescope_newcommands()
command! TXaddbib lua require'texbox.telescope'.telescope_bib()
command! TXextractsection lua require'texbox.texbox'.extract_section()
command! TXnewcommand lua require'texbox.texbox'.newcommand_from_yank()
command! TXnewconceal lua require'texbox.texbox'.new_conceal_from_yank()
