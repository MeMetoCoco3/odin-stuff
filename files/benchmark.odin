package main

import fmt "core:fmt"
import "core:math/rand"
import "core:mem"
import "core:time"

Person :: struct {
	health: int,
	age:    int,
}

NUM_ELEMS :: 10000
NUM_TEST_ITERS :: 10

make_person :: proc() -> Person {
	health := int(rand.int31_max(101))
	age := int(rand.int31_max(101))

	return {health = health, age = age}
}

benchmark_scattered_array :: proc() -> f64 {
	people: [dynamic]^Person

	for _ in 0 ..< NUM_ELEMS {
		p := new(Person)
		p^ = make_person()
		append(&people, p)
	}

	age_sum: int
	start := time.now()
	for i in 0 ..< NUM_TEST_ITERS {
		for &p in people {
			age_sum += p.age
		}
	}
	end := time.now()
	fmt.println("Scattered array age sum:", f32(age_sum) / (NUM_TEST_ITERS * NUM_ELEMS))

	return time.duration_milliseconds(time.diff(start, end))
}

// This array is allocating random stuff so the allocations the system is doing will be made farther between each other. 
benchmark_scattered_array_realisitc :: proc() -> f64 {
	people: [dynamic]^Person

	for _ in 0 ..< NUM_ELEMS {
		for i in 0 ..< 100 {
			_, _ = mem.alloc(rand.int_max(8) + 8)
		}

		p := new(Person)
		p^ = make_person()
		append(&people, p)
	}

	age_sum: int
	start := time.now()
	for i in 0 ..< NUM_TEST_ITERS {
		for &p in people {
			age_sum += p.age
		}
	}
	end := time.now()
	fmt.println("Scattered array age sum:", f32(age_sum) / (NUM_TEST_ITERS * NUM_ELEMS))

	return time.duration_milliseconds(time.diff(start, end))
}

benchmark_tight_array :: proc() -> f64 {
	people: [dynamic]Person

	for i in 0 ..< NUM_ELEMS {
		p := make_person()
		append(&people, p)
	}

	age_sum: int
	start := time.now()
	for i in 0 ..< NUM_TEST_ITERS {
		for &p in people {
			age_sum += p.age
		}
	}
	end := time.now()
	fmt.println("Tight array age sum:", f32(age_sum) / (NUM_TEST_ITERS * NUM_ELEMS))

	return time.duration_milliseconds(time.diff(start, end))
}

// main :: proc() {
// 	time_scattered := benchmark_scattered_array()
// 	time_tight := benchmark_tight_array()
// 	time_scattered_real := benchmark_scattered_array_realisitc()
// 	fmt.printfln(
// 		"Cache friendly method is %.2f times faster than scattered",
// 		time_scattered / time_tight,
// 	)
// 	fmt.printfln(
// 		"Cache friendly method is %.2f times faster than realistic scattered",
// 		time_scattered_real / time_tight,
// 	)
//
// 	fmt.printfln(
// 		"Scattered method is %.2f times faster than realistic scattered",
// 		time_scattered_real / time_scattered,
// 	)
// }


// Problem here, a pointer to any of this persons will get invalid if the array grows to much, because it wil be realocated
main :: proc() {
	Person :: struct {
		health: int,
		age:    int,
	}

	people: [dynamic]Person
	append(&people, Person{health = 10, age = 65})
	person_ptr := &people[0]

	for i in 0 ..< 65665 {
		append(&people, Person{})
	}

	fmt.printfln("%p", &people[0])
	fmt.printfln("%p", person_ptr)
}
