package main
import "core:fmt"
COMPONENT_ID :: enum {
	POSITION,
	VELOCITY,
	SPRITE,
	ANIMATION,
	DATA,
	COLLIDER,
	IA,
	PLAYER_DATA,
	COUNT,
}

mask1: bit_set[COMPONENT_ID;u64]
mask2: bit_set[COMPONENT_ID;u64]

bit_range_num: bit_set[0 ..= 5]
bit_range_alpha: bit_set['A' ..= 'Z']

// // i32 is the total bits of the bitfield
EnemyData :: bit_field i32 {
	// components: bit_set[COMPONENT_ID]    | 8, // THIS CANT BE DONE, NEEDS TO BE BOOL, NUM or ENUM. 
	components: COMPONENT_ID | 8,
	health:     int          | 8, // When fetched, the value will be read as a i64, but inside of the bitfield, it will be just 8 bits long.
	speed:      int          | 16,
}


main :: proc() {
	mask1 += {.POSITION, .SPRITE}
	mask2 += {.SPRITE}
	fmt.println(mask1 & mask2)
	// if .POSITION in mask {
	// 	fmt.println("GOOD")
	// }

	enemy_data := EnemyData {
		// components = mask1,
		health = 3,
		speed  = 4,
	}

	fmt.println(enemy_data)

}
