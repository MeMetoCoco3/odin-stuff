package main

import "core:fmt"

main :: proc() {
	arr: [dynamic]int //Allocation happens at the first append
	// We can also arr:= make([dynamic]int, 0, 1024), and allocation happens instantly with 0 length and 1024 capacity
	append(&arr, 6)
	fmt.printfln("Len: %v, Cap: %v, arr[0]: %v", len(arr), cap(arr), arr[0])

	for i in 0 ..< 7 {
		append(&arr, i)
	}

	fmt.println("\nAfter 7 more appends:")
	fmt.println("Capacity:", cap(arr))
	fmt.println("Length:", len(arr))

	append(&arr, 6)
	fmt.println("\nAfter 1 more append:")
	fmt.println("Capacity:", cap(arr))
	fmt.println("Length:", len(arr))

	// // DEALOCATES MEMORY
	// delete(arr)
	// fmt.println("\nAfter DELETE:")
	// fmt.println("Capacity:", cap(arr))
	// fmt.println("Length:", len(arr))
	//
	// // SETS LENGTH TO 0
	// clear(&arr)
	// fmt.println("\nAfter CLEAR:")
	// fmt.println("Capacity:", cap(arr))
	// fmt.println("Length:", len(arr))


	unordered_remove(&arr, 4) // DOES WHAT I DO, COPY LAST TO INDEX, REDUCE LENGTH
	// ordered_remove(&arr, 4) // Copiesfrom index+1 till the end on top of index

}
