package main

// TODO: Check more about markov chain for state machines on ai behavior

import "core:fmt"
import "core:math"
import "core:math/linalg"

CLIMATE :: enum {
	RAINY,
	SUNNY,
	CLODY,
}


prob_climate :: struct {
	chain:         matrix[3, 3]f32,
	current_state: CLIMATE,
	current_vec:   [3]f32,
}

climate := [CLIMATE][3]f32 {
	.RAINY = {1, 0, 0},
	.SUNNY = {0, 1, 0},
	.CLODY = {0, 0, 1},
}

spain := prob_climate {
	chain         = {0.3, 0.4, 0.3, 0.4, 0.3, 0.4, 0.3, 0.3, 0.3},
	current_state = .SUNNY,
	current_vec   = climate[.SUNNY],
}

main :: proc() {
	for i in 0 ..< 20 {
		fmt.println(i)
		print_day(spain.current_vec, spain.current_state)
		pass_day(&spain)
		fmt.println()
	}
}

print_day :: proc(prob: [3]f32, curr_state: CLIMATE) {
	fmt.println("Current state: ", curr_state)
	fmt.println("Probabilities:")
	fmt.printfln("  RAINY: %.2f", prob[CLIMATE.RAINY])
	fmt.printfln("  SUNNY: %.2f", prob[CLIMATE.SUNNY])
	fmt.printfln("  CLODY: %.2f", prob[CLIMATE.CLODY])
}

pass_day :: proc(country: ^prob_climate) {
	country.current_vec = country.chain * country.current_vec
	country.current_state = CLIMATE(get_max_index(country.current_vec))
}

get_max_index :: proc(v: [3]f32) -> int {
	max := 0
	for _, i in v {
		if v[i] > v[max] {
			max = i
		}
	}
	return max


}
