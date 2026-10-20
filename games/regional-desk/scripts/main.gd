extends Control

const Rules = preload("res://scripts/case_rules.gd")
const Store = preload("res://scripts/save_store.gd")
const MapView = preload("res://scripts/map_view.gd")

var case_data: Dictionary = {}
var state: Dictionary = {}
var save_path := "user://session.json"
var save_blocked := false
var selected_evidence := ""
var evidence_list: ItemList
var timeline_list: ItemList
var reader: RichTextLabel
var document_title: Label
var document_source: Label
var pin_button: Button
var notebook_label: Label
var notes: TextEdit
var status_label: Label
var feedback: RichTextLabel
var hint_label: Label
var confidence: OptionButton
var reset_dialog: ConfirmationDialog
var autosave: Timer
var map_view := MapView.new()
var finding_options: Dictionary = {}
var citation_boxes: Dictionary = {}


func _ready() -> void:
	var result := Rules.load_case("res://content/case_01.json")
	if result.has("error"):
		_show_fatal(result["error"])
		return
	case_data = result["case"]
	var loaded := Store.load_session(save_path, case_data)
	if loaded.has("error"):
		state = Rules.new_session(case_data)
		save_blocked = true
	else:
		state = loaded["state"]
	_build_interface()
	_restore_form()
	_open_evidence(0)
	if loaded.has("error"):
		_set_status("SAVE LOCKED: " + loaded["error"] + " Use Reset to back it up and start again.", true)
	else:
		_set_status("Local progress ready. Changes autosave; Save is also available.")
	get_tree().auto_accept_quit = false


