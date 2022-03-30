# TEXBOX
LaTex + vim = :fire:

## Funciones
| Comando Vim      | Descripción                                                                             |
|------------------|-----------------------------------------------------------------------------------------|
| TXgetlabels      | Lista de etiquetas. Al pulsar <CR> introduce la referencia de la etiqueta seleccionada. |
| TXaddlabels      | Añade una etiqueta.                                                                     |
| TXextractsection | Extrae la sección seleccionada en un documento nuevo.                                   |
| TXnewcommand     | Crea un nuevo comando en el preambulo y te pregunta si quieres crear un conceal         |
| TXaddconceal     | Crea un nuevo conceal                                                                   |


### Extraer secciones
Para mejorar esta función pueden implementarse:
1. Que el título del documento sea el de la sección
2. Problema con bibliografías. Se debería eliminar o algo
3. Problemas con imágenes. Se debería eliminar o algo
4. Problemas con referencias cruzadas. Se debería eliminar o algo

## TODO (problemas)
1. [New] Extract visual text
2. [FIX] Add_conceal >> Cuando el comando que quiero crear es un \word no detecta ninguno porque tendría que trasformarse en \\word.
3. [F:Extract section] Archivos que estén separados.
