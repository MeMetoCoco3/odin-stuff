# odin-stuff


## Custom iterators
Para declarar un custo iterator necesitamos
- Una estructura de datos que contenga un indice y la array que vamos a loopear, esta estructura la llamaremos ITERADOR.
- Una funcion que reciba un ITERADOR y devuelva 3 cosas:
    - El valor que queremos que el iterator devuelva.
    - Un segundo valor que queremos que el iterator devuelva, por ejemplo un indice.
    - La condicion que permite al iterador devolver el valor.
Lo que devuelva esta funcion sera lo que vamos a iterar en nuestro for loop.
Podemos hacer que nuestro iterator permita modificar los valores si el valor que devolvemos es un puntero a la array que estamos trabajando.

## Odin inmutable references
En odin cada argumento de mas de 16 bits se pasa como referencia inmutable, asi que tampoco nos calentemos la cabeza con optimizar pasando punteros en lugar de valores.

## Slices y arrays
Podemos hacer nuestras funciones mas universales usando slices como parametros, ya que cada array puede ser leida como uno.
El unico caso en el que mejor pasar un puntero al contenedor en lugar de un slice es cuando vayamos a utilizar append, ya que no podemos pasar un slice a append.

## Slice literals
Son slices cuya memoria es suya, y no de otra array, se localizan en el stack y  se suelen declarar something = {a,b,c}   o podemos pasarlos directamente a funciones print({a,b,c}), pero cuidao!! Mirar ejercicio*.

## Debugging stuff
Para compilar el archivo con simbolos para debuggearlo:
    odin build .file -file -out:file -o:none -debug
Para chekear los simbolos:
    info functions
    info variables
    info locals
Para poner un breakpoint:
    break main::func
Para poner un condicional:
    cond 1 someshit == whatever


