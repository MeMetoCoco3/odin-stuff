package main

import "core:fmt"

main :: proc() {
	j := 1
	defer fmt.println(j)
	j += 1
	fmt.println(j)
}
