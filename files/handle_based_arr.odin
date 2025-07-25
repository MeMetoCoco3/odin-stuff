package main


Handle :: struct {
	idx: u32,
	gen: u32,
}


HANDLE_NONE :: Handle{}
Handle_Array :: struct($T: typeid, $HT: typeid) {
	items:    [dynamic]T,
	freelist: [dynamic]HT,
	count:    int,
}


ha_clear :: proc(ha: ^Handle_Array($T, $TH)) {
	clear(ha.items)
	clear(ha.freelist)
}

ha_delete :: proc(ha: ^Handle_Array($T, $TH)) {
	delete(ha.items)
	delete(ha.freelist)
}

// V should contain a handle
ha_add :: proc(ha: ^Handle_Array($T, $HT), v: T) -> HT {
	v := v
	if len(ha.freelist) > 0 {
		h := pop(&ha.freelist)
		h.gen += 1
		v.handle = h // ??
		ha.items[h.idx] = v
		ha.count += 1
		return h
	}

	// Index 0 is always defined as 0
	if len(ha.items) == 0 {
		append_nothing(&ha.items)
	}

	idx := u32(len(ha.items))
	v.handle.idx = idx
	v.handle.gen = 1
	append(&ha.items, v)
	ha.count += 1
	return v.handle
}


ha_get :: proc(ha: Handle_Array($T, $HT), h: HT) -> (T, bool) {
	if h.idx > 0 && int(h.idx) < len(ha.items) && ha.items[h.idx].handle == h {
		return ha.items[h.idx], true
	}
	return {}, false
}


ha_get_ptr :: proc(ha: Handle_Array($T, $HT), h: HT) -> (T, bool) {
	if h.idx > 0 && int(h.idx) < len(ha.items) && ha.items[h.idx].handle == h {
		return &ha.items[h.idx]
	}
	return nil
}

ha_remove :: proc(ha: Handle_Array($T, $HT), h: HT) {
	if h.idx > 0 && int(h.idx) < len(ha.items) && ha.items[h.idx].handle == h {
		append(&ha.freelist, h)
		ha.items[h.idx] = {}
		ha.count -= 1
	}
}

ha_valid :: proc(ha: Handle_Array($T, $HT), h: HT) -> bool {
	return ha_get(ha, h) != nil
}

Handle_Array_Iter :: struct($T: typeid, $HT: typeid) {
	ha:    Handle_Array(T, HT),
	index: int,
}

ha_make_iter :: proc(ha: Handle_Array($T, $HT)) -> Handle_Array_Iter(T, HT) {
	return Handle_Array_Iter(T, HT){ha = ha}
}

ha_iter :: proc(it: ^Handle_Array_Iter($T, $HT)) -> (val: T, h: HT, cond: bool) {
	in_range := it.index < len(it.ha.items)

	for in_range {
		cond = it.index > 0 && in_range && it.ha.items[it.index].handle.idx > 0

		if cond {
			val = it.ha.items[it.index]
			h = it.ha.items[it.index].handle
			it.index += 1
			return
		}

		it.index += 1
		in_range = it.index < len(it.ha.items)
	}

	return
}


ha_iter_ptr :: proc(it: ^Handle_Array_Iter($T, $HT)) -> (val: ^T, h: HT, cond: bool) {
	in_range := it.index < len(it.ha.items)

	for in_range {
		cond = it.index > 0 && in_range && it.ha.items[it.index].handle.idx > 0

		if cond {
			val = &it.ha.items[it.index]
			h = it.ha.items[it.index].handle
			it.index += 1
			return
		}

		it.index += 1
		in_range = it.index < len(it.ha.items)
	}

	return
}
