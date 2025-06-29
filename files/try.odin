package main
import "core:fmt"

aligned_vectors :: proc(vectors: ..Vector2) -> bool {
	aligned_x := true
	aligned_y := true
	fmt.println(vectors[0])
	for i in 1 ..< len(vectors) {
		fmt.println(vectors[1])
		prev := vectors[i - 1]
		curr := vectors[i]

		if prev.x != curr.x {
			aligned_x = false
		}
		if prev.y != curr.y {
			aligned_y = false
		}
	}
	return aligned_x || aligned_y
}
Vector2 :: [2]f32

main :: proc() {


	if (aligned_vectors({0, 1}, {0, 1}, {0, 1}, {0, 1}, {1, 1})) {
		fmt.println("ALIGNED")
	} else {
		fmt.println("NOT ALIGNED!")}

}
