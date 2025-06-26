build:
	@rm -f odin 
	glslc ./shaders/shader.glsl.frag -o ./files/shader.spv.frag || exit 1
	glslc ./shaders/shader.glsl.vert -o ./files/shader.spv.vert || exit 1
	@odin build  ./files/$(file) -file -out:odin -debug 
	@odin run 

run:
	odin run .
clear:
	rm -f odin

comp_shad:
	glslc ./shaders/shader.glsl.frag -o ./files/shader.spv.frag || exit 1
	glslc ./shaders/shader.glsl.vert -o ./files/shader.spv.vert || exit 1

b_debug: 
	@odin build ./files/$(file) -file -out:debug_$(file) -o:none -debug
debug: 
	gdb debug_$(file)
