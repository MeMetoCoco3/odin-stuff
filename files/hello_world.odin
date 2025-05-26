#+feature dynamic-literals
// Looks like GO

package main

import "core:fmt"

main :: proc() {
	x, y: int
	x, y = 1, 2
	z := 3
	// We declare constants
	a :: 4
	b: int : 5

	some_array := []int{x, y, z, a, b}
	for i in 0 ..< len(some_array) {
		fmt.println(some_array[i])
	}

	#reverse for i in some_array {
		fmt.println(i)
	}

	some_map := map[int]int {
		1 = b,
		2 = x,
		4 = y,
		3 = a,
		5 = z,
	} 	// some_map := map[int]int{1=b,2=x,4=y,3=a,5=z}
	defer delete(some_map)
	for val, index in some_map {
		fmt.println(val, index)
	}

	new_value: int : 99
	for &value, index in some_array {
		value = new_value
		fmt.println(some_array[index])
	}

	switch arch := ODIN_ARCH; arch {
	case .i386, .wasm32, .arm32:
		fmt.println("32 bit")
	case .amd64, .wasm64p32, .arm64, .riscv64:
		when ODIN_ARCH == .arm64 {
			fmt.println("When is like if but with constants, it is evaluated at compile time.")
		}
		fmt.println("64 bit")
	case .Unknown:
		fmt.println("Unknown architecture")
	}
	// fmt.printf("[%d, %d, %d, %d, %d]\n", x, y, z, a, b)

}
