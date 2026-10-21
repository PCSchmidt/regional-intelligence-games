extends SceneTree

const Seabed = preload("res://scripts/seabed.gd")
var app: Node3D
var samples: Array[float] = []
var max_draws := 0
var max_triangles := 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	if DisplayServer.get_name() == "headless":
		push_error("Benchmark requires actual Forward+ rendering.")
		quit(1)
		return
	create_timer(120).timeout.connect(func() -> void: quit(1))
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	Engine.max_fps = 0
	root.size = Vector2i(1920, 1080)
	var directory := "user://benchmark-%d" % OS.get_process_id()
	app = load("res://scripts/main.gd").new()
	app.save_path = directory.path_join("session.json")
	root.add_child(app)
	app.set_physics_process(false)
	app.help_dialog.hide()
	app.launch_survey()
	app.release_mouse()
	var warmup_start := Time.get_ticks_usec()
	while Time.get_ticks_usec() - warmup_start < 5000000:
		position_camera(int((Time.get_ticks_usec() - warmup_start) * 1200 / 5000000.0))
		await process_frame
		await RenderingServer.frame_post_draw
	var last := Time.get_ticks_usec()
	var measured_start := last
	while Time.get_ticks_usec() - measured_start < 30000000:
		position_camera(mini(1199, int((Time.get_ticks_usec() - measured_start) * 1200 / 30000000.0)))
		await process_frame
		await RenderingServer.frame_post_draw
		var now := Time.get_ticks_usec()
		samples.append(float(now - last) / 1000000.0)
		last = now
		max_draws = maxi(max_draws, int(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)))
		max_triangles = maxi(max_triangles, int(Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME)))
	var total := 0.0
	for sample in samples:
		total += sample
	samples.sort()
	var slow_total := 0.0
	var slow_count := maxi(1, int(ceil(samples.size() * 0.01)))
	for index in range(slow_count):
		slow_total += samples[samples.size() - 1 - index]
	var result := {
		"viewport": [root.size.x, root.size.y],
		"adapter": RenderingServer.get_video_adapter_name(),
		"renderer": RenderingServer.get_current_rendering_method(),
		"frames": samples.size(), "warmup_seconds": 5, "measured_seconds": total,
		"average_fps": snappedf(samples.size() / total, 0.1),
		"one_percent_low_fps": snappedf(slow_count / slow_total, 0.1),
		"worst_frame_ms": snappedf(samples.back() * 1000.0, 0.01),
		"max_draw_calls": max_draws, "max_rendered_primitives": max_triangles,
		"scope": "Four inspection views plus moving survey overview; no loading, image encoding or dialogs."
	}
	result["throughput_budget_pass"] = root.size == Vector2i(1920, 1080) and result["average_fps"] >= 60 and result["one_percent_low_fps"] >= 30 and max_draws <= 250 and max_triangles <= 400000
	result["strict_30fps_floor_pass"] = samples.back() <= 1.0 / 30.0
	if not result["strict_30fps_floor_pass"]:
		push_warning("Benchmark recorded a frame over 33.33 ms; strict 30 fps floor is not met even if throughput passes.")
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--output="):
			var file := FileAccess.open(argument.trim_prefix("--output="), FileAccess.WRITE)
			if file == null:
				push_error("Cannot write benchmark output.")
				quit(1)
				return
			file.store_string(JSON.stringify(result, "\t") + "\n")
			file.close()
	print("BENCHMARK: " + JSON.stringify(result))
	app.queue_free()
	await process_frame
	DirAccess.remove_absolute(directory.path_join("session.json"))
	DirAccess.remove_absolute(directory)
	quit(0 if result["throughput_budget_pass"] else 1)


func position_camera(frame: int) -> void:
	var segment := floori(float(frame) / 240.0)
	if segment < 4:
		var target := Seabed.feature_position(app.survey["features"][segment])
		app.rov_position = Seabed.clamp_to_bounds(target + Vector3(sin(frame * 0.015), 2.0, 3.8))
		app.rov_camera.position = app.rov_position
		app.rov_camera.look_at(target, Vector3.UP)
	else:
		app.rov_position = Vector3(sin(frame * 0.01) * 20, -405, cos(frame * 0.01) * 20)
		app.rov_camera.position = app.rov_position
		app.rov_camera.look_at(Vector3(0, -419, 0), Vector3.UP)
	app._update_hud()
