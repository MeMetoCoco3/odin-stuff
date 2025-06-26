package main

import "core:fmt"

MAX_ELEMENTS :: 100

MyArray :: struct {
	data:  [MAX_ELEMENTS]int,
	count: int,
}

add_element :: proc(arr: ^MyArray, value: int) {
	if arr.count < MAX_ELEMENTS {
		arr.data[arr.count] = value
		arr.count += 1
	} else {
		fmt.println("Array is full!")
	}
}

main :: proc() {
	my_array := MyArray{}
	for i in 0 ..< 100 {
		add_element(&my_array, 10 * my_array.count)
		add_element(&my_array, 20 * my_array.count)
		add_element(&my_array, 30 * my_array.count)
	}

	for i in 0 ..< my_array.count {
		fmt.printf("Element %d: %d\n", i, my_array.data[i])
	}
}

breakpoint :: proc() {
 asm volatile ("int3")
}
