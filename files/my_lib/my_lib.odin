package my_lib
import "core:c"
import "core:fmt"


when ODIN_OS == .Windows {
	// Esta linea dice que libreria estamos importando.
	foreign import my_lib "windows/my_lib.lib"

} else when ODIN_OS == .Linux {

	foreign import my_lib "linux/my_lib.a"


} else when ODIN_OS == .Darwin {
	foreign import my_lib "macos/my_lib.a"

}


Callback :: proc "c" (_: TestStruct)


// Aqui definimos las funciones de dicha libreria que exponemos.
@(default_calling_convention = "c")
foreign my_lib {
	set_callback :: proc(c: Callback) ---
	do_stuff :: proc(ts: TestStruct) ---
}


TestStruct :: struct {
	num:     c.int,
	flt_num: c.float,
}
