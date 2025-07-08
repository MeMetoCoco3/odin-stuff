package main
import "base:runtime"
import "core:fmt"
import "core:log"
import "core:math/rand"
import "core:os"

/*
main :: proc() {
		 // Injecting context into functions
	get_random_ints :: proc() -> []i32 {
		ints := make([]i32, 4096)

		for &v, i in ints {
			v = rand.int31()
		}
		return ints
	}


	context.allocator = context.temp_allocator // This line transforms allows to inject stuff in functions that may be out of our reach
	my_ints := get_random_ints()

	for i in my_ints {
		fmt.println(i)
	}


}

// Allows us to define what a failed assert does. a -> ! means that the function is espected to crash
assert_fail :: proc(prefix, message: string, loc := #caller_location) -> ! {
	fmt.printfln("Oh no, an assertion at line: %v", loc)
	fmt.println(message)
	runtime.trap()
}

main :: proc() {
	context.assertion_failure_proc = assert_fail
	number := 5
	assert(number == 7, "Number has wrong value")
}


*/
// FILE LOGGER
//
// main :: proc() {
// 	mode: int = 0
// 	when ODIN_OS == .Linux || ODIN_OS == .Darwin {
// 		mode = os.S_IRUSR | os.S_IWUSR | os.S_IRGRP | os.S_IROTH
// 	}
//
// 	logh, logh_err := os.open("log.txt", (os.O_CREATE | os.O_TRUNC | os.O_RDWR), mode)
//
// 	// Redirects print to file
// 	if logh_err == os.ERROR_NONE {
// 		os.stdout = logh
// 		os.stderr = logh
// 	}
//
// 	// Creates file logger or console logger
// 	logger :=
// 		logh_err == os.ERROR_NONE ? log.create_file_logger(logh) : log.create_console_logger()
// 	context.logger = logger
//
// 	log.info("First line")
// 	log.info("Second line")
// 	log.info("Third line")
// 	fmt.println("IM PRINTLN")
// 	log.info("Fourth line")
// 	log.error("Some error happend")
//
// 	log.fatal("COLLISION SYSTEM BROKE")
// 	if logh_err == os.ERROR_NONE {
// 		log.destroy_file_logger(logger)
// 	} else {
// 		log.destroy_console_logger(logger)
// 	}
//
// }


// We seed a random generator and use it as default
main :: proc() {
	random_state := rand.create(40)
	context.random_generator = runtime.default_random_generator((&random_state))
	fmt.println(rand.int_max(100))
}
