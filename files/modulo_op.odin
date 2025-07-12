package main
import "core:fmt"
import "core:math"


main :: proc() {
	index_pos := 5
	fmt.println(index_pos % 10)
	fmt.println(math.mod(f16(index_pos), f16(10)))

	index_neg := -1
	fmt.println(index_neg % 10)
	fmt.println(math.mod(f16(index_neg), f16(10)))


}
