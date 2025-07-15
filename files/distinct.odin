package main

import "core:fmt"
my_intd :: distinct int
my_int :: int

main :: proc() {
	My_intd: my_intd = 1
	My_int: my_int = 1
	Int: int = 1
	fmt.println(My_int == Int) // GOOD!
	// fmt.println(My_intd == Int) // BAD 
	fmt.println(int(My_intd) == Int) // GOOD!
}
