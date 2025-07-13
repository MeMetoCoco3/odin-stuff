package main
import "core:fmt"

// En este programa cogemos un puntero y lo casteamos a un valor que ocupa mas espacio. Este fallo pasa desapercibido a no ser que:
// odin run . -debug -sanitize:address
// Para mas info odin book apartado 13.4
main :: proc() {
	f: f32 = 7.0
	bad_pointer := cast(^f64)&f

	fmt.println(bad_pointer^)
}
