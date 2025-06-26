# odin-stuff


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


