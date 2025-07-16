package main
// #+private file  Makes the content of the file inaccessible to the rest of the package.
import "core:fmt"
import inter "interface"

// This are called procedure attributes.
// @(private = "package")
@(private = "file")
jamon: inter.Printer_Interface

print_message :: proc(msg: string) {
	fmt.println(msg)
}

end_of_work :: proc() {
	fmt.println("Let's all go home")
}

count_till :: proc(n: int) {
	for i in 0 ..< n {
		fmt.print(i)
	}
}

main :: proc() {
	init_interface()
	inter.do_work()
}

init_interface :: proc() {
	interface := inter.Printer_Interface {
		func_a = print_message,
		func_b = end_of_work,
		func_c = count_till,
	}
	inter.interface = interface
}
