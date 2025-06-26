package main

box :: enum {
	small,
	medium,
	big,
}


boxsize := [box]int {
	.small  = 2,
	.medium = 4,
	.big    = 70,
}

import "core:fmt"

main :: proc() {
	fmt.println(boxsize[.big])

}
