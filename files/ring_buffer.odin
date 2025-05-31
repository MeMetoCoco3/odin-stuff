package main
import "core:fmt"

MAX_RINGBUFFER_VALUES :: 20

cell_ghost_t :: struct {
	a, b: int,
}

Ringuffer_t :: struct {
	values: [MAX_RINGBUFFER_VALUES]cell_ghost_t,
	head:   i8,
	tail:   i8,
	count:  i8,
}


main :: proc() {
	rb := Ringuffer_t{}

	// Insert some test values
	for i := 0; i < 5; i += 1 {
		cell := cell_ghost_t {
			a = i,
			b = i * 10,
		}
		put_cell(&rb, cell)
		fmt.println("Put:", cell)
	}

	// Peek at the current head
	peeked_cell, ok := peek_cell(&rb)
	if ok {
		fmt.println("Peeked:", peeked_cell)
	} else {
		fmt.println("Peeked: buffer empty")
	}

	// Pop all elements
	for {
		cell, ok := pop_cell(&rb)
		if !ok {
			break
		}
		fmt.println("Popped:", cell)
	}

	// Confirm buffer is empty
	_, ok = peek_cell(&rb)
	if !ok {
		fmt.println("Buffer is now empty after popping all elements.")
	}
}

put_cell :: proc(rb: ^Ringuffer_t, cell: cell_ghost_t) {
	if rb.count >= MAX_RINGBUFFER_VALUES {
		return
	}

	rb.values[rb.tail] = cell

	rb.tail = (rb.tail + 1) % MAX_RINGBUFFER_VALUES
	rb.count += 1
}

pop_cell :: proc(rb: ^Ringuffer_t) -> (cell_ghost_t, bool) {
	if rb.count == 0 {
		return cell_ghost_t{}, false
	}

	popped_cell := rb.values[rb.head]

	rb.head = (rb.head + 1) % MAX_RINGBUFFER_VALUES
	rb.count -= 1

	return popped_cell, true
}

peek_cell :: proc(rb: ^Ringuffer_t) -> (cell_ghost_t, bool) {
	if rb.count == 0 {
		return cell_ghost_t{}, false
	}

	return rb.values[rb.head], true
}
