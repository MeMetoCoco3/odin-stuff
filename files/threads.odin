package main
import "core:fmt"
import "core:thread"
import "core:time"

Worker_Thread_Data :: struct {
	run:    bool, // Needed for loops

	// Add data your thread needs here.
	thread: ^thread.Thread,
}

War :: struct {
	data:          string,
	people_fought: int,
}

worker_thread_proc :: proc(t: ^thread.Thread) {
	d := (^Worker_Thread_Data)(t.data)
	time_passed := 4
	for d.run {
		time.sleep(time.Second * 2)
		time_passed -= 1
		fmt.println(time.now())
		if time_passed <= 0 {
			fmt.println(d.thread.data)
			d.run = false
		}
	}
	fmt.println("Worker finished")
}

start_worker_thread :: proc(d: ^Worker_Thread_Data) {
	d.run = true
	if d.thread = thread.create(worker_thread_proc); d.thread != nil {
		d.thread.init_context = context
		d.thread.data = rawptr(d)
		thread.start(d.thread)
	}
}

stop_worker_thread :: proc(d: ^Worker_Thread_Data) {
	d.run = false
	thread.join(d.thread)
	thread.destroy(d.thread)
}


main :: proc() {
	thousand_year_war := War {
		data          = "theotherday",
		people_fought = 1000,
	}
	worker: Worker_Thread_Data

	worker.thread.data = &thousand_year_war
	start_worker_thread(&worker)

}
