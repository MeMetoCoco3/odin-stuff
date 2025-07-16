package interface

import "core:fmt"
// this line allows to import from main, which woud be not possible
// import ".."
Printer_Interface :: struct {
	func_a: proc(msg: string),
	func_b: proc(),
	func_c: proc(n: int),
}

interface: Printer_Interface

do_work :: proc() {
	fmt.println("First")

	if interface.func_a != nil {
		interface.func_a("Middle")
	}

	fmt.println("Last")

	if interface.func_b != nil {
		interface.func_b()
	}
	if interface.func_c != nil {
		interface.func_c(5)
	}

}
