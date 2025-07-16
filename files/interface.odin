package main

import "core:fmt"
import inter "interface"

print_message :: proc(msg: string) {
	fmt.println(msg)
}

end_of_work :: proc() {
	fmt.println("Let's all go home")
}

main :: proc() {
	init_interface()
	inter.do_work()
}

init_interface :: proc() {
	interface := inter.Printer_Interface {
		func_a = print_message,
		func_b = end_of_work,
	}
	inter.interface = interface
}
