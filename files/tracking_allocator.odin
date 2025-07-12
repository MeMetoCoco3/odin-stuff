package main
import "core:fmt"
import "core:math/rand"
import "core:mem"
import sdl "vendor:sdl3"


main :: proc() {
	ok := sdl.Init({.VIDEO});assert(ok)
	window := sdl.CreateWindow("Tracking_Allocator", 800, 800, {.FULLSCREEN});assert(window != nil)


	when ODIN_DEBUG { 	// Remember, when does not create a scope
		track: mem.Tracking_Allocator
		mem.tracking_allocator_init(&track, context.allocator)
		context.allocator = mem.tracking_allocator(&track)
		// j := "123"

		defer {
			if len(track.allocation_map) > 0 {
				for _, entry in track.allocation_map {
					fmt.printfln("%v leaked %v bytes", entry.location, entry.size)
				}
			}

			mem.tracking_allocator_destroy(&track)
		}
	}
	// fmt.println(j)

	r := rand.create(32)
	context.random_generator = rand.default_random_generator(&r)

	lots_of_nums: [dynamic]int

	main_loop: for {
		ev: sdl.Event
		for sdl.PollEvent(&ev) {
			#partial switch ev.type {
			case .KEY_DOWN:
				if ev.key.scancode == .F1 do break main_loop
			}
		}

		three_nums := [3]^int {
			some_func_that_allocates(),
			some_func_that_allocates(),
			some_func_that_allocates(),
		}
		for num in three_nums {
			if num^ != 3 {
				append(&lots_of_nums, num^)
			} else {
				free(num)
			}
		}

	}

	sdl.DestroyWindow(window)
	sdl.Quit()
}


some_func_that_allocates :: proc(loc := #caller_location) -> ^int {
	num := new(int, loc = loc)
	num^ = rand.int_max(3)
	return num
}
