extends SceneTree

const Rules = preload("res://scripts/survey_rules.gd")
const Seabed = preload("res://scripts/seabed.gd")
var passed := 0
var failed := 0
var preview := ""


func _initialize() -> void:
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--preview="):
			preview = argument.trim_prefix("--preview=")
	call_deferred("_run")


func check(condition: bool, label: String) -> void:
	if condition:
		passed += 1
	else:
		failed += 1
		push_error("FAIL: " + label)


func _run() -> void:
	create_timer(90).timeout.connect(func() -> void:
		push_error("Cable scene test timeout")
		quit(1)
	)
	if not ResourceLoader.exists("res://scripts/main.gd"):
		check(false, "Playable scene implementation exists")
		quit(1)
		return
	var script: Script = load("res://scripts/main.gd")
	var directory := "user://scene-tests-%d" % OS.get_process_id()
	var app: Node3D = script.new()
	app.save_path = directory.path_join("session.json")
	root.add_child(app)
	await process_frame
	await process_frame
	app.set_physics_process(false)
	app.help_dialog.hide()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	check(app.startup_error.is_empty(), "Scene starts without errors")
	check(app.phase == "deck", "New session starts on deck")
	check(app.deck.visible and not app.survey_world.visible, "Only deck visible initially")
	check(app.deck_camera.current, "Deck camera active")
	check(app.environment.environment.volumetric_fog_enabled == false, "No underwater fog on deck")
	check(app.console_distance() > 3.0, "Start requires walking to console")
	await snapshot(app, "deck")
	app.interact_console()
	check(app.phase == "deck", "Console cannot be used across the deck")
	app.deck_camera.position = Vector3(0, 1.75, 2)
	app.sync_camera()
	await snapshot(app, "console")
	app.interact_console()
	check(app.console_dialog.visible, "Nearby console opens")
	app.console_dialog.hide()
	app.launch_survey()
	check(app.phase == "survey" and app.rov_camera.current, "Launch switches to ROV")
	check(not app.deck.visible and app.survey_world.visible, "Only underwater world visible")
	check(Seabed.is_inside_bounds(app.rov_position), "Start position inside survey box")
	check(app.instruments()["depth"] > 400, "Depth reads actual meters below sea level")
	var start: Vector3 = app.rov_position
	app.step_pilot({"forward": 1.0}, 0.25)
	check(app.rov_position.distance_to(start) > 0.01, "Presentation uses real thrust model")
	app.depth_hold = true
	app.hold_y = app.rov_position.y
	app.step_pilot({}, 0.1)
	check(Seabed.is_inside_bounds(app.rov_position), "Depth hold respects floor and bounds")
	app.return_to_deck()
	check(app.phase == "deck", "Recovery returns to deck")
	app.launch_survey()
	check(app.rov_position.distance_to(start) > 0, "Same-session relaunch retains ROV progress")

	for feature in app.survey["features"]:
		var id: String = feature["id"]
		var target := Seabed.feature_position(feature)
		app.rov_position = Seabed.clamp_to_bounds(target + Vector3(0, 2.0, 3.8))
		app.rov_velocity = Vector3.ZERO
		app.rov_yaw = 0.0
		app.rov_pitch = -atan2(app.rov_position.y - target.y, 3.8)
		app.sync_camera()
		await process_frame
		await snapshot(app, id)
		check(app.capture_candidate() == id, "Only framed target selected: " + id)
		if DisplayServer.get_name() != "headless":
			await app.capture_frame()
			check(Rules.captured_ids(app.session).has(id), "Real viewport capture recorded: " + id)
			var captured: Dictionary = app.session["captures"].back()
			var file_path: String = app.frame_path(captured)
			var image := Image.new()
			check(image.load(file_path) == OK and image.get_width() >= 1000, "Actual PNG saved: " + id)
		else:
			Rules.add_capture(app.session, app.survey, id, app.rov_position, -app.rov_camera.global_basis.z, 10.0)
		var before: int = app.session["captures"].size()
		Rules.add_capture(app.session, app.survey, id, app.rov_position, -app.rov_camera.global_basis.z, 10.0)
		check(app.session["captures"].size() == before, "Duplicate capture does not grow log")
	app.return_to_deck()
	app.open_assessment()
	check(app.assessment_dialog.visible, "Review opens from console")
	check(app.answer_controls.size() == 2, "Two findings rendered")
	check(app.gallery.get_item_count() == 4, "Gallery lists every captured feature")
	app.gallery.select(1)
	app.gallery.item_selected.emit(1)
	check(app.gallery_description.text.contains("netting"), "Gallery opens corresponding observation")
	await snapshot(app, "assessment")
	for finding in app.survey["findings"]:
		var id: String = finding["id"]
		var choices: OptionButton = app.answer_controls[id]
		choices.select(1)
		choices.item_selected.emit(1)
	app.submit_assessment()
	check(app.result_label.text.contains("0 / 2"), "Correct answers alone do not complete")
	check(app.result_label.text.contains("Cite"), "Missing evidence feedback is actionable")
	for finding in app.survey["findings"]:
		var id: String = finding["id"]
		for citation in finding["required_citations"]:
			var box: CheckBox = app.citation_controls[id][citation]
			box.button_pressed = true
			box.toggled.emit(true)
	app.answer_controls["mechanism"].select(2)
	app.answer_controls["mechanism"].item_selected.emit(2)
	app.submit_assessment()
	check(app.result_label.text.contains("Revise"), "Wrong answer and citations still require revision")
	app.answer_controls["mechanism"].select(1)
	app.answer_controls["mechanism"].item_selected.emit(1)
	app.submit_assessment()
	check(app.result_label.text.contains("SURVEY COMPLETE"), "Correct citations and answers complete")
	check(bool(Rules.evaluate(app.session, app.survey)["all_supported"]), "UI writes same domain state")
	app.show_hint()
	check(app.session["hint_count"] == 1, "Hint use persists independently")
	await snapshot(app, "complete")
	app.assessment_dialog.hide()
	app.return_to_deck()
	check(app.persist(), "State saved")
	var state: Dictionary = app.session.duplicate(true)
	app.queue_free()
	await process_frame
	app = script.new()
	app.save_path = directory.path_join("session.json")
	root.add_child(app)
	await process_frame
	app.set_physics_process(false)
	app.help_dialog.hide()
	check(app.session["captures"].size() == 4, "Capture log survives scene restart")
	check(bool(Rules.evaluate(app.session, app.survey)["all_supported"]), "Completion recomputed after restart")
	check(app.session["answers"] == state["answers"], "Answers survive restart")
	app.reset_dialog.popup_centered()
	app.reset_dialog.canceled.emit()
	app.reset_dialog.hide()
	check(app.session["captures"].size() == 4, "Cancel reset preserves progress")
	app.reset_session()
	check(app.session["captures"].is_empty() and app.phase == "deck", "Confirmed reset clears only this survey")
	var file := FileAccess.open(app.save_path, FileAccess.WRITE)
	file.store_string("{broken")
	file.close()
	app.queue_free()
	await process_frame
	app = script.new()
	app.save_path = directory.path_join("session.json")
	root.add_child(app)
	await process_frame
	app.set_physics_process(false)
	check(app.save_locked, "Corrupt save enters protected mode")
	check(not app.persist(), "Protected mode cannot overwrite original")
	check(FileAccess.get_file_as_string(app.save_path) == "{broken", "Original bytes preserved")
	app.reset_session()
	check(not app.save_locked and app.startup_error.is_empty(), "Explicit backup/reset recovers protected session")
	app.queue_free()
	await process_frame
	cleanup(directory)
	print("SCENE TESTS: %d passed, %d failed; rendered frames: %s" % [passed, failed, DisplayServer.get_name() != "headless"])
	quit(0 if failed == 0 else 1)


func snapshot(app: Node3D, label: String) -> void:
	if preview.is_empty() or DisplayServer.get_name() == "headless":
		return
	await RenderingServer.frame_post_draw
	var path := preview + "-" + label + ".png"
	check(app.get_viewport().get_texture().get_image().save_png(path) == OK, "Viewport saved: " + label)


func cleanup(directory: String) -> void:
	var dir := DirAccess.open(directory)
	if dir == null:
		return
	for name in dir.get_files():
		DirAccess.remove_absolute(directory.path_join(name))
	var captures := directory.path_join("captures")
	var images := DirAccess.open(captures)
	if images != null:
		for name in images.get_files():
			DirAccess.remove_absolute(captures.path_join(name))
		DirAccess.remove_absolute(captures)
	DirAccess.remove_absolute(directory)
