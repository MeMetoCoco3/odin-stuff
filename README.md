# odin-stuff


## Handles are the better pointers
La memoria dinamica puede crecer, lo que significa que en ciertos momentos si guardamos un puntero y la memoria crece, esta referencia se pierda. Los Handles ayudan con esto.
Un handle es una referencia a la posicion en una HandlerBasedArray, y una referencia a la generacion, estos dos numeros identifican la entidad que hacen referencia.
La HBA tiene dos dynamic arrays, una con los valores que queremos guardar, y otra con handlers que apuntana  huecos vacios. Si podemos usar un hueco vacio lo usarmeos, y le sumaremos uno a la generacion, guardaremos el valor en la posicion que indica el handler, y, IMPORTANTE, el valor tambien guardara el propio handler. De esta forma podremos comparar este handler con referencias fuera de la HBA para identificar si el valor que hay es el que buscamos.
La existencia de handles va pareja con la idea de no almacenar pointers.
Otras cosas interesantes que ofrecen los handles son:
-  Los handles con indice 0 estan libres para usar.
-  Lista de free positions, que permite manipularlas con O(1).
-  Podemos mantener los handlers dentro de los systemas para tener mas control, respecto a donde esta nuestra memoria.
-  Si cogemos un puntero a un valor, y anadimos valores de tal manera que se realoc los valores del handler, el puntero que sacamos estara muerto.

Los problemas relacionados con este ultimo punto se solucionan si usamos fixed-size arrays o si creamos una nueva array con nuestras nuevas entidades y tras manipular todas nuestras entidades las añadimos.



ref= https://zylinski.se/posts/handle-based-arrays/
ref= https://floooh.github.io/2018/06/17/handles-vs-pointers.html

## Procedure Attributes
Son declaraciones que cambian el comportamiento de declaraciones en compile time.
```odin
@require_results
@(private = "file")
@(private="file", require_results)
@(default_calling_convention="c")
```

## Building
- Los bindings son programas que linkean librerias a otro idioma, definen los archivos a importar, y que funciones hacer publicas. En odin se utiliza la  calling convention = c cuando la libreria esta escrita en C, ya que odin siempre pasa el contexto automaticamente, lo cual haria que las funciones declaradas anteriormente, tengan la signature mal.
- Podemos aislar archivos a la hora de compilarlos para segun que sistemas de estas dos formas: 
    -  Añadiendo #+build linux or #+build !linux, para compilar exlusivamente o no hacerlo
    -  Sufijando los files con "_windows.odin", para compilar exlusivamente en windows.



## Arenas
En odin podemos usar 3 implementaciones definidas en:
- core:mem/
- core:mem/virtual
- base:runtime
Es general usaremos virtual, pero ciertas plataformas no permiten el uso de virtual memory, como WASM.
El declarado en runtime no deberia ser usado en otro lugar que en temp allocations, ya que usa virtual memory, haciendolo menos eficiente.

Cuando usamos memoria virtual significa que el os sabe que un bloque de memoria va a ser utilizado, y por lo tanto se reserva, pero, el programa no esta utilizando toda esta memoria, el uso de memoria de nuestro programa solo aumentara conforme reservemos memroria para nuestros datos. Si tenemos un bloque de 13 gigas y reservamos un u32, solo estaremos usando 4 bytes. 
```odin
    Arena :: struct {
        kind:                Arena_Kind,
        curr_block:          ^Memory_Block,

        total_used:          uint,
        total_reserved:      uint,

        default_commit_size: uint, // commit size <= reservation size
        minimum_block_size:  uint, // block size == total reservation

        temp_count:          uint,
        mutex:               sync.Mutex,
    }
```

### Diferentes tipos de Arena
```odin
    Arena_Kind :: enum uint {
        Growing = 0, // Chained memory blocks (singly linked list).
        Static  = 1, // Fixed reservation sized.
        Buffer  = 2, // Uses a fixed sized buffer.
    }

    arena : vmem.Arena
    err := vmem.arena_init_growing(&arena, 100*mem.Megabyte)
    err := vmem.arena_init_static(&arena, 100*mem.Megabyte)
    vmem.arena_destroy(&arena) 

    buf := make([]byte, 10*mem.Megabyte)
    err := vmem.arena_init_buffer(&arena, [:]buf)
    delete(buf)
```

- Growing: Usa blockes de memoria de el tamaño que pidamos, a partir de cierto momento, pedira al OS otro bloke para poder seguir reservando memoria una vez el primero este lleno, o una vez reservemos espacio mayor al que tenemos disponible en le bloque.
- Static: Es igual, pero este no va a reservar mas bloques si es necesario.
- Buffer: Igual que static, pero sin usar memoria virtual. TAMBIEN podemos darle una fixed array declarada en el stack. Para destruirlo usaremos delete en el buffer.


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
    break somefile.odin:321
Para poner un condicional:
    cond 1 someshit == whatever


