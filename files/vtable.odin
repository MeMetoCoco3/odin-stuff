package main

import "core:fmt"
import "core:math"
import "core:math/linalg"

NPC_VTable :: struct {
	attack: proc(data: rawptr),
}

@(private = "file")
NPC :: struct {
	vtable: ^NPC_VTable,
	data:   rawptr,
}

Warrior :: struct {
	health: int,
	dmg:    int,
	name:   string,
}
Wizard :: struct {
	health:      int,
	mana:        int,
	magic_power: f32,
	name:        string,
}
Hobbit :: struct {
	health: int,
	name:   string,
}

warrior_table := &NPC_VTable{attack = warrior_attack}
warrior_attack :: proc(data: rawptr) {
	npc := cast(^Warrior)data
	fmt.printfln("THE WARRIOR %v ATTACKED AND INFLICTED %v OF DAMAGE", npc.name, npc.dmg)
}

wizard_table := &NPC_VTable{attack = wizard_attack}
wizard_attack :: proc(data: rawptr) {
	npc := cast(^Wizard)data
	npc.mana -= 20
	if npc.mana <= 0 {
		fmt.printfln("THE WIZARD %v, HAS NO MANA", npc.name)
	} else {
		fmt.printfln(
			"THE Wizard %v ATTACKED AND INFLICTED %v, current mana = %v",
			npc.name,
			npc.magic_power,
			npc.mana,
		)}
}


hobbit_table := &NPC_VTable{attack = hobbit_attack}
hobbit_attack :: proc(data: rawptr) {
	npc := cast(^Hobbit)data
	fmt.printfln("THE HOBBIT DOES NOT DO ANYTHING")
}


make_warrior :: proc() -> NPC {
	npc := new(Warrior)
	npc.health = 4
	npc.dmg = 3
	npc.name = "Alicuecano"
	return NPC{vtable = warrior_table, data = rawptr(npc)}
}

make_wizard :: proc() -> NPC {
	npc := new(Wizard)
	npc.health = 4
	npc.magic_power = 3
	npc.mana = 30
	npc.name = "Ricewind"
	return NPC{vtable = wizard_table, data = rawptr(npc)}
}


make_hobbit :: proc() -> NPC {
	npc := new(Hobbit)
	npc.health = 3
	npc.name = "Bilbo"
	return NPC{vtable = hobbit_table, data = rawptr(npc)}
}


main :: proc() {
	npcs := [?]NPC{make_hobbit(), make_warrior(), make_wizard()}

	for npc in npcs {
		npc.vtable.attack(npc.data)
	}

	wizard := make_wizard()
	wizard.vtable.attack(wizard.data)
	wizard.vtable.attack(wizard.data)
}
