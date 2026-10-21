extends SceneTree

var passed := 0
var failed := 0
var skipped := 0


func _initialize() -> void:
	call_deferred("_run")


func check(condition: bool, label: String, requires_display: bool = false) -> void:
	if requires_display and DisplayServer.get_name() == "headless":
		skipped += 1
		return
	if condition:
		passed += 1
	else:
		failed += 1
		push_error("FAIL: " + label)


func key(code: Key, down: bool) -> void:
	var event := InputEventKey.new()
	event.keycode = code
	event.physical_keycode = code
	event.pressed = down
	Input.parse_input_event(event)
	Input.flush_buffered_events()


func _run() -> void:
	create_timer(45).timeout.connect(func() -> void: quit(1))
	var directory := "user://controls-tests-%d" % OS.get_process_id()
	var app: Node3D = load("res://scripts/main.gd").new()
	app.save_path = directory.path_join("session.json")
	root.add_child(app)
	await process_frame
	app.help_dialog.hide()
	await process_frame
	root.gui_release_focus()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	var start: Vector3 = app.deck_camera.position
	key(KEY_W, true)
	for frame in range(20):
		await physics_frame
	key(KEY_W, false)
	check(app.deck_camera.position.z < start.z - 0.2, "Physical W input walks forward on deck", true)
	app.deck_camera.position = Vector3(0, 1.75, 2)
	key(KEY_E, true)
	await process_frame
	key(KEY_E, false)
	check(app.console_dialog.visible, "Physical E opens nearby console")
	var buttons: Array[Node] = app.console_dialog.find_children("*", "Button", true, false)
	for button in buttons:
		if button.text == "Launch / resume ROV":
			button.pressed.emit()
	check(app.phase == "survey", "Launch button enters survey")
	start = app.rov_position
	key(KEY_W, true)
	for frame in range(30):
		await physics_frame
	key(KEY_W, false)
	check(app.rov_position.z < start.z - 0.05, "Physical W drives ROV through thrust model", true)
	key(KEY_H, true)
	await process_frame
	key(KEY_H, false)
	check(app.depth_hold, "H enables depth hold")
	key(KEY_ESCAPE, true)
	await process_frame
	key(KEY_ESCAPE, false)
	check(Input.mouse_mode == Input.MOUSE_MODE_VISIBLE, "Escape releases mouse")
	start = app.rov_position
	key(KEY_W, true)
	for frame in range(10):
		await physics_frame
	key(KEY_W, false)
	check(app.rov_position == start, "Free cursor blocks accidental thrust")
	key(KEY_TAB, true)
	await process_frame
	key(KEY_TAB, false)
	check(app.phase == "deck" and app.assessment_dialog.visible, "Tab recovers and opens review")
	await process_frame
	check(app.assessment_dialog.position.y >= 0 and app.assessment_dialog.position.y + app.assessment_dialog.size.y <= root.get_visible_rect().size.y, "Assessment fits the stretched viewport", true)
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		for argument in OS.get_cmdline_user_args():
			if argument.begins_with("--preview="):
				check(root.get_texture().get_image().save_png(argument.trim_prefix("--preview=")) == OK, "Save small-window review screenshot")
	app.assessment_dialog.hide()
	app.show_licenses()
	check(app.licenses_dialog.visible and app.dialog_open(), "Bundled engine/asset licenses open and pause input")
	app.licenses_dialog.hide()
	check(app.persist(), "Input-driven session saves")
	var expected: Vector3 = app.rov_position
	app.queue_free()
	await process_frame
	var restored: Node3D = load("res://scripts/main.gd").new()
	restored.save_path = directory.path_join("session.json")
	root.add_child(restored)
	await process_frame
	check(restored.rov_position.distance_to(expected) < 0.01, "Input-driven position persists across scene restart")
	check(restored.phase == "deck", "Recovery phase persists")
	restored.queue_free()
	await process_frame
	DirAccess.remove_absolute(directory.path_join("session.json"))
	DirAccess.remove_absolute(directory)
	check(not DirAccess.dir_exists_absolute(directory), "Isolated control journey cleaned up")
	print("CONTROL TESTS: %d passed, %d failed, %d skipped (headless has no mouse capture or desktop window)" % [passed, failed, skipped])
	quit(0 if failed == 0 else 1)
