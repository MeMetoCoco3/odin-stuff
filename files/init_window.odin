package main

import "base:runtime"
import "core:log"
import "core:math/linalg"
import sdl "vendor:sdl3"
default_context: runtime.Context

frag_shader_code := #load("shader.spv.frag")
vert_shader_code := #load("shader.spv.vert")

main :: proc() {
	context.logger = log.create_console_logger()
	default_context = context
	sdl.SetLogPriorities(.VERBOSE)
	sdl.SetLogOutputFunction(
		proc "c" (
			userdata: rawptr,
			category: sdl.LogCategory,
			priority: sdl.LogPriority,
			message: cstring,
		) {
			context = default_context
			log.debugf("SDL {} [{}]: {}", category, priority, message)
		},
		nil,
	)


	// .VIDEO is part of a enum set, that initialize SDL subsystems
	ok := sdl.Init({.VIDEO});assert(ok)

	window := sdl.CreateWindow("Hello SDL", 1280, 780, {});assert(window != nil)


	gpu := sdl.CreateGPUDevice({.SPIRV}, true, nil)
	assert(gpu != nil)

	ok = sdl.ClaimWindowForGPUDevice(gpu, window)


	vertex_shader := load_shader(gpu, vert_shader_code, .VERTEX, 1)
	fragment_shader := load_shader(gpu, frag_shader_code, .FRAGMENT, 0)

	pipeline := sdl.CreateGPUGraphicsPipeline(
		gpu,
		{
			vertex_shader = vertex_shader,
			fragment_shader = fragment_shader,
			primitive_type = .TRIANGLELIST,
			target_info = {
				num_color_targets = 1,
				color_target_descriptions = &(sdl.GPUColorTargetDescription {
						format = sdl.GetGPUSwapchainTextureFormat(gpu, window),
					}),
			},
		},
	)

	sdl.ReleaseGPUShader(gpu, vertex_shader)
	sdl.ReleaseGPUShader(gpu, fragment_shader)


	window_size: [2]i32
	ok = sdl.GetWindowSize(window, &window_size.x, &window_size.y);assert(ok)
	proj_mat := linalg.matrix4_perspective_f32(
		70,
		f32(window_size.x) / f32(window_size.y),
		0.00001,
		1000,
	)
	ROTATION_SPEED := linalg.to_radians(f32(90))
	rotation := f32(0)

	UBO :: struct {
		mvp: matrix[4, 4]f32,
	}


	last_tick := sdl.GetTicks()

	// When using labels we can break $label and continue $label from nested loops 
	main_loop: for {

		current_tick := sdl.GetTicks()
		delta_time := f32(current_tick - last_tick) / 1000
		last_tick = current_tick


		// PROCESS EVENTS
		event: sdl.Event
		for sdl.PollEvent(&event) {
			// Odin will complain if we make a switch that does not deal with all cases, so we use partial.
			#partial switch event.type {
			case .QUIT:
				break main_loop
			case .KEY_DOWN:
				if event.key.scancode == .ESCAPE || event.key.scancode == .Q do break main_loop
			}
		}


		// GAME STATE


		// RENDER
		// A commamnd buffer records a series of instructions to pass to GPU efficiently
		cmd_buf := sdl.AcquireGPUCommandBuffer(gpu)
		// Swapchain texture is a special texture that represents the content of a window.
		swapchain_tex: ^sdl.GPUTexture
		ok := sdl.WaitAndAcquireGPUSwapchainTexture(
			cmd_buf,
			window,
			&swapchain_tex,
			nil,
			nil,
		);assert(ok)

		rotation += ROTATION_SPEED * delta_time
		model_mat :=
			linalg.matrix4_translate_f32({0, 0, -20}) *
			linalg.matrix4_rotate_f32(rotation, {0, 1, 0})
		ubo := UBO {
			mvp = proj_mat * model_mat,
		}

		if swapchain_tex != nil { 	// Si swapchain text fuese NULL lo pasariamos a color_target y crasheariamos todo. Seria null si la ventana estubiera minimizada
			log.debug("Rendering")
			color_target := sdl.GPUColorTargetInfo {
				texture     = swapchain_tex,
				load_op     = .CLEAR,
				clear_color = {0, 0.2, 0.5, 1},
				store_op    = .STORE,
			}
			render_pass := sdl.BeginGPURenderPass(cmd_buf, &color_target, 1, nil)
			sdl.BindGPUGraphicsPipeline(render_pass, pipeline)
			// Dos tipos de data podemos pasar, vertices o uniform.
			// Vertices es vertices.
			// Uniform es algo como nuestra matrix de projeccion, afecta a todos los pixeles.

			// Este 0 es el slot_index, hace referencia al binding = 0  en el vertex shader.
			sdl.PushGPUVertexUniformData(cmd_buf, 0, &ubo, size_of(ubo))
			sdl.DrawGPUPrimitives(render_pass, 3, 1, 0, 0)
			sdl.EndGPURenderPass(render_pass)
		} else {
			log.debug("NOT RENDERING!")
		}

		ok = sdl.SubmitGPUCommandBuffer(cmd_buf);assert(ok)


	}
}


load_shader :: proc(
	device: ^sdl.GPUDevice,
	code: []u8,
	stage: sdl.GPUShaderStage,
	num_uniform_buffers: u32,
) -> ^sdl.GPUShader {
	return sdl.CreateGPUShader(
		device,
		{
			code_size = len(code),
			code = raw_data(code),
			entrypoint = "main",
			format = {.SPIRV},
			stage = stage,
			num_uniform_buffers = num_uniform_buffers,
		},
	)


}
