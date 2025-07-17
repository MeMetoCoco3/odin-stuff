package main
import "base:intrinsics"
import "core:fmt"
import "core:reflect"
import "core:slice"

@(private = "file")
Entity :: enum {
	Player,
	Enemy,
	Boss,
}


Character :: struct {
	rol:  string,
	name: string,
}

@(private = "file")
Rect :: [2]int

player := Character{"Player", "Vidal"}
boss := Character{"Boss", "Katuja"}

gui_dropdown :: proc(rect: Rect, values: []$T, names: []string, cur: T) -> (T, bool) {
	// Do something and return, or not a change.
	return T{}, false}

gui_enum_dropdown :: proc(rect: Rect, cur: $T) -> (T, bool) where intrinsics.type_is_enum(T) {
	names := reflect.enum_field_names(T)
	values := reflect.enum_field_values(T)
	values_i64 := slice.reinterpret([]i64, values)
	new_val, changed := gui_dropdown(rect, values_i64, names, i64(cur))
	return T(new_val), changed
}

main :: proc() {
	if rol, ok := reflect.enum_from_name(Entity, player.rol); ok {
		fmt.printfln("The character %v is the %v", player.name, rol)
	}
	if rol, ok := reflect.enum_from_name(Entity, boss.rol); ok {
		fmt.printfln("The character %v is the %v", boss.name, rol)
		gui_enum_dropdown(Rect{0, 0}, rol)
	}


}