func _build_interface() -> void:
	var theme_value := Theme.new()
	theme_value.default_font_size = 16
	theme_value.set_color("font_color", "Label", Color("#e0eaf0"))
	theme_value.set_color("default_color", "RichTextLabel", Color("#d6e2e9"))
	theme_value.set_color("font_color", "Button", Color("#e0eaf0"))
	for type_name in ["Button", "OptionButton", "TextEdit", "ItemList"]:
		var style := StyleBoxFlat.new()
		style.bg_color = Color("#132b3a")
		style.border_color = Color("#335364")
		style.set_border_width_all(1)
		style.set_corner_radius_all(5)
		style.content_margin_left = 8
		style.content_margin_right = 8
		style.content_margin_top = 6
		style.content_margin_bottom = 6
		theme_value.set_stylebox("normal", type_name, style)
	theme = theme_value

	var background := ColorRect.new()
	background.color = Color("#09131e")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 18)
	add_child(margin)
	var page := VBoxContainer.new()
	page.add_theme_constant_override("separation", 10)
	margin.add_child(page)
	var header := HBoxContainer.new()
	page.add_child(header)
	var title := _label("REGIONAL ANALYSIS DESK", 25)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)
	header.add_child(_label("CASE 01  /  OFFLINE PROTOTYPE", 14))
	page.add_child(_label(case_data["title"] + "  |  " + case_data["date"] + "  |  UTC", 20))
	page.add_child(_label(case_data["brief"], 16, true))
	var disclaimer := _label(case_data["disclaimer"], 13, true)
	disclaimer.modulate = Color("#e8c58d")
	page.add_child(disclaimer)
	page.add_child(HSeparator.new())

	var columns := HBoxContainer.new()
	columns.add_theme_constant_override("separation", 18)
	columns.size_flags_vertical = Control.SIZE_EXPAND_FILL
	page.add_child(columns)
	var left := _column(columns, 325, 1.0)
	var center := _column(columns, 395, 1.25)
	var right := _column(columns, 365, 1.05)

	left.add_child(_label("LOCATION / OBSERVATIONS", 15))
	var map_toolbar := HBoxContainer.new()
	left.add_child(map_toolbar)
	_button(map_toolbar, "+", func() -> void: map_view.zoom_by(1.15))
	_button(map_toolbar, "-", func() -> void: map_view.zoom_by(1.0 / 1.15))
	_button(map_toolbar, "Reset view", map_view.reset_view)
	map_view.case_data = case_data
	map_view.size_flags_vertical = Control.SIZE_EXPAND_FILL
	left.add_child(map_view)
	map_view.observation_selected.connect(_select_observation)
	left.add_child(_label("Drag to pan / wheel or +/- to zoom", 12))
	left.add_child(_label("TIMELINE / ALL TIMES UTC", 15))
	timeline_list = ItemList.new()
	timeline_list.custom_minimum_size.y = 240
	timeline_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	for event in case_data["timeline"]:
		timeline_list.add_item(event["time"] + "  " + event["label"])
	left.add_child(timeline_list)
	timeline_list.item_selected.connect(_select_observation)

	center.add_child(_label("SOURCE LIBRARY / SIX RECORDS", 15))
	evidence_list = ItemList.new()
	evidence_list.custom_minimum_size.y = 170
	for evidence in case_data["evidence"]:
		evidence_list.add_item(evidence["title"])
	center.add_child(evidence_list)
	evidence_list.item_selected.connect(_open_evidence)
	document_title = _label("", 18, true)
	document_source = _label("", 13, true)
	center.add_child(document_title)
	center.add_child(document_source)
	reader = RichTextLabel.new()
	reader.bbcode_enabled = false
	reader.selection_enabled = true
	reader.custom_minimum_size.y = 185
	reader.size_flags_vertical = Control.SIZE_EXPAND_FILL
	reader.size_flags_stretch_ratio = 1.4
	center.add_child(reader)
	pin_button = _button(center, "Pin source to notebook", _toggle_pin)
	notebook_label = _label("", 13, true)
	center.add_child(notebook_label)
	center.add_child(_label("YOUR NOTES / saved locally", 14))
	notes = TextEdit.new()
	notes.placeholder_text = "What do the sources establish? What remains uncertain?"
	notes.custom_minimum_size.y = 90
	notes.size_flags_vertical = Control.SIZE_EXPAND_FILL
	notes.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	center.add_child(notes)
	notes.text_changed.connect(func() -> void:
		state["notes"] = notes.text
		_mark_dirty()
	)

	right.add_child(_label("FILE AN ASSESSMENT", 15))
	var assessment_scroll := ScrollContainer.new()
	assessment_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	assessment_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right.add_child(assessment_scroll)
	var form := VBoxContainer.new()
	form.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	form.add_theme_constant_override("separation", 10)
	assessment_scroll.add_child(form)
	form.add_child(_label("Choose a finding, then cite pinned sources for that finding.", 14, true))
	for finding in case_data["findings"]:
		var id: String = finding["id"]
		form.add_child(_label(finding["question"], 16, true))
		var options := OptionButton.new()
		options.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		options.add_item("Choose a conclusion...")
		for option in finding["options"]:
			options.add_item(option["label"])
		form.add_child(options)
		finding_options[id] = options
		options.item_selected.connect(_answer_selected.bind(id))
		var citations := VBoxContainer.new()
		form.add_child(citations)
		citation_boxes[id] = citations
		form.add_child(HSeparator.new())
	form.add_child(_label("Confidence / reflection only, not scored", 13, true))
	confidence = OptionButton.new()
	for value in ["Unrecorded", "Low", "Medium", "High"]:
		confidence.add_item(value)
	form.add_child(confidence)
	confidence.item_selected.connect(func(index: int) -> void:
		state["confidence"] = confidence.get_item_text(index)
		_mark_dirty()
	)
	var submit := _button(form, "Submit assessment", _submit)
	submit.name = "SubmitAssessment"
	feedback = RichTextLabel.new()
	feedback.bbcode_enabled = false
	feedback.selection_enabled = true
	feedback.fit_content = true
	feedback.text = "Debrief appears here after submission. You can revise and resubmit."
	form.add_child(feedback)
	_button(form, "Show next hint / no penalty", _next_hint)
	hint_label = _label("", 14, true)
	form.add_child(hint_label)

	page.add_child(HSeparator.new())
	var footer := HBoxContainer.new()
	page.add_child(footer)
	status_label = _label("", 13, true)
	status_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	footer.add_child(status_label)
	_button(footer, "Licenses", _show_licenses)
	_button(footer, "Save", _save)
	_button(footer, "Reset case", func() -> void: reset_dialog.popup_centered())
	reset_dialog = ConfirmationDialog.new()
	reset_dialog.title = "Reset case progress?"
	reset_dialog.dialog_text = "Replace your notes, pins, answers and hints?\nAn unreadable save will first be copied to a .backup file."
	reset_dialog.confirmed.connect(_reset_case)
	add_child(reset_dialog)
	autosave = Timer.new()
	autosave.wait_time = 0.7
	autosave.one_shot = true
	autosave.timeout.connect(_save)
	add_child(autosave)


