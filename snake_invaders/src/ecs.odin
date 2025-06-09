package main


State :: enum {
	PLAY,
	PAUSE,
}

Entity :: u32
ComponentID :: enum u32 {
	moveID    = 1 << 0,
	collideID = 1 << 1,
}

MaskComponents :: u32
Component :: union {
	collider_t,
	mover_t,
}


System :: struct {
	world: ^World,
	kind:  SystemKind,
}

SystemKind :: union {
	RenderingSystem,
	UpdateSystem,
}


SetWorld :: proc(w: ^World, system: ^System) -> ^System {
	system.world = w
	return system
}

Archetype :: struct {
	mask:            MaskComponents,
	entities:        []Entity,
	components:      map[ComponentID]Component,
	entity_to_index: map[Entity]int,
}

World :: struct {
	next_entity_id: Entity,
	state:          State,
	entityMask:     map[Entity]MaskComponents,
	archetypes:     map[MaskComponents]^Archetype,
}

CreateEntity :: proc(world: ^World, components: map[ComponentID]Component) -> Entity {
	entity := world.next_entity_id
	world.next_entity_id += 1


	mask := GetMaskFromComponents(components)
	component_list := []ComponentID{}
	count := 0
	for component in components {
		component_list[count] = component
		count += 1
	}
	archetype, ok := world.archetypes[mask]
	if !ok {
		newArchetype := NewArchetype(components)
		world.archetypes[mask] = newArchetype
		archetype = newArchetype
	}
	return entity
}


COLLIDER_TYPE :: enum {
	STATIC,
	BULLET,
	CANDY,
}

STATE :: enum {
	DEAD,
	ALIVE,
}


NewArchetype :: proc(components: map[ComponentID]Component) -> ^Archetype {
	archetype := new(Archetype)
	archetype.mask = GetMaskFromComponents(components)
	archetype.entities = make([]Entity, 0)
	archetype.components = make(map[ComponentID]Component)
	archetype.entity_to_index = make(map[Entity]int)

	for id, component in components {

		archetype.components[id] = MakeComponentArray(id)
	}


	return archetype
}


MakeComponentArray :: proc(component: $T) -> []Component {
	switch component {
	case .moveID:
		return make([]mover_t, 100)
	case .collideID:
		return collider_t


		return make([]T, 100)
	}


	GetComponentFromID :: proc(component: ComponentID) -> Component {
	}
}
GetMaskFromComponents :: proc(components: map[ComponentID]Component) -> MaskComponents {
	mask: ComponentID
	for k in components {
		mask |= k
	}
	return MaskComponents(mask)
}

HasComponent :: proc(mask: u32, id: ComponentID) -> bool {
	return (mask & u32(id)) != 0
}
MAX_NUM_COLLIDERS :: 100


collider_t :: struct {
	position: vec2_t,
	w, h:     f32,
	state:    STATE,
	kind:     COLLIDER_TYPE,
}

mover_t :: struct {
	position:  vec2_t,
	direction: vec2_t,
	speed:     f32,
	kind:      COLLIDER_TYPE,
}


RenderingSystem :: struct {
	world: ^World,
}

UpdateSystem :: struct {
	world: ^World,
}
