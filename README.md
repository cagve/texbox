# TEXBOX
LaTex + vim = :fire:

## Funciones
| Comando Vim      | Descripción                                                                             |
|------------------|-----------------------------------------------------------------------------------------|
| TXgetlabels      | Lista de etiquetas. Al pulsar <CR> introduce la referencia de la etiqueta seleccionada. |
| TXaddlabels      | Añade una etiqueta.                                                                     |
| TXextractsection | Extrae la sección seleccionada en un documento nuevo.                                   |
| TXnewcommand     | Crea un nuevo comando en el preambulo


### Extraer secciones
Para mejorar esta función pueden implementarse:
1. Que el título del documento sea el de la sección
2. Problema con bibliografías. Se debería eliminar o algo
3. Problemas con imágenes. Se debería eliminar o algo
4. Problemas con referencias cruzadas. Se debería eliminar o algo

## TODO (problemas)
1. Archivos que estén separados.
2. Mejorar como obtener el preambulo función `lua require'texbox'.get_preamble()`.
3. El archivo main con todas las funciones se debe mejorar.
