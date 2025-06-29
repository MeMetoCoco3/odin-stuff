package main
import "core:fmt"

Jamon :: struct {
	precio:     int,
	nombre:     string,
	de_bellota: bool,
}

JamonIterator :: struct {
	index:   int,
	jamones: []Jamon,
}

make_jamones_iterator :: proc(data: []Jamon) -> JamonIterator {
	return {jamones = data}
}

jamon_iterator :: proc(it: ^JamonIterator) -> (val: Jamon, idx: int, cond: bool) {
	cond = it.index < len(it.jamones)

	for ; cond; cond = it.index < len(it.jamones) {
		if !it.jamones[it.index].de_bellota {
			it.index += 1
			continue
		}

		val = it.jamones[it.index]
		idx = it.index
		it.index += 1
		break
	}

	return
}
main :: proc() {
	jamones := make([]Jamon, 128)

	jamones[10] = {
		precio     = 7,
		nombre     = "Frank",
		de_bellota = true,
	}

	jamones[50] = {
		precio     = 89,
		nombre     = "Tonarrox",
		de_bellota = true,
	}
	jamones[0] = {
		precio     = 3,
		nombre     = "El luis",
		de_bellota = false,
	}
	jamones[100] = {
		precio     = 7000,
		nombre     = "El Hector",
		de_bellota = true,
	}
	it := make_jamones_iterator(jamones[:])


	fmt.println("Quiere jamon de bellotita? Pues tenemos: ")
	for val, i in jamon_iterator(&it) {
		fmt.printfln("- %v\t%v a %v euritos.", i, val.nombre, val.precio)
	}
}
