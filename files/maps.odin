package main
import "core:fmt"

main :: proc() {

	some_map: map[string]int
	defer delete(some_map)

	some_map["karl"] = 1
	some_map["crypto"] = 2

	count := 0
	for ("karl" in some_map) { 	// We also have not_in
		fmt.println(count)
		fmt.println(some_map["karl"])
		count += 1
		if count == 6 {
			delete_key(&some_map, "karl")
		}
	}


}
