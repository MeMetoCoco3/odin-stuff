package main

import "core:fmt"
foo :: struct {
	x, y: int,
}

bar :: struct {
	using voo: foo,
	radius:    f32,
}

jamon :: struct {
	using jax: bar,
	gues:      int,
}

print_xy :: proc(f: ^foo) {
	fmt.println(f.x, f.y)
}

print_f :: proc(f: ^bar) {
	fmt.println(f.radius)
}


main :: proc() {
	f1 := foo{1, 2}
	b1 := bar{{3, 4}, 4.5}
	j1 := jamon{{{5, 6}, 9.0}, 9}
	arr1 := make([dynamic]foo)
	append(&arr1, f1)
	append(&arr1, b1)
	append(&arr1, j1)


	for i in 0 ..< len(arr1) {
		print_xy(&arr1[i])
	}

	arr2 := make([dynamic]bar)
	append(&arr2, b1)
	append(&arr2, j1)

	for i in 0 ..< len(arr2) {
		print_f(&arr2[i])
	}

}
