package main

import "core:fmt"

main :: proc() {

	arr := make([dynamic]int, 0, 6)

	append(&arr, 1)
	fmt.println(arr)
	unordered_remove(&arr, 0)
	fmt.println(arr)
	append(&arr, 5)
	fmt.println(arr)
}
