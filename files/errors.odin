package main

import "core:encoding/json"
import "core:fmt"
import os "core:os/os2"

LOAD_FIGHTER_ERROR :: enum {
	None,
	File_Unreadable,
	Invalid_Format,
}

Fighter :: struct {
	name:   string,
	health: int,
	power:  f32,
}

DEFAULT_FIGHTER := Fighter {
	name   = "Default fighter",
	health = 3,
	power  = 2.3,
}

load_fighter :: proc(file_path: string) -> (Fighter, LOAD_FIGHTER_ERROR) {
	data, ok := os.read_entire_file_from_path(file_path, context.temp_allocator)
	if ok != nil do return {}, .File_Unreadable

	fighter: Fighter

	json_error := json.unmarshal(data, &fighter, allocator = context.temp_allocator)
	if json_error != nil do return {}, .Invalid_Format


	return fighter, .None
}


main :: proc() {
	// Or else takes last return value and if it is not 0 value it will give back right val
	fighter := load_fighter("assets/fighter.json") or_else DEFAULT_FIGHTER
	default_fighter := load_fighter("nonexistentpath") or_else DEFAULT_FIGHTER
	fmt.println(fighter)
	fmt.println(default_fighter)

}


// or_return
clone :: proc(
	s: string,
	allocator := context.allocator,
	loc := #caller_location,
) -> (
	res: string,
	err: mem.Allocator_Error, // We need named return values because we would need to return a something declared in the or_return
) #optional_allocator_error {
	// If error on make, the error is returned
	c := make([]byte, len(s), allocator, loc) or_return
	copy(c, s)
	return string(c[:len(s)]), nil
}


// We can use #optional_ok and #optional_allocator_error to make optional bools or errors
