package main

import sa "core:container/small_array"
import "core:fmt"

main :: proc() {
	arr: sa.Small_Array(1024, int)
	fmt.printfln("lenL %v", sa.len(arr))

	sa.append(&arr, 5)
	fmt.printfln("lenL %v", sa.len(arr))

	sa.append(&arr, 6)
	fmt.printfln("lenL %v", sa.len(arr))

	sa.unordered_remove(&arr, 0)
	fmt.printfln("arr[0]: %v", sa.get(arr, 0))
	fmt.printfln("lenL %v", sa.len(arr))

}
