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
		push_error("Three-case test timeout")
		quit(1)
	)
	if DisplayServer.get_name() == "headless":
		root.size = Vector2i(1280, 900)
	else:
		DisplayServer.window_set_size(Vector2i(1280, 900))
	var directory := "user://campaign-tests-%d" % OS.get_process_id()
	check(DirAccess.make_dir_absolute(directory) == OK, "Create isolated campaign save directory")
	var path := directory.path_join("session.json")
	var scene: PackedScene = load("res://main.tscn")
	var app = scene.instantiate()
	app.save_path = path
	root.add_child(app)
	await settle()
	app.help_dialog.hide()
	check(app.case_picker.item_count == 3 and app.case_index == 0, "All three cases selectable; restart defaults to introductory case")
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
	check(app.result_text.text.contains("Continue to Case 3") and app.continue_button.visible and not app.continue_button.disabled, "Second-case completion offers the included third case")
	check(app.feedback.text.contains("00:20 UTC") and app.feedback.text.contains("different vessels"), "Debrief explains time conversion and identity limits")
	for control in [app.notes, app.status_label.get_parent()]:
		check(window_bounds.encloses(root.get_final_transform() * control.get_global_rect()), "Completed seven-source notebook leaves notes and footer reachable")
	await capture_preview("-complete")
	app.result_dialog.hide()
	app.evidence_list.item_selected.emit(2)
	check(app.document_source.text.contains("Archive processed: 08:45 UTC") and not app.reader.text.contains("00:20"), "Image header identifies archive processing without pre-solving capture time")
	app.evidence_list.item_selected.emit(3)
	check(app.document_source.text.contains("Setting card copied: 08:50 UTC") and app.reader.text.contains("eight hours AHEAD"), "Clock card separates copy time from the camera convention")
	for index in range(2):
		app._next_hint()
	check(app.state["hint_count"] == 4 and app.hint_label.text.contains("Finding 2 / choose the event") and app.hint_label.text.contains("Finding 2 / convert and cite"), "All hints form explicit event/conversion/citation steps")
	await settle()
	for control in [app.notes, app.status_label.get_parent()]:
		check(window_bounds.encloses(root.get_final_transform() * control.get_global_rect()), "Clock metadata and all hints leave notes and footer reachable")
	await capture_preview("-clock")
	var time_options: OptionButton = app.finding_options["capture_time"]
	time_options.select(1)
	time_options.item_selected.emit(1)
	app.pin_button.pressed.emit()
	app._submit()
	check(app.progress_label.text.contains("2 of 3") and app.result_text.text.contains("Submitted, but NOT COMPLETE"), "Wrong timestamp is not mistaken for completed investigation")
	check(app.result_text.text.contains("REVISE. Change") and app.result_text.text.contains("CITATIONS STILL NEEDED for this finding: 04 / Q4 camera setting card"), "Wrong answer feedback also identifies missing unpinned support")
	check(app.result_text.text.contains("Pin source to notebook") and app.result_text.text.contains("does not update until you resubmit"), "Feedback explains pin, cite and resubmit actions")
	await capture_preview("-needs-review")
	app.result_dialog.hide()
	time_options.select(3)
	time_options.item_selected.emit(3)
	app._submit()
	check(app.result_text.text.contains("NEEDS SUPPORT. Your answer is correct") and app.progress_label.text.contains("2 of 3"), "Correcting answer alone still explicitly needs the missing citation")
	app.result_dialog.hide()
	app.pin_button.pressed.emit()
	app._citation_toggled(true, "capture_time", "clock")
	app._submit()
	check(app.progress_label.text.contains("3 of 3") and app.result_dialog.title == "Investigation complete", "Correct, pin, cite and resubmit resolves the previously unsupported finding")
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
	check(app.state.recursive_equal(expected, 8) and app.state["hint_count"] == 4, "Second notes, citations, all hints and corrected result restore independently")
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
	if app.cases.size() == 3:
		app = await third_case_journey(app, scene, path, window_bounds)
	root.remove_child(app)
	app.queue_free()
	await settle()
	for suffix in ["", "-case-02", "-case-03"]:
		for extension in [".json", ".json.tmp", ".json.backup"]:
			DirAccess.remove_absolute(directory.path_join("session" + suffix + extension))
	check(DirAccess.remove_absolute(directory) == OK, "Clean up isolated three-case save fixtures")
	print("CAMPAIGN TESTS: %d passed, %d failed" % [passed, failed])
	quit(1 if failed else 0)


