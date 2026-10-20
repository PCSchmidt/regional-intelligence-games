extends SceneTree

const Store = preload("res://scripts/save_store.gd")
var passed := 0
var failed := 0
var preview_path := ""


func _initialize() -> void:
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--preview="):
			preview_path = argument.trim_prefix("--preview=")
	call_deferred("_run")


func _run() -> void:
	create_timer(30).timeout.connect(func() -> void:
		push_error("Two-case test timeout")
		quit(1)
	)
	if DisplayServer.get_name() == "headless":
		root.size = Vector2i(1280, 900)
	else:
		DisplayServer.window_set_size(Vector2i(1280, 900))
	var directory := "user://campaign-tests-%d" % OS.get_process_id()
	check(DirAccess.make_dir_absolute(directory) == OK, "Create isolated two-case save directory")
	var path := directory.path_join("session.json")
	var scene: PackedScene = load("res://main.tscn")
	var app = scene.instantiate()
	app.save_path = path
	root.add_child(app)
	await settle()
	app.help_dialog.hide()
	check(app.case_picker.item_count == 2 and app.case_index == 0, "Both cases selectable; restart defaults to introductory case")
	check(app.session_path(0) == path and app.session_path(1) == directory.path_join("session-case-02.json"), "Original save path retained; second case has a separate slot")
	check(app.continue_button.disabled, "Continuation is not advertised as earned before completion")
	app.notes.text = "First case notes preserved across switches."
	app.notes.text_changed.emit()
	app.confidence.select(3)
	app.confidence.item_selected.emit(3)
	app._next_hint()
	support_case(app, false)
	check(not app.continue_button.disabled and app.result_dialog.visible, "First-case completion enables continuation")
	app.result_dialog.hide()
	var first_bytes := FileAccess.get_file_as_string(path)
	app.continue_button.pressed.emit()
	await settle()
	check(app.case_index == 1 and app.case_data["id"] == "borrowed-name", "Continue opens the distinct second investigation")
	check(app.evidence_list.item_count == 7 and app.state["notes"].is_empty(), "Seven source records with independent fresh progress")
	check(app.help_dialog.visible and app.help_text.text.contains("Review request") and not app.help_text.text.contains("Dispatch extract"), "Second-case guide names its own mission and first source")
	check(not app.help_text.text.contains("00:20") and app.help_text.text.contains("clock convention"), "Help does not solve the timestamp or mislabel source clocks")
	check(app.case_picker.get_item_text(0).contains("Complete"), "Selector retains first-case completion")
	app.help_dialog.hide()
	check(app.evidence_list.get_item_rect(6).end.y <= app.evidence_list.size.y, "All seven source rows are visible without clipping")
	var window_bounds := Rect2(Vector2.ZERO, Vector2(root.size))
	for control in [app.case_picker, app.evidence_list, app.notes, app.review_button]:
		check(window_bounds.encloses(root.get_final_transform() * control.get_global_rect()), "Second-case control fits target window")
	for options in app.finding_options.values():
		var scroll: ScrollContainer = options.get_parent().get_parent()
		scroll.ensure_control_visible(options)
		await settle()
		check(scroll.get_global_rect().encloses(options.get_global_rect()), "Second-case finding remains reachable")
	app.feedback.get_parent().get_parent().scroll_vertical = 0
	await capture_preview("")
	app.notes.text = "Second case: compare identity and clock conventions."
	app.notes.text_changed.emit()
	app.confidence.select(1)
	app.confidence.item_selected.emit(1)
	app._next_hint()
	app._next_hint()
	support_case(app, true)
	check(app.progress_label.text.contains("3 of 3") and app.state["assessment_submitted"], "Second case completes after reverse-order discovery and citations")
	check(app.result_text.text.contains("No third case") and not app.continue_button.visible, "Final available case does not promise an unavailable third case")
	check(app.feedback.text.contains("00:20 UTC") and app.feedback.text.contains("different vessels"), "Debrief explains time conversion and identity limits")
	for control in [app.notes, app.status_label.get_parent()]:
		check(window_bounds.encloses(root.get_final_transform() * control.get_global_rect()), "Completed seven-source notebook leaves notes and footer reachable")
	await capture_preview("-complete")
	app.result_dialog.hide()
	var second_path: String = app.session_path(1)
	var expected: Dictionary = JSON.parse_string(JSON.stringify(app.state))
	check(FileAccess.get_file_as_string(path) == first_bytes, "Completing second case leaves first save unchanged")
	app.case_picker.select(0)
	app.case_picker.item_selected.emit(0)
	await settle()
	check(app.notes.text.begins_with("First case") and app.state["hint_count"] == 1 and app.state["confidence"] == "High" and not app.continue_button.disabled, "Switch back restores first notes, hints, confidence and completion")
	app.case_picker.select(1)
	app.case_picker.item_selected.emit(1)
	await settle()
	check(app.state.recursive_equal(expected, 8) and app.state["hint_count"] == 2, "Second notes, citations, hints and result restore independently")
	root.remove_child(app)
	app.queue_free()
	await settle()
	app = scene.instantiate()
	app.save_path = path
	root.add_child(app)
	await settle()
	check(app.case_index == 0 and app.progress_label.text.contains("3 of 3"), "Restart preserves original case completion")
	app._request_case(1)
	await settle()
	check(app.state.recursive_equal(expected, 8) and not app.result_dialog.visible, "Select second case after restart to resume without intrusive result dialog")
	first_bytes = FileAccess.get_file_as_string(path)
	app._reset_case()
	app.help_dialog.hide()
	check(app.state["notes"].is_empty() and FileAccess.get_file_as_string(path) == first_bytes, "Second-case reset leaves first-case saved bytes intact")

	app.notes.text = "Unsaved work must not disappear without confirmation."
	app.notes.text_changed.emit()
	app.save_path = directory.path_join("missing").path_join("session.json")
	app._request_case(0)
	check(app.case_index == 1 and app.switch_dialog.visible and app.pending_case == 0, "Failed save blocks automatic case departure")
	app.save_path = path
	app.autosave.stop()
	app.switch_dialog.hide()
	app.switch_dialog.canceled.emit()
	check(app.case_index == 1 and app.pending_case == -1 and app.notes.text.begins_with("Unsaved work"), "Cancel failed switch keeps current work")
	app.save_path = directory.path_join("missing").path_join("session.json")
	app._request_case(0)
	app.save_path = path
	app.switch_dialog.confirmed.emit()
	await settle()
	check(app.case_index == 0 and app.notes.text.begins_with("First case"), "Explicit leave-without-saving confirmation opens other saved case")
	check(Store.load_session(second_path, app.cases[1])["state"]["notes"].is_empty(), "Discarded scratch note was not silently saved")

	var file := FileAccess.open(second_path, FileAccess.WRITE)
	file.store_string("{corrupt second case")
	file.close()
	app._request_case(1)
	await settle()
	check(app.save_blocked and app.status_label.text.contains("SAVE LOCKED"), "Corrupt second-case save is visibly locked")
	check(app.case_picker.get_item_text(1).contains("Save needs attention"), "Selector exposes case-specific save problem")
	app._request_case(0)
	check(app.switch_dialog.visible and app.case_index == 1, "Leaving locked case also requires explicit confirmation")
	app.switch_dialog.confirmed.emit()
	await settle()
	check(app.case_index == 0 and not app.save_blocked, "Corrupt second slot does not disable first case")
	check(FileAccess.get_file_as_string(second_path) == "{corrupt second case", "Switching away preserves original corrupt file")
	app._request_case(1)
	await settle()
	app._reset_case()
	app.help_dialog.hide()
	check(not app.save_blocked and FileAccess.get_file_as_string(second_path + ".backup") == "{corrupt second case", "Reset backs up only corrupt second slot")
	check(FileAccess.get_file_as_string(path) == first_bytes, "Second-slot recovery does not modify first slot")
	app.notes.text = "Recovered second-case progress."
	app.notes.text_changed.emit()
	support_case(app, false)
	check(app.state["assessment_submitted"] and app.progress_label.text.contains("3 of 3"), "Second case also completes in forward discovery order after recovery")
	app.result_dialog.hide()
	check(app._save(), "Recovered second slot saves normally")
	var second_bytes := FileAccess.get_file_as_string(second_path)
	app._request_case(0)
	await settle()
	app._reset_case()
	app.help_dialog.hide()
	check(FileAccess.get_file_as_string(second_path) == second_bytes, "First-case reset leaves second-case saved bytes intact")
	root.remove_child(app)
	app.queue_free()
	await settle()
	for filename in ["session.json", "session.json.tmp", "session.json.backup", "session-case-02.json", "session-case-02.json.tmp", "session-case-02.json.backup"]:
		DirAccess.remove_absolute(directory.path_join(filename))
	check(DirAccess.remove_absolute(directory) == OK, "Clean up isolated two-case save fixtures")
	print("CAMPAIGN TESTS: %d passed, %d failed" % [passed, failed])
	quit(1 if failed else 0)


