extends SceneTree

var passed := 0
var failed := 0
var directory := ""
var preview_path := ""


func _initialize() -> void:
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--preview="):
			preview_path = argument.trim_prefix("--preview=")
	call_deferred("_run")


func _run() -> void:
	var watchdog := create_timer(30)
	watchdog.timeout.connect(func() -> void:
		push_error("UI test timeout")
		quit(1)
	)
	if DisplayServer.get_name() == "headless":
		root.size = Vector2i(1280, 900)
	else:
		DisplayServer.window_set_size(Vector2i(1280, 900))
	directory = "user://ui-tests-%d" % OS.get_process_id()
	check(DirAccess.make_dir_absolute(directory) == OK, "Create isolated UI directory")
	var path := directory.path_join("session.json")
	var scene: PackedScene = load("res://main.tscn")
	var app = scene.instantiate()
	app.save_path = path
	root.add_child(app)
	await process_frame
	await process_frame
	check(not app.case_data.is_empty(), "Main scene loads case")
	check(app.evidence_list.item_count == 6, "Six source controls available")
	check(app.timeline_list.item_count == 9, "Nine timeline entries")
	check(app.help_dialog.visible and app.help_text.text.contains("YOUR ROLE") and app.help_text.text.contains("START HERE"), "New session opens mission and first-action guide")
	check(app.help_text.text.contains("HOW TO FINISH") and app.help_text.text.contains("NEEDS SUPPORT"), "Help explains feedback and completion")
	check(not app.help_text.text.contains("lookout and delivery") and not app.help_text.text.contains("relay outage"), "Mission guide does not reveal accepted conclusions")
	await capture_preview("-mission")
	app.help_dialog.hide()
	var before_help: Dictionary = app.state.duplicate(true)
	app._show_help()
	check(app.help_dialog.visible and app.state.recursive_equal(before_help, 8), "Help reopens without changing investigation progress")
	app.help_dialog.hide()
	check(app.review_button.disabled and app.progress_label.text.contains("Not submitted"), "Fresh case does not claim graded progress")
	app._submit()
	check(app.feedback.text.contains("INCOMPLETE"), "Incomplete UI submission explains missing answer")
	check(app.result_dialog.visible and app.progress_label.text.contains("0 of 3") and app.result_text.text.contains("Submitted, but NOT COMPLETE"), "Incomplete submission shows visible zero-count result")
	app.result_dialog.hide()
	for index in range(5, -1, -1):
		app.evidence_list.item_selected.emit(index)
		check(app.reader.text == app.case_data["evidence"][index]["body"], "Reverse discovery opens source %d" % index)
		app.pin_button.pressed.emit()
	check(app.state["pinned"].size() == 6, "All sources pinned without discovery-order gating")
	for index in range(6):
		app.evidence_list.item_selected.emit(index)
		check(app.reader.text == app.case_data["evidence"][index]["body"], "Forward discovery opens source %d" % index)
	app.map_view.observation_selected.emit(3)
	check(app.selected_evidence == "lookout" and app.timeline_list.is_selected(3), "Map selection synchronizes timeline and document")
	app.timeline_list.item_selected.emit(7)
	check(app.selected_evidence == "relay" and app.map_view.selected_index == 7, "Timeline selection synchronizes map and reader")
	var old_zoom: float = app.map_view.zoom
	app.map_view.zoom_by(1.15)
	check(app.map_view.zoom > old_zoom, "Map zoom changes")
	app.map_view.pan = Vector2(25, 30)
	app.map_view.reset_view()
	check(app.map_view.pan == Vector2.ZERO and app.map_view.zoom == 1.0, "Map reset restores transform")
	var press := InputEventMouseButton.new()
	press.button_index = MOUSE_BUTTON_LEFT
	press.pressed = true
	press.position = app.map_view.plot_rect().position + Vector2(1, 1)
	app.map_view._gui_input(press)
	var motion := InputEventMouseMotion.new()
	motion.relative = Vector2(15, 10)
	app.map_view._gui_input(motion)
	press.pressed = false
	app.map_view._gui_input(press)
	check(app.map_view.pan == Vector2(15, 10) and not app.map_view.dragging, "Map input pans and releases drag")
	app.map_view.reset_view()

	for finding in app.case_data["findings"]:
		var options: OptionButton = app.finding_options[finding["id"]]
		for index in range(finding["options"].size()):
			if finding["options"][index]["id"] == finding["accepted"]:
				options.select(index + 1)
				options.item_selected.emit(index + 1)
	app._submit()
	check(app.feedback.text.contains("NEEDS SUPPORT"), "Right answers without evidence need support")
	check(app.feedback.text.contains("03 / Lookout entry") and not app.feedback.text.contains("cite: lookout"), "Missing citations use visible source titles, not internal IDs")
	app.result_dialog.hide()
	for finding in app.case_data["findings"]:
		for checkbox in app.citation_boxes[finding["id"]].get_children():
			for evidence in app.case_data["evidence"]:
				if checkbox.text == evidence["title"] and evidence["id"] in finding["required_evidence"]:
					checkbox.button_pressed = true
		if finding["id"] == "stop":
			app._submit()
			check(app.progress_label.text.contains("1 of 3") and app.result_dialog.visible, "Partial submission reports one supported finding")
			app.result_dialog.hide()
	app.notes.text = "Reviewed the gap; intent remains unproven."
	app.notes.text_changed.emit()
	check(app.state["notes"] == app.notes.text, "Notes edit signal updates saved state")
	app._next_hint()
	app.confidence.select(2)
	app.confidence.item_selected.emit(2)
	await create_timer(0.9).timeout
	var autosaved := JSON.new()
	check(autosaved.parse(FileAccess.get_file_as_string(path)) == OK and autosaved.data["notes"] == app.notes.text, "Debounced autosave persists notes without manual Save")
	app._submit()
	check(app.feedback.text.begins_with("INVESTIGATION COMPLETE"), "Supported assessment debrief through actual controls")
	check(app.result_dialog.visible and app.result_dialog.title == "Investigation complete" and app.progress_label.text.contains("3 of 3"), "Completion cannot be missed inside scrolling findings")
	await capture_preview("-complete")
	app.result_dialog.hide()
	app.review_button.pressed.emit()
	check(app.result_dialog.visible and app.result_text.text.contains("finished this case"), "Persistent review button reopens completion debrief")
	app.result_dialog.hide()
	app.evidence_list.item_selected.emit(2)
	app.pin_button.pressed.emit()
	check("lookout" not in app.state["citations"]["stop"], "Unpin removes stale citation")
	check(not app.feedback.text.begins_with("INVESTIGATION COMPLETE"), "Changed evidence invalidates debrief")
	check(app.review_button.disabled and not app.state["assessment_submitted"] and not app.progress_label.text.contains("3 of 3"), "Changed evidence clears stale completion and submission flag")
	app.pin_button.pressed.emit()
	app._citation_toggled(true, "stop", "lookout")
	app._submit()
	check(app._save(), "Save integrated state")
	var expected: Dictionary = JSON.parse_string(JSON.stringify(app.state))
	root.remove_child(app)
	app.queue_free()
	await process_frame
	app = scene.instantiate()
	app.save_path = path
	root.add_child(app)
	await process_frame
	await process_frame
	check(app.state.recursive_equal(expected, 8), "Restart restores all saved fields")
	check(app.notes.text.contains("intent remains") and app.confidence.selected == 2, "Restored notes and confidence displayed")
	check(app.hint_label.text.contains("observation"), "Restored hints displayed")
	check(app.progress_label.text.contains("3 of 3") and not app.review_button.disabled, "Reload reconstructs submitted completion without resubmission")
	check(not app.help_dialog.visible and not app.result_dialog.visible, "Returning player is not interrupted by first-launch dialogs")
	app._submit()
	check(app.feedback.text.begins_with("INVESTIGATION COMPLETE"), "Restored assessment still supported")
	app.result_dialog.hide()

	if DisplayServer.get_name() == "headless":
		root.size = Vector2i(1280, 900)
	else:
		DisplayServer.window_set_size(Vector2i(1280, 900))
	await process_frame
	await process_frame
	check(root.size == Vector2i(1280, 900), "Layout evaluated at target window size")
	var window_bounds := Rect2(Vector2.ZERO, Vector2(root.size))
	check(window_bounds.encloses(root.get_final_transform() * app.evidence_list.get_global_rect()), "Source list fits target viewport")
	check(window_bounds.encloses(root.get_final_transform() * app.notes.get_global_rect()), "Notes fit target viewport")
	check(window_bounds.encloses(root.get_final_transform() * app.progress_label.get_global_rect()), "Completion progress stays visible outside the scrolling form")
	check(window_bounds.encloses(root.get_final_transform() * app.review_button.get_global_rect()), "Review result control stays visible")
	for options in app.finding_options.values():
		var scroll: ScrollContainer = options.get_parent().get_parent()
		scroll.ensure_control_visible(options)
		await process_frame
		await process_frame
		check(scroll.get_global_rect().encloses(options.get_global_rect()), "Assessment finding reachable within scrolling viewport")
	var form_scroll: ScrollContainer = app.feedback.get_parent().get_parent()
	form_scroll.ensure_control_visible(app.feedback)
	await process_frame
	var debrief_rect: Rect2 = root.get_final_transform() * app.feedback.get_global_rect()
	check(debrief_rect.position.x >= 0 and debrief_rect.end.x <= root.size.x, "Debrief fits viewport width")
	form_scroll.scroll_vertical = 0
	app._show_licenses()
	var license_dialog: AcceptDialog = app.get_child(app.get_child_count() - 1)
	check(license_dialog.visible and license_dialog.get_child(0).text.contains("Permission is hereby granted") and license_dialog.get_child(0).text.contains("Natural Earth"), "Engine and geography notices accessible")
	license_dialog.hide()
	license_dialog.confirmed.emit()
	await process_frame
	await capture_preview("")

	app.state.erase("assessment_submitted")
	check(app._save(), "Write backward-compatible legacy save fixture")
	root.remove_child(app)
	app.queue_free()
	await process_frame
	app = scene.instantiate()
	app.save_path = path
	root.add_child(app)
	await process_frame
	await process_frame
	check(app.notes.text.contains("intent remains") and app.state["pinned"].size() == 6 and app.finding_options["stop"].selected > 0, "Legacy restart preserves notes, pins and answers")
	check(not app.state["assessment_submitted"] and app.review_button.disabled, "Legacy save is unsubmitted, not silently declared complete")

	app.reset_dialog.popup_centered()
	check(app.reset_dialog.visible and app.state["notes"] != "", "Reset requires confirmation")
	app.reset_dialog.hide()
	var before_reset: Dictionary = app.state.duplicate(true)
	var original_file := FileAccess.get_file_as_string(path)
	app.save_path = directory.path_join("missing").path_join("session.json")
	app.reset_dialog.confirmed.emit()
	check(app.state.recursive_equal(before_reset, 8) and app.status_label.text.contains("RESET FAILED"), "Failed reset preserves in-memory progress and displays error")
	check(FileAccess.get_file_as_string(path) == original_file, "Failed reset preserves original save")
	app.save_path = path
	app.reset_dialog.confirmed.emit()
	check(app.state["pinned"].is_empty() and app.state["notes"] == "", "Confirmed reset clears progress")
	check(not app.state["assessment_submitted"] and app.review_button.disabled and app.help_dialog.visible, "Reset clears completion and offers mission guide again")
	app.help_dialog.hide()
	root.remove_child(app)
	app.queue_free()
	await process_frame
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string("{corrupt")
	file.close()
	app = scene.instantiate()
	app.save_path = path
	root.add_child(app)
	await process_frame
	check(app.save_blocked and app.status_label.text.contains("SAVE LOCKED"), "Corrupt save visibly locks writes")
	check(not app._save() and FileAccess.get_file_as_string(path) == "{corrupt", "Locked save preserves original")
	app._reset_case()
	check(not app.save_blocked and FileAccess.get_file_as_string(path + ".backup") == "{corrupt", "Explicit reset backs up unreadable save")
	check(app.state["pinned"].is_empty(), "Recovered session is fresh")
	root.remove_child(app)
	app.queue_free()
	await process_frame
	for filename in ["session.json", "session.json.tmp", "session.json.backup"]:
		DirAccess.remove_absolute(directory.path_join(filename))
	check(DirAccess.remove_absolute(directory) == OK, "Clean up isolated UI save files")
	print("UI TESTS: %d passed, %d failed" % [passed, failed])
	quit(1 if failed else 0)


func capture_preview(suffix: String) -> void:
	if preview_path.is_empty() or DisplayServer.get_name() == "headless":
		return
	for frame in range(4):
		await process_frame
	var image := root.get_texture().get_image()
	var path := preview_path.get_basename() + suffix + ".png"
	check(image.save_png(path) == OK, "Save game-only viewport preview " + suffix)


func check(condition: bool, description: String) -> void:
	if condition:
		passed += 1
	else:
		failed += 1
		push_error("FAIL: " + description)
