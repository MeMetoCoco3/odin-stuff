package main
import "core:fmt"

list := [?]int{0, 1, 2, 3, 4, 5, 6, 7}


main :: proc() {
	for i in (len(list) - 1) ..= 0 {
		fmt.println(list[i])
		fmt.println(i)
	}

	for i in 0 ..< len(list) {
		fmt.println(list[i])
		fmt.println(i)
	}

}
