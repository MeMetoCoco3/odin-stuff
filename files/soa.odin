package main
import fmt "core:fmt"
import "core:math/rand"
import "core:mem"
import "core:time"

@(private = "file")
NUM_ELEMS :: 10000

@(private = "file")
NUM_TEST_ITERS :: 10

@(private = "file")
Person :: struct($N: int) {
	health:     int,
	age:        int,

	// We add in more and more extra bytes
	// by varying the parameter N. For
	// bigger `extra_data` you may see
	// bigger benefits of SoA because of
	// being able to fill cache lines with
	// more relevant data.
	extra_data: [N]byte,
}

@(private = "file")
make_person :: proc($N: int) -> Person(N) {
	health := int(rand.int31_max(101))
	age := int(rand.int31_max(101))

	return {health = health, age = age}
}

benchmark_aos_array :: proc($N: int) -> f64 {
	people: [dynamic]Person(N)

	for i in 0 ..< NUM_ELEMS {
		p := make_person(N)
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
	fmt.println("Arrays of Structures age sum:", f32(age_sum) / (NUM_TEST_ITERS * NUM_ELEMS))

	return time.duration_milliseconds(time.diff(start, end))
}

benchmark_soa_array :: proc($N: int) -> f64 {
	people: #soa[dynamic]Person(N)

	for i in 0 ..< NUM_ELEMS {
		p := make_person(N)
		append_soa(&people, p)
	}

	age_sum: int
	start := time.now()
	for i in 0 ..< NUM_TEST_ITERS {
		for &p in people {
			// This will become vectorized
			// with -o:speed. Run with
			// -o:none to see the
			// "pure SoA vs AoS numbers".

			// Also, if we add in lots of
			// extra instructions in this
			// loop, then prefetching might
			// start being as fast as SoA
			// because the prefetcher has
			// time enough to prefetch the
			// next thing from main memory.
			age_sum += p.age
		}
	}
	end := time.now()
	fmt.println("Structure of Arrays age sum:", f32(age_sum) / (NUM_TEST_ITERS * NUM_ELEMS))

	return time.duration_milliseconds(time.diff(start, end))
}

soa_bench :: proc($N: int) {
	fmt.printfln("For %v bytes of extra data in each array element:", N)
	time_aos := benchmark_aos_array(N)
	time_soa := benchmark_soa_array(N)
	fmt.printfln("SoA is %.2f times faster than AoS", time_aos / time_soa)
	fmt.println()
}

main :: proc() {
	soa_bench(0)
	soa_bench(2)
	soa_bench(4)
	soa_bench(8)
	soa_bench(16)
	soa_bench(32)
	soa_bench(64)
	soa_bench(128)
	soa_bench(256)
	soa_bench(512)
	soa_bench(1024)
	soa_bench(1500)
	soa_bench(2000)
	soa_bench(3000)
}