func support_case(app, reverse: bool) -> void:
	var indices: Array = range(app.case_data["evidence"].size())
	if reverse:
		indices.reverse()
	for index in indices:
		app.evidence_list.item_selected.emit(index)
		if app.selected_evidence not in app.state["pinned"]:
			app.pin_button.pressed.emit()
	for finding in app.case_data["findings"]:
		var options: OptionButton = app.finding_options[finding["id"]]
		for index in range(finding["options"].size()):
			if finding["options"][index]["id"] == finding["accepted"]:
				options.select(index + 1)
				options.item_selected.emit(index + 1)
		for checkbox in app.citation_boxes[finding["id"]].get_children():
			for evidence in app.case_data["evidence"]:
				if checkbox.text == evidence["title"] and evidence["id"] in finding["required_evidence"]:
					checkbox.button_pressed = true
	app._submit()


func settle() -> void:
	await process_frame
	await process_frame


func capture_preview(suffix: String) -> void:
	if preview_path.is_empty() or DisplayServer.get_name() == "headless":
		return
	await settle()
	await settle()
	check(root.get_texture().get_image().save_png(preview_path.get_basename() + suffix + ".png") == OK, "Capture second-case game-only preview")


func check(condition: bool, description: String) -> void:
	if condition:
		passed += 1
	else:
		failed += 1
		push_error("FAIL: " + description)
