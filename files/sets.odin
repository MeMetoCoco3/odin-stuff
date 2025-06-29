package main

import "core:fmt"
main :: proc() {

	set_of_names: map[string]struct {
	}

	set_of_names["Pontus"] = {} // this empty truct takes 0 bytes


	add_to_set(&set_of_names, "Carles")
	add_to_set(&set_of_names, "Alicuecano")

	for key in set_of_names {
		fmt.println(key)
	}

	delete_map(set_of_names)


}


add_to_set :: proc(s: ^map[$T]struct {
	}, v: T) {
	s[v] = {}
}