func third_case_journey(app, scene: PackedScene, path: String, window_bounds: Rect2):
	app._request_case(2)
	await settle()
	check(app.case_index == 2 and app.case_data["id"] == "echoed-warning" and app.state["notes"].is_empty(), "Third case is directly selectable before first-case completion")
	check(app.session_path(2) == path.get_basename() + "-case-03.json", "Third slot preserves both existing save paths")
	check(app.evidence_list.item_count == 6 and app.timeline_list.item_count == 8, "Third desk exposes all six sources and eight UTC events")
	check(app.help_dialog.visible and app.help_text.text.contains("Desk review request") and app.help_text.text.contains("no mapped vessel observations"), "Third guide names its own mission and context-only map")
	check(app.map_context_label.text.contains("no mapped vessel observations") and not app.map_context_label.text.contains("gap"), "Third map does not claim a tracking gap or route")
	check(not app.continue_button.visible, "Last case does not offer a nonexistent next case")
	app.help_dialog.hide()
	for index in range(8):
		app.timeline_list.item_selected.emit(index)
		check(app.selected_evidence == app.case_data["timeline"][index]["evidence_id"], "Every unpositioned timeline event still opens its source")
	for index in range(6):
		app.evidence_list.item_selected.emit(index)
		check(app.document_source.text.contains(app.case_data["evidence"][index]["time_label"] + ": "), "Third source header explains timestamp meaning")
	app._request_case(1)
	await settle()
	check(not app.continue_button.disabled and app.continue_button.text == "Continue to Case 3", "Previously completed second case retains earned continuation")
	app.continue_button.pressed.emit()
	await settle()
	check(app.case_index == 2, "Actual second-case Continue button opens third case")
	app.help_dialog.hide()
	support_case(app, true)
	check(app.progress_label.text.contains("3 of 3") and app.result_dialog.visible, "Reverse discovery and all three-source citations complete third case")
	check(app.result_text.text.contains("last included case") and app.result_text.text.contains("No further case") and not app.result_text.text.contains("Continue"), "Final result accurately ends available content without promising another case")
	await capture_preview("-case03-complete")
	app.result_dialog.hide()
	for index in range(4):
		app._next_hint()
	check(app.state["hint_count"] == 4 and app.hint_label.text.contains("02/03/04") and app.hint_label.text.contains("resubmit"), "All four third-case hints explain lineage, scope, independent support and citations")
	var longest := 0
	for index in range(6):
		if app.case_data["evidence"][index]["body"].length() > app.case_data["evidence"][longest]["body"].length():
			longest = index
	app.evidence_list.item_selected.emit(longest)
	await settle()
	check(app.evidence_list.get_item_rect(5).end.y <= app.evidence_list.size.y, "Third-case six-record list has no clipped last row")
	for control in [app.case_picker, app.map_view, app.evidence_list, app.reader, app.notes, app.status_label.get_parent()]:
		check(window_bounds.encloses(root.get_final_transform() * control.get_global_rect()), "Third-case longest source, pins, hints and footer fit target window")
	app.reader.get_v_scroll_bar().value = app.reader.get_v_scroll_bar().max_value
	await settle()
	check(app.reader.get_v_scroll_bar().value + app.reader.get_v_scroll_bar().page >= app.reader.get_v_scroll_bar().max_value - 1, "Full longest third-case source is reachable")
	for options in app.finding_options.values():
		var scroll: ScrollContainer = options.get_parent().get_parent()
		scroll.ensure_control_visible(options)
		await settle()
		check(scroll.get_global_rect().encloses(options.get_global_rect()), "Each third-case finding and citation group is reachable")
	var scroll: ScrollContainer = app.hint_label.get_parent().get_parent()
	scroll.ensure_control_visible(app.hint_label)
	await settle()
	check(app.hint_label.get_global_rect().end.y <= scroll.get_global_rect().end.y + 1, "End of fourth hint can be scrolled into view")
	await capture_preview("-case03-hints")
	scroll.scroll_vertical = 0
	await capture_preview("-case03-desk")
	app.evidence_list.item_selected.emit(3)
	app.pin_button.pressed.emit()
	var options: OptionButton = app.finding_options["origins"]
	options.select(1)
	options.item_selected.emit(1)
	app._submit()
	check(app.progress_label.text.contains("2 of 3") and app.result_text.text.contains("REVISE. Change") and app.result_text.text.contains("04 / Community digest"), "Third wrong answer plus unpinned source explains both repairs")
	await capture_preview("-case03-review")
	app.result_dialog.hide()
	options.select(2)
	options.item_selected.emit(2)
	app._submit()
	check(app.progress_label.text.contains("2 of 3") and app.result_text.text.contains("NEEDS SUPPORT. Your answer is correct"), "Third answer-only repair still needs missing chain citation")
	app.result_dialog.hide()
	app.pin_button.pressed.emit()
	for checkbox in app.citation_boxes["origins"].get_children():
		if checkbox.text == "04 / Community digest":
			checkbox.button_pressed = true
	app._submit()
	check(app.progress_label.text.contains("3 of 3"), "Third pin, cite and resubmit completes repaired chain")
	app.result_dialog.hide()

	var paths: Array[String] = []
	var expected: Array[Dictionary] = []
	for index in range(3):
		app._request_case(index)
		await settle()
		app.help_dialog.hide()
		app.notes.text = "Independent saved notes for case %d." % (index + 1)
		app.notes.text_changed.emit()
		app.confidence.select(index + 1)
		app.confidence.item_selected.emit(index + 1)
		while app.state["hint_count"] < index + 1:
			app._next_hint()
		support_case(app, false)
		app.result_dialog.hide()
		check(app.progress_label.text.contains("3 of 3"), "All cases complete through forward-order controls")
		paths.append(app.session_path(index))
		expected.append(JSON.parse_string(JSON.stringify(app.state)))
	root.remove_child(app)
	app.queue_free()
	await settle()
	app = scene.instantiate()
	app.save_path = path
	root.add_child(app)
	await settle()
	check(app.case_index == 0, "Three-case restart still defaults to first investigation")
	for index in range(3):
		app._request_case(index)
		await settle()
		check(app.state.recursive_equal(expected[index], 8) and app.progress_label.text.contains("3 of 3") and not app.result_dialog.visible, "Each case restores notes, pins, answers, citations, hints, confidence and recomputed result")
	check(app.state["hint_count"] == 4 and app.case_picker.get_item_text(2).contains("Complete"), "Third four-hint completion survives restart")
	app.notes.text = "Third-case unsaved scratch."
	app.notes.text_changed.emit()
	app.save_path = path.get_base_dir().path_join("missing").path_join("session.json")
	app._request_case(0)
	check(app.case_index == 2 and app.switch_dialog.visible, "Third write failure blocks unconfirmed departure")
	app.save_path = path
	app.autosave.stop()
	app.switch_dialog.hide()
	app.switch_dialog.canceled.emit()
	check(app.case_index == 2 and app.notes.text == "Third-case unsaved scratch.", "Cancel third failed switch retains current work")
	app.save_path = path.get_base_dir().path_join("missing").path_join("session.json")
	app._request_case(0)
	app.save_path = path
	app.switch_dialog.confirmed.emit()
	await settle()
	check(app.case_index == 0 and app.state.recursive_equal(expected[0], 8), "Explicit third-case discard resumes untouched first case")
	check(Store.load_session(paths[2], app.cases[2])["state"].recursive_equal(expected[2], 8), "Discarded third scratch was not silently persisted")
	var corrupt := "{corrupt third case"
	var file := FileAccess.open(paths[2], FileAccess.WRITE)
	file.store_string(corrupt)
	file.close()
	app._request_case(2)
	await settle()
	check(app.save_blocked and app.status_label.text.contains("SAVE LOCKED") and app.case_picker.get_item_text(2).contains("Save needs attention"), "Only corrupt third slot is visibly locked")
	var earlier_bytes := [FileAccess.get_file_as_string(paths[0]), FileAccess.get_file_as_string(paths[1])]
	app._request_case(1)
	check(app.switch_dialog.visible and app.case_index == 2, "Locked third slot requires confirmation to leave")
	app.switch_dialog.confirmed.emit()
	await settle()
	check(not app.save_blocked and app.state.recursive_equal(expected[1], 8) and FileAccess.get_file_as_string(paths[2]) == corrupt, "Second case remains usable without overwriting corrupt third original")
	app._request_case(2)
	await settle()
	app._reset_case()
	app.help_dialog.hide()
	check(not app.save_blocked and FileAccess.get_file_as_string(paths[2] + ".backup") == corrupt, "Third reset backs up the original and recovers only third slot")
	for index in range(2):
		check(FileAccess.get_file_as_string(paths[index]) == earlier_bytes[index], "Third recovery preserves each earlier slot")
	support_case(app, false)
	check(app.progress_label.text.contains("3 of 3"), "Recovered third case completes in forward order")
	app.result_dialog.hide()
	for index in range(3):
		app._request_case(index)
		await settle()
		var before: Array[String] = []
		for other in range(3):
			before.append(FileAccess.get_file_as_string(paths[other]))
		app._reset_case()
		app.help_dialog.hide()
		check(app.state["notes"].is_empty() and app.state["hint_count"] == 0 and not app.state["assessment_submitted"], "Reset clears only selected case progress")
		for other in range(3):
			if other != index:
				check(FileAccess.get_file_as_string(paths[other]) == before[other], "Reset leaves each other save byte-identical immediately before/after")
	return app


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
	check(root.get_texture().get_image().save_png(preview_path.get_basename() + suffix + ".png") == OK, "Capture campaign game-only preview")


func check(condition: bool, description: String) -> void:
	if condition:
		passed += 1
	else:
		failed += 1
		push_error("FAIL: " + description)
