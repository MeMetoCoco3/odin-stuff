package main

import "base:runtime"
import "core:fmt"

import "my_lib"

// We play with this contexxt because it is needed to call odin functions from proc "c"
custom_context: runtime.Context

callbank :: proc "c" (ts: my_lib.TestStruct) {
	context = custom_context
	fmt.println("WE ARE IN THEKALL BANK")

	fmt.println("AND, AM OUT")
}


main :: proc() {
	my_lib.set_callback(callbank)


	ts := my_lib.TestStruct{10, 1.5}

	my_lib.do_stuff(ts)

}
