package main
import "core:fmt"
import "core:math"

PI :: 3.14159

Shape :: union #no_nil {
	Circle,
	Square,
	Rect,
}

Circle :: struct {
	radius: f32,
}

Square :: struct {
	width: f32,
}

Rect :: struct {
	width, height: f32,
}

Entity :: struct {
	id:    int,
	shape: Shape,
}

main :: proc() {

	shapes := [3]Entity{}

	shapes[0] = Entity{0, Circle{3}}
	shapes[1] = Entity{1, Square{5}}
	shapes[2] = Entity{2, Rect{2, 4}}
	for &shape in shapes {
		print_area(&shape)
	}
}


print_area :: proc(e: ^Entity) {
	switch s in e.shape {
	case Circle:
		r := e.shape.(Circle).radius
		area := PI * (r * r)
		fmt.printf("Circle has radius of %2f, and area of %2f\n", r, area)
	case Square:
		w := e.shape.(Square).width
		area := (w * w)
		fmt.printf("Square has border of %2f, and area of %2f\n", w, area)
	case Rect:
		w := e.shape.(Rect).width
		h := e.shape.(Rect).height
		area := w * h
		fmt.printf("Rect has border of %2f and %2f, and area of %2f\n", w, h, area)
	case:
		fmt.println("No idea of this shape")
	}
}
