# TEXBOX
LaTex + vim = :fire:

## Funciones
| Comando Vim | Comando lua                                            | Descripción                                                                             |
|-------------|--------------------------------------------------------|-----------------------------------------------------------------------------------------|
| TXgetlabels | lua require'texbox.telescope_latex'.labels_telescope() | Lista de etiquetas. Al pulsar <CR> introduce la referencia de la etiqueta seleccionada. |
| TXaddlabels | lua require'texbox.latex'.add_labels()                 | Añade una etiqueta.                                                                     |
