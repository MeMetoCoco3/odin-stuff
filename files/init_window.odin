package main

import "base:runtime"
import "core:log"
import "core:math/linalg"
import "core:mem"
import sdl "vendor:sdl3"
import stbi "vendor:stb/image"

default_context: runtime.Context

// Load file as []u8
frag_shader_code := #load("shader.spv.frag")
vert_shader_code := #load("shader.spv.vert")


main :: proc() {

	// Creamos un custom logger para imprimir mensajes desde SDL
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

	// Iniciamos SDL con los sistemas que queremos.
	ok := sdl.Init({.VIDEO});assert(ok)

	// Iniciamos una ventana.
	window := sdl.CreateWindow("Hello SDL", 1280, 780, {});assert(window != nil)

	// Iniciamos un Device, y le pasamos el tipo de shaders que vamos a hacer.
	// SPIRV es el tipo de shaders utilizado por vulkan.
	gpu := sdl.CreateGPUDevice({.SPIRV}, true, nil)
	assert(gpu != nil)

	// Asignamos una ventana al device.
	ok = sdl.ClaimWindowForGPUDevice(gpu, window)

	// Asignamos los shaders a la GPU.
	vertex_shader := load_shader(
		gpu,
		vert_shader_code,
		.VERTEX,
		num_uniform_buffers = 1,
		num_samplers = 0,
	)

	fragment_shader := load_shader(
		gpu,
		frag_shader_code,
		.FRAGMENT,
		num_uniform_buffers = 0,
		num_samplers = 1, // Esta linea me ha matado, por su culpa la textura no renderizaba.
	)

	// Load pixels
	img_size: [2]i32
	pixels := stbi.load(
		"files/texture.png",
		&img_size.x,
		&img_size.y,
		nil,
		4,
	);assert(pixels != nil);defer stbi.image_free(pixels)
	// pixels := sdli.Load("files/texture2.png");assert(pixels != nil)
	// img_size.x, img_size.y = pixels.w, pixels.h
	pixelx_byte_size := img_size.x * img_size.y * 4

	// Create texture on the gpu
	pixels_texture := sdl.CreateGPUTexture(
		gpu,
		{
			format = .R8G8B8A8_UNORM,
			usage = {.SAMPLER},
			height = u32(img_size.y),
			width = u32(img_size.x),
			layer_count_or_depth = 1,
			num_levels = 1,
		},
	)

	tex_transfer_buffer := sdl.CreateGPUTransferBuffer(
		gpu,
		{usage = .UPLOAD, size = u32(pixelx_byte_size)},
	)

	tex_transfer_memory := transmute([^]byte)sdl.MapGPUTransferBuffer(
		gpu,
		tex_transfer_buffer,
		false,
	)
	mem.copy(tex_transfer_memory, pixels, int(pixelx_byte_size))
	sdl.UnmapGPUTransferBuffer(gpu, tex_transfer_buffer)

	// Definimos los datos que vamos a pasar
	Vec3 :: [3]f32
	Vertex_Data :: struct {
		pos:   Vec3,
		color: sdl.FColor,
		uv:    [2]f32,
	}
	vertices := []Vertex_Data {
		{pos = {-0.5, -0.5, 0}, color = {1, 1, 0, 1}, uv = {0, 1}},
		{pos = {0.5, 0.5, 0}, color = {1, 1, 0, 1}, uv = {1, 0}},
		{pos = {-0.5, 0.5, 0}, color = {1, 0, 1, 1}, uv = {0, 0}},
		{pos = {0.5, -0.5, 0}, color = {0, 1, 1, 1}, uv = {1, 1}},
	}
	vertices_byte_size := len(vertices) * size_of(vertices[0])

	indices := []u16{0, 1, 2, 0, 3, 1}
	indices_byte_size := len(indices) * size_of(indices[0])

	// Creamos un buffer para los datos.
	vertex_buffer := sdl.CreateGPUBuffer(gpu, {usage = {.VERTEX}, size = u32(vertices_byte_size)})
	index_buffer := sdl.CreateGPUBuffer(gpu, {usage = {.INDEX}, size = u32(indices_byte_size)})

	// Creamos un transfer_buffer, es un buffer especial desde el que podemos copiar datos al GPU buffer.
	transfer_buffer := sdl.CreateGPUTransferBuffer(
		gpu,
		{usage = .UPLOAD, size = u32(vertices_byte_size + indices_byte_size)},
	)

	// Pedimos la memoria a la que vamos a pasar nuestros datos, y la pasamos, tras esto podemos llamar a Unmap
	transfer_memory := transmute([^]byte)sdl.MapGPUTransferBuffer(gpu, transfer_buffer, false)
	mem.copy(transfer_memory, raw_data(vertices), vertices_byte_size)
	mem.copy(transfer_memory[vertices_byte_size:], raw_data(indices), indices_byte_size)
	sdl.UnmapGPUTransferBuffer(gpu, transfer_buffer)


	// Para enviar ordenes necesitamos un command buffer, la orden es enviar la memoria de transfer buffer al buffer de la GPU, 
	// para ello necesitamos un copy_pass
	copy_cmd_buffer := sdl.AcquireGPUCommandBuffer(gpu)
	copy_pass := sdl.BeginGPUCopyPass(copy_cmd_buffer)
	sdl.UploadToGPUBuffer(
		copy_pass,
		{transfer_buffer = transfer_buffer},
		{buffer = vertex_buffer, size = u32(vertices_byte_size)},
		false,
	)
	sdl.UploadToGPUBuffer(
		copy_pass,
		{transfer_buffer = transfer_buffer, offset = u32(vertices_byte_size)},
		{buffer = index_buffer, size = u32(indices_byte_size)},
		false,
	)

	sdl.UploadToGPUTexture(
		copy_pass,
		{transfer_buffer = tex_transfer_buffer},
		{texture = pixels_texture, w = u32(img_size.x), h = u32(img_size.y), d = 1},
		false,
	)

	sdl.EndGPUCopyPass(copy_pass)

	ok = sdl.SubmitGPUCommandBuffer(copy_cmd_buffer);assert(ok)

	// Ya hemos terminado con el transfer_buffer, asi que lo liberamos.
	sdl.ReleaseGPUTransferBuffer(gpu, transfer_buffer)
	sdl.ReleaseGPUTransferBuffer(gpu, tex_transfer_buffer)

	// Create a sampler for shader
	sampler := sdl.CreateGPUSampler(gpu, {})

	// Describimos nuestros datos, en este caso decimos que vamos a pasar dos datos en esas localizaciones(las definimos en nuestros shaders), 
	// tendran ese tamaño (3/4 floats), y tendran un offset de eso.
	vertex_attributes := []sdl.GPUVertexAttribute {
		{location = 0, format = .FLOAT3, offset = u32(offset_of(Vertex_Data, pos))},
		{location = 1, format = .FLOAT4, offset = u32(offset_of(Vertex_Data, color))},
		{location = 2, format = .FLOAT2, offset = u32(offset_of(Vertex_Data, uv))},
	}


	// Creamos un GPUGraphicsPipelineCreateInfo con los datos de nuestros shaders.
	pipeline := sdl.CreateGPUGraphicsPipeline(
	gpu,
	{
		vertex_shader = vertex_shader,
		fragment_shader = fragment_shader,
		primitive_type = .TRIANGLELIST,
		// Creamos GPUVertexInputState que da informacion de nuestro vertex buffer.
		vertex_input_state = {
			num_vertex_buffers = 1,
			vertex_buffer_descriptions = &(sdl.GPUVertexBufferDescription {
					slot = 0,
					pitch = size_of(Vertex_Data),
				}),
			num_vertex_attributes = u32(len(vertex_attributes)),
			vertex_attributes = raw_data(vertex_attributes),
		},
		// Creamos GPUGraphicsPipelineTargetInfo que define el color de nuestros pixeles.
		target_info = {
			num_color_targets = 1,
			color_target_descriptions = &(sdl.GPUColorTargetDescription {
					format = sdl.GetGPUSwapchainTextureFormat(gpu, window),
				}),
		},
	},
	)
	// Una vez hayamos hecho el binding con la pipeline, podemos liberarlos.
	sdl.ReleaseGPUShader(gpu, vertex_shader)
	sdl.ReleaseGPUShader(gpu, fragment_shader)


	// Creamos una matriz de projeccion.
	window_size: [2]i32
	ok = sdl.GetWindowSize(window, &window_size.x, &window_size.y);assert(ok)
	proj_mat := linalg.matrix4_perspective_f32(
		70,
		f32(window_size.x) / f32(window_size.y),
		0.1,
		1000,
	)
	ROTATION_SPEED := linalg.to_radians(f32(90))
	rotation := f32(0)

	UBO :: struct {
		mvp: matrix[4, 4]f32,
	}


	last_tick := sdl.GetTicks()

	main_loop: for {

		current_tick := sdl.GetTicks()
		delta_time := f32(current_tick - last_tick) / 1000
		last_tick = current_tick


		event: sdl.Event
		for sdl.PollEvent(&event) {
			#partial switch event.type {
			case .QUIT:
				break main_loop
			case .KEY_DOWN:
				if event.key.scancode == .ESCAPE || event.key.scancode == .Q do break main_loop
			}
		}


		// GAME STATE
		// RENDER
		// Creamos un buffer de comandos, encargado de enviar ordenes a la GPU.
		cmd_buf := sdl.AcquireGPUCommandBuffer(gpu)

		// WARN: Chekear esta swapchain texture definicion
		// Swapchain texture es una textura que con el contenido de una ventana..
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
			linalg.matrix4_translate_f32({0, 0, -5}) *
			linalg.matrix4_rotate_f32(rotation, {0, 1, 0})
		ubo := UBO {
			mvp = proj_mat * model_mat,
		}

		// Seria null si la ventana estubiera minimizada.
		if swapchain_tex != nil {
			log.debug("Rendering")
			color_target := sdl.GPUColorTargetInfo {
				texture     = swapchain_tex,
				load_op     = .CLEAR,
				clear_color = {0, 0.2, 0.5, 1},
				store_op    = .STORE,
			}
			// Empezamos el proceso de pasar datos a nuestra GPU, debemos bindearlo a la pipeline.
			render_pass := sdl.BeginGPURenderPass(cmd_buf, &color_target, 1, nil)

			sdl.BindGPUGraphicsPipeline(render_pass, pipeline)
			sdl.BindGPUVertexBuffers(
				render_pass,
				0,
				&(sdl.GPUBufferBinding{buffer = vertex_buffer}),
				1,
			)
			sdl.BindGPUIndexBuffer(render_pass, {buffer = index_buffer}, ._16BIT)
			// Este 0 es el slot_index, hace referencia al binding = 0  en el vertex shader.
			sdl.PushGPUVertexUniformData(cmd_buf, 0, &ubo, size_of(UBO))
			sdl.BindGPUFragmentSamplers(
				render_pass,
				0,
				&(sdl.GPUTextureSamplerBinding{texture = pixels_texture, sampler = sampler}),
				1,
			)
			sdl.DrawGPUIndexedPrimitives(render_pass, 6, 1, 0, 0, 0)
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
	num_samplers: u32,
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
			num_samplers = num_samplers,
		},
	)
}
