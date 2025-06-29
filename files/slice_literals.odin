package main
import "core:fmt"

numbers: []int // SLICE

print_slice :: proc() {
	numbers = {1, 2, 3} // numbers point to slice literal allocated in stack of print_slice
	fmt.println(numbers)
	// that slice literal is dealocated now
}


main :: proc() {
	print_slice()
	fmt.println(numbers) // we try to access the slice that was dealocated

	// result: 
	// [1, 2, 3]
	// [1, 140720397232624, 1]
}
