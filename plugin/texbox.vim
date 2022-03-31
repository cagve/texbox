" TEXBOX VIM
if exists('g:loaded_texbox') | finish | endif

let g:loaded_texbox=1
let g:bib_file="/home/karu/Documents/Pdfs/Database/karubib.bib"

" Comandos
command! TXtelescopelabels lua require'texbox.telescope_latex'.labels_telescope()
command! TXaddbib lua require'texbox.bib'.run_telescope("1")
command! TXprintbib lua require'texbox.bib'.run_telescope("2")
command! TXaddlabels lua require'texbox.latex'.add_labels()
command! TXextractsection lua require'texbox.latex'.extract_section()
command! TXnewcommand lua require'texbox.latex'.new_command()
command! TXaddconceal lua require'texbox.latex'.add_conceal()
command! TXtelescopecommands lua require'texbox.telescope_latex'.telescope_new_commands()

