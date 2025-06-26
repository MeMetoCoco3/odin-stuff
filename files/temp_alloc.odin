package main

import "core:fmt"
import "core:math/rand"
// Solemos usar temp_allocator cuando necesitamos una dynamic array para correr algun algoritmo de forma rapida y que no nos interesa que persista.
main :: proc() {
	numbers := make([dynamic]int, context.temp_allocator)

	for i in 0 ..< 100 {
		append(&numbers, rand.int_max(10))
	}

	for n, i in numbers {
		if n > 4 {
			fmt.printfln("%v: %v", i, n)
		}
	}

	free_all(context.temp_allocator)
}
