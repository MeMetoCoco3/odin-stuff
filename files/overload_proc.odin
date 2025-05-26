package main

import "core:fmt"
import "core:strconv"


bool_to_string :: proc(b: bool) -> (r: string) {
	r = "false"
	if b {
		r = "true"
	}
	return
}

int_to_string :: proc(n: int) -> (r: string) {
	buf := make([]u8, 32)
	r = strconv.itoa(buf, n)
	return
}


to_string :: proc {
	bool_to_string,
	int_to_string,
}


main :: proc() {
	b := false
	i := 500

	string_b := to_string(b)
	string_i := to_string(i)

	fmt.println(string_b, string_i)
}
