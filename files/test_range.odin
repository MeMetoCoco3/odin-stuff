package main
import "core:fmt"

main :: proc() {
	j := 10


	for i in 0 ..< j {
		fmt.println(i)
		j -= 1
	}
}