func _column(parent: HBoxContainer, width: float, ratio: float) -> VBoxContainer:
	var column := VBoxContainer.new()
	column.custom_minimum_size.x = width
	column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	column.size_flags_stretch_ratio = ratio
	column.add_theme_constant_override("separation", 8)
	parent.add_child(column)
	return column


func _label(text: String, font_size: int, wrap: bool = false) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	if wrap:
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return label


func _button(parent: Node, text: String, action: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.pressed.connect(action)
	parent.add_child(button)
	return button


func _open_evidence(index: int) -> void:
	var evidence: Dictionary = case_data["evidence"][index]
	selected_evidence = evidence["id"]
	evidence_list.select(index)
	document_title.text = evidence["title"]
	document_source.text = evidence["source"] + " / " + evidence["time"] + " UTC / SYNTHETIC"
	reader.text = evidence["body"]
	reader.scroll_to_line(0)
	if selected_evidence not in state["read"]:
		state["read"].append(selected_evidence)
		_mark_dirty(false)
	pin_button.text = "Unpin source" if selected_evidence in state["pinned"] else "Pin source to notebook"


func _select_observation(index: int) -> void:
	timeline_list.select(index)
	timeline_list.ensure_current_is_visible()
	map_view.set_selection(index)
	var id: String = case_data["timeline"][index]["evidence_id"]
	for evidence_index in range(case_data["evidence"].size()):
		if case_data["evidence"][evidence_index]["id"] == id:
			_open_evidence(evidence_index)
			break


func _toggle_pin() -> void:
	if selected_evidence in state["pinned"]:
		state["pinned"].erase(selected_evidence)
		for id in state["citations"]:
			state["citations"][id].erase(selected_evidence)
	else:
		state["pinned"].append(selected_evidence)
	pin_button.text = "Unpin source" if selected_evidence in state["pinned"] else "Pin source to notebook"
	_refresh_notebook()
	_mark_dirty()


func _refresh_notebook() -> void:
	var titles: Array[String] = []
	for evidence in case_data["evidence"]:
		if evidence["id"] in state["pinned"]:
			titles.append(evidence["title"].substr(5))
	notebook_label.text = "PINNED (%d): %s" % [titles.size(), ", ".join(titles) if not titles.is_empty() else "none yet"]
	for finding in case_data["findings"]:
		var id: String = finding["id"]
		var box: VBoxContainer = citation_boxes[id]
		for child in box.get_children():
			box.remove_child(child)
			child.queue_free()
		if titles.is_empty():
			box.add_child(_label("Pin sources to enable citations.", 13))
		else:
			for evidence in case_data["evidence"]:
				var evidence_id: String = evidence["id"]
				if evidence_id not in state["pinned"]:
					continue
				var check := CheckBox.new()
				check.text = evidence["title"]
				check.add_theme_font_size_override("font_size", 13)
				check.set_pressed_no_signal(evidence_id in state["citations"][id])
				check.toggled.connect(_citation_toggled.bind(id, evidence_id))
				box.add_child(check)


func _citation_toggled(checked: bool, finding_id: String, evidence_id: String) -> void:
	if checked and evidence_id not in state["citations"][finding_id]:
		state["citations"][finding_id].append(evidence_id)
	elif not checked:
		state["citations"][finding_id].erase(evidence_id)
	_mark_dirty()


func _answer_selected(index: int, finding_id: String) -> void:
	for finding in case_data["findings"]:
		if finding["id"] == finding_id:
			state["answers"][finding_id] = "" if index == 0 else finding["options"][index - 1]["id"]
			_mark_dirty()
			break


func _submit() -> void:
	var result := Rules.assess(case_data, state)
	var lines: Array[String] = ["ASSESSMENT SUPPORTED" if result["complete"] else "ASSESSMENT / REVIEW FINDINGS"]
	for index in range(result["results"].size()):
		var finding_result: Dictionary = result["results"][index]
		var status: String = finding_result["status"]
		lines.append("\n" + case_data["findings"][index]["question"])
		match status:
			"supported":
				lines.append("SUPPORTED. " + finding_result["explanation"])
			"incomplete":
				lines.append("INCOMPLETE. Choose a conclusion before this finding can be assessed.")
			"needs_support":
				lines.append("NEEDS SUPPORT. Conclusion matches, but cite: " + ", ".join(finding_result["missing"]) + ".\n" + finding_result["explanation"])
			"revise":
				lines.append("REVISE. " + finding_result["explanation"])
	feedback.text = "\n".join(lines)
	_save()


func _next_hint() -> void:
	state["hint_count"] = mini(int(state["hint_count"]) + 1, case_data["hints"].size())
	_refresh_hints()
	_mark_dirty(false)


func _refresh_hints() -> void:
	var hints: Array[String] = []
	for index in range(int(state["hint_count"])):
		hints.append("%d. %s" % [index + 1, case_data["hints"][index]])
	hint_label.text = "\n\n".join(hints)


func _restore_form() -> void:
	notes.set_block_signals(true)
	notes.text = state["notes"]
	notes.set_block_signals(false)
	for finding in case_data["findings"]:
		var option_button: OptionButton = finding_options[finding["id"]]
		option_button.select(0)
		for index in range(finding["options"].size()):
			if finding["options"][index]["id"] == state["answers"][finding["id"]]:
				option_button.select(index + 1)
	confidence.select(["Unrecorded", "Low", "Medium", "High"].find(state["confidence"]))
	_refresh_notebook()
	_refresh_hints()


func _mark_dirty(invalidate_feedback: bool = true) -> void:
	if invalidate_feedback and is_instance_valid(feedback):
		feedback.text = "Assessment changed. Submit to produce a current debrief."
	if is_instance_valid(autosave) and not save_blocked:
		autosave.start()
		_set_status("Unsaved changes / autosave pending.")


func _save() -> bool:
	if save_blocked:
		_set_status("SAVE LOCKED: original unreadable save preserved. Use Reset to back it up and start again.", true)
		return false
	var error := Store.write_session(save_path, state, case_data)
	if not error.is_empty():
		_set_status("SAVE FAILED: " + error, true)
		return false
	_set_status("Saved locally / " + Time.get_time_string_from_system())
	return true


func _reset_case() -> void:
	autosave.stop()
	if save_blocked and FileAccess.file_exists(save_path):
		if FileAccess.file_exists(save_path + ".backup"):
			_set_status("RESET FAILED: an existing .backup must be moved before replacing the unreadable save.", true)
			return
		var backup_error := DirAccess.copy_absolute(save_path, save_path + ".backup")
		if backup_error != OK:
			_set_status("RESET FAILED: cannot preserve original save: " + error_string(backup_error), true)
			return
	var replacement := Rules.new_session(case_data)
	var error := Store.write_session(save_path, replacement, case_data)
	if not error.is_empty():
		_set_status("RESET FAILED: " + error, true)
		return
	state = replacement
	save_blocked = false
	_restore_form()
	feedback.text = "Case reset. Start a new investigation."
	map_view.reset_view()
	map_view.set_selection(-1)
	timeline_list.deselect_all()
	_open_evidence(0)
	_set_status("Case reset and saved.")


func _set_status(message: String, failed: bool = false) -> void:
	status_label.text = message
	status_label.modulate = Color("#ffba9e") if failed else Color("#9db7c6")
	if failed:
		push_warning(message)


func _show_fatal(message: String) -> void:
	var label := _label("CASE STARTUP FAILED\n\n" + message, 20, true)
	label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(label)
	push_error(message)


func _show_licenses() -> void:
	var dialog := AcceptDialog.new()
	dialog.title = "Engine and third-party licenses"
	var text := RichTextLabel.new()
	text.custom_minimum_size = Vector2(760, 480)
	text.selection_enabled = true
	text.text = "GODOT ENGINE\n\n" + Engine.get_license_text()
	text.text += "\n\nTHIRD-PARTY COPYRIGHT NOTICES\n\n" + JSON.stringify(Engine.get_copyright_info(), "\t")
	text.text += "\n\nTHIRD-PARTY LICENSE TEXTS\n\n" + JSON.stringify(Engine.get_license_info(), "\t")
	dialog.add_child(text)
	dialog.confirmed.connect(dialog.queue_free)
	dialog.canceled.connect(dialog.queue_free)
	add_child(dialog)
	dialog.popup_centered()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		if state.is_empty() or _save():
			get_tree().quit()
		else:
			var dialog := ConfirmationDialog.new()
			dialog.title = "Progress could not be saved"
			dialog.dialog_text = "The save error is shown in the status bar. Exit without saving?"
			dialog.confirmed.connect(func() -> void: get_tree().quit())
			add_child(dialog)
			dialog.popup_centered()
