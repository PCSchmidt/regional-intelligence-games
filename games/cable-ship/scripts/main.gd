extends Node3D

const Rules = preload("res://scripts/survey_rules.gd")
const Store = preload("res://scripts/save_store.gd")
const Seabed = preload("res://scripts/seabed.gd")
const Rov = preload("res://scripts/rov_model.gd")
const World = preload("res://scripts/world_builder.gd")
const Chart = preload("res://scripts/survey_chart.gd")

var save_path := "user://survey/session.json"
var survey: Dictionary = {}
var session: Dictionary = {}
var startup_error := ""
var save_locked := false
var phase := "deck"
var deck: Node3D
var survey_world: Node3D
var environment: WorldEnvironment
var deck_camera: Camera3D
var rov_camera: Camera3D
var rov_position := Vector3(0, -415, 8)
var rov_velocity := Vector3.ZERO
var rov_yaw := 0.0
var rov_pitch := -0.35
var deck_yaw := 0.0
var deck_pitch := 0.0
var depth_hold := false
var hold_y := -415.0
var hud: CanvasLayer
var info: Label
var prompt: Label
var status: Label
var chart: Control
var help_dialog: AcceptDialog
var console_dialog: AcceptDialog
var assessment_dialog: AcceptDialog
var reset_dialog: ConfirmationDialog
var licenses_dialog: AcceptDialog
var result_label: Label
var hint_label: Label
var gallery: ItemList
var gallery_image: TextureRect
var gallery_description: Label
var answer_controls: Dictionary = {}
var citation_controls: Dictionary = {}
var capturing := false
var autosave := 0.0


func _ready() -> void:
	var loaded := Rules.load_survey("res://content/survey.json")
	if loaded.has("error"):
		startup_error = loaded["error"]
		push_error(startup_error)
		var fatal := Label.new()
		fatal.text = "STARTUP FAILED\n" + startup_error
		add_child(fatal)
		set_physics_process(false)
		return
	survey = loaded["survey"]
	var restored := Store.load_session(save_path, survey)
	if restored.has("error"):
		save_locked = true
		session = Rules.new_session(survey)
	else:
		session = restored["state"]
	_build_world()
	_build_ui()
	_restore_pilot()
	set_phase(str(session["phase"]))
	get_tree().auto_accept_quit = false
	get_tree().root.close_requested.connect(_close)
	if save_locked:
		notify("SAVE LOCKED: " + str(restored["error"]) + " Use Reset to back it up.", true)
	else:
		persist()
	if restored.get("new", false) or save_locked:
		help_dialog.popup_centered()
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		notify("Session resumed. F1: mission/controls. Click the 3D view to pilot.")


func _build_world() -> void:
	environment = WorldEnvironment.new()
	environment.environment = Environment.new()
	add_child(environment)
	deck = Node3D.new()
	add_child(deck)
	World.build_deck(deck)
	survey_world = Node3D.new()
	add_child(survey_world)
	World.build_survey(survey_world, survey)
	deck_camera = Camera3D.new()
	deck_camera.position = Vector3(0, 1.75, 6)
	deck_camera.fov = 68
	deck.add_child(deck_camera)
	rov_camera = Camera3D.new()
	rov_camera.fov = 68
	rov_camera.near = 0.05
	rov_camera.far = 90
	survey_world.add_child(rov_camera)
	for x in [-0.5, 0.5]:
		var light := SpotLight3D.new()
		light.position = Vector3(x, -0.15, 0.1)
		light.light_color = Color("#e4ead0")
		light.light_energy = 12.0
		light.spot_range = 22.0
		light.spot_angle = 42.0
		light.spot_attenuation = 0.5
		light.shadow_enabled = true
		rov_camera.add_child(light)


func _build_ui() -> void:
	hud = CanvasLayer.new()
	add_child(hud)
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud.add_child(root)
	var theme := Theme.new()
	theme.default_font_size = 18
	root.theme = theme
	var header := HBoxContainer.new()
	header.position = Vector2(20, 16)
	root.add_child(header)
	var title := Label.new()
	title.text = "CABLE SHIP  /  SURVEY 01     "
	header.add_child(title)
	_button(header, "Mission / F1", show_help)
	_button(header, "Release mouse / Esc", release_mouse)
	_button(header, "Review / Tab", review_from_pilot)
	_button(header, "Recover / B", return_to_deck)
	_button(header, "Reset", func() -> void:
		release_mouse()
		reset_dialog.popup_centered()
	)
	_button(header, "Licenses", show_licenses)
	info = Label.new()
	info.position = Vector2(24, 74)
	root.add_child(info)
	chart = Chart.new()
	chart.position = Vector2(24, 220)
	chart.size = Vector2(258, 258)
	chart.survey = survey
	root.add_child(chart)
	prompt = Label.new()
	prompt.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	prompt.position = Vector2(-260, -24)
	prompt.size = Vector2(520, 80)
	prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(prompt)
	status = Label.new()
	status.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	status.offset_left = 24
	status.offset_right = -24
	status.offset_top = -110
	status.offset_bottom = -15
	status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(status)
	help_dialog = _dialog("Mission & controls")
	var help := _body(help_dialog)
	_label(help, "YOUR JOB", 26)
	_label(help, survey["brief"] + "\n\n" + survey["question"])
	_label(help, "1. Close this guide. Click the deck to take mouse control.\n2. Walk toward the glowing console; press E nearby, then Launch / resume ROV.\n3. Visit numbered targets on the survey plot. Fly within 6 m and frame a feature.\n4. Press F to capture a real inspection image. Capture the features you need.\n5. Tab recovers the ROV and opens review. Read frames, choose both findings,\n   tick the supporting captures under each finding, then Submit.\n6. Finish when both findings are SUPPORTED. Wrong answers and missing citations\n   are shown separately; revise and resubmit. Hints are optional.")
	_label(help, "W/S forward/reverse | A/D strafe | mouse look | Q/E yaw (ROV)\nSpace rise / Ctrl descend (ROV) | H depth hold | F capture | B recover\nEsc release mouse and stop thrust | click 3D view to resume | F1 reopen help\nWalk with WASD on deck. Flight stops while a dialog or free cursor is active.")
	_label(help, "Real Batanes regional setting; fictional cable, vessel and incident.\nAuthored 70 m survey box near 420 m depth, not real bathymetry or a real route.\nProcedural first-pass art, no audio, no network. No vessel identity or intent can\nbe established from these observations. Target labels are prior survey marks,\nnot new evidence. Autosave is separate from Regional Desk.")
	console_dialog = _dialog("Survey control")
	var console := _body(console_dialog)
	_label(console, "ROV CONTROL / ON STATION", 26)
	_label(console, "Inspect the cable and nearby seabed. Recover to review your images.\nLaunch/resume preserves captures and answers; Reset is a separate action.")
	_button(console, "Launch / resume ROV", launch_survey)
	_button(console, "Review captured frames & assessment", open_assessment)
	assessment_dialog = _dialog("Inspection review & assessment", Vector2i(1040, 620))
	reset_dialog = ConfirmationDialog.new()
	reset_dialog.title = "Back up and reset this survey?"
	reset_dialog.dialog_text = "Back up the current save, then start this Cable Ship survey again.\nOld capture files are retained. Regional Desk is unaffected."
	add_child(reset_dialog)
	reset_dialog.confirmed.connect(reset_session)
	_update_hud()


func _dialog(title_text: String, dimensions := Vector2i(1000, 630)) -> AcceptDialog:
	var dialog := AcceptDialog.new()
	dialog.title = title_text
	dialog.min_size = dimensions
	dialog.size = dimensions
	dialog.ok_button_text = "Close"
	add_child(dialog)
	return dialog


func _body(dialog: AcceptDialog) -> VBoxContainer:
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(dialog.min_size.x - 40, dialog.min_size.y - 80)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	dialog.add_child(scroll)
	var body := VBoxContainer.new()
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 14)
	scroll.add_child(body)
	return body


func _label(parent: Node, value: String, font_size: int = 19) -> Label:
	var label := Label.new()
	label.text = value
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.add_theme_font_size_override("font_size", font_size)
	parent.add_child(label)
	return label


func _button(parent: Node, value: String, callback: Callable) -> Button:
	var button := Button.new()
	button.text = value
	button.pressed.connect(callback)
	parent.add_child(button)
	return button


func set_phase(value: String) -> void:
	phase = value
	session["phase"] = value
	deck.visible = value == "deck"
	survey_world.visible = value == "survey"
	deck_camera.current = value == "deck"
	rov_camera.current = value == "survey"
	var env := environment.environment
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color("#061c22") if value == "survey" else Color("#101d30")
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("#83a6ad")
	env.ambient_light_energy = 0.12 if value == "survey" else 0.65
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.fog_enabled = true
	env.fog_light_color = Color("#073138") if value == "survey" else Color("#182d42")
	env.fog_density = 0.035 if value == "survey" else 0.003
	env.volumetric_fog_enabled = value == "survey" and DisplayServer.get_name() != "headless"
	env.volumetric_fog_density = 0.018
	env.volumetric_fog_albedo = Color("#2a565b")
	env.volumetric_fog_length = 40
	env.volumetric_fog_ambient_inject = 0.15
	sync_camera()
	_update_hud()


func console_distance() -> float:
	return Vector2(deck_camera.position.x, deck_camera.position.z).length()


func interact_console() -> void:
	if console_distance() > 3.0:
		notify("Walk to the glowing console, then press E (within 3 m).")
		return
	release_mouse()
	console_dialog.popup_centered()


func launch_survey() -> void:
	console_dialog.hide()
	assessment_dialog.hide()
	set_phase("survey")
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	persist()
	notify("ROV live. Numbered plot marks are prior survey targets. Frame within 6 m, press F.")


func return_to_deck() -> void:
	if capturing:
		return
	rov_velocity = Vector3.ZERO
	if is_instance_valid(console_dialog):
		console_dialog.hide()
	if is_instance_valid(assessment_dialog):
		assessment_dialog.hide()
	set_phase("deck")
	deck_camera.position = Vector3(0, 1.75, 2)
	release_mouse()
	persist()
	notify("ROV recovered. Press E at the console or Tab to review.")


func review_from_pilot() -> void:
	return_to_deck()
	open_assessment()


func dialog_open() -> bool:
	return help_dialog.visible or console_dialog.visible or assessment_dialog.visible or reset_dialog.visible or (is_instance_valid(licenses_dialog) and licenses_dialog.visible)


func show_licenses() -> void:
	release_mouse()
	if not is_instance_valid(licenses_dialog):
		licenses_dialog = _dialog("Asset and engine licenses")
		var body := _body(licenses_dialog)
		_label(body, FileAccess.get_file_as_string("res://content/ASSET_NOTICES.md"))
		_label(body, Engine.get_license_text())
		_label(body, JSON.stringify(Engine.get_copyright_info(), "\t"))
		_label(body, JSON.stringify(Engine.get_license_info(), "\t"))
	licenses_dialog.popup_centered()


func _unhandled_input(event: InputEvent) -> void:
	if startup_error != "" or capturing:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT and not dialog_open():
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED and not dialog_open():
		if phase == "survey":
			rov_yaw -= event.relative.x * 0.0025
			rov_pitch = clampf(rov_pitch - event.relative.y * 0.0025, -1.25, 0.8)
		else:
			deck_yaw -= event.relative.x * 0.0025
			deck_pitch = clampf(deck_pitch - event.relative.y * 0.0025, -1.1, 1.1)
			deck_camera.rotation = Vector3(deck_pitch, deck_yaw, 0)
	if not (event is InputEventKey) or not event.pressed or event.echo:
		return
	match event.physical_keycode:
		KEY_ESCAPE: release_mouse()
		KEY_F1: show_help()
		KEY_TAB:
			if not dialog_open():
				review_from_pilot()
		KEY_B:
			if not dialog_open():
				return_to_deck()
		KEY_E:
			if phase == "deck" and not dialog_open():
				interact_console()
		KEY_F:
			if phase == "survey" and not dialog_open():
				capture_frame()
		KEY_H:
			if phase == "survey" and not dialog_open():
				depth_hold = not depth_hold
				hold_y = rov_position.y
				notify("Depth hold " + ("ON; vertical thrust changes setpoint." if depth_hold else "OFF"))


func _physics_process(delta: float) -> void:
	if startup_error != "" or dialog_open() or capturing or Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		return
	if phase == "survey":
		var vertical := float(Input.is_physical_key_pressed(KEY_SPACE)) - float(Input.is_physical_key_pressed(KEY_CTRL))
		var input := {
			"forward": float(Input.is_physical_key_pressed(KEY_W)) - float(Input.is_physical_key_pressed(KEY_S)),
			"strafe": float(Input.is_physical_key_pressed(KEY_D)) - float(Input.is_physical_key_pressed(KEY_A)),
			"yaw": float(Input.is_physical_key_pressed(KEY_Q)) - float(Input.is_physical_key_pressed(KEY_E)),
			"vertical": vertical
		}
		step_pilot(input, delta)
		session["elapsed_seconds"] += delta
	else:
		var forward := float(Input.is_physical_key_pressed(KEY_W)) - float(Input.is_physical_key_pressed(KEY_S))
		var right := float(Input.is_physical_key_pressed(KEY_D)) - float(Input.is_physical_key_pressed(KEY_A))
		var displacement := (Rov.forward_vector(deck_yaw) * forward + Rov.right_vector(deck_yaw) * right).limit_length(1) * delta * 3.0
		var next := deck_camera.position + displacement
		next.x = clampf(next.x, -9.7, 9.7)
		next.z = clampf(next.z, -3.2, 8.9)
		if not (absf(next.x) < 1.3 and absf(next.z) < 0.85) and not (next.x > -6.7 and next.x < -4.1 and next.z > -0.3 and next.z < 3.3):
			deck_camera.position = next
	autosave += delta
	if autosave >= 5:
		autosave = 0
		persist()
	_update_hud()


func step_pilot(input: Dictionary, delta: float) -> void:
	var controls := input.duplicate()
	if depth_hold:
		hold_y += float(controls.get("vertical", 0)) * delta * Rov.MAX_VERTICAL_SPEED
		hold_y = clampf(hold_y, Seabed.height_at(rov_position.x, rov_position.z) + Seabed.MIN_ALTITUDE, Seabed.height_at(rov_position.x, rov_position.z) + Seabed.MAX_ALTITUDE)
		controls["vertical"] = clampf((hold_y - rov_position.y) * 1.5 - rov_velocity.y, -1, 1)
	var result := Rov.step(rov_position, rov_velocity, rov_yaw, controls, delta)
	rov_position = result["position"]
	rov_velocity = result["velocity"]
	rov_yaw = result["yaw"]
	sync_camera()


func sync_camera() -> void:
	rov_camera.position = rov_position
	rov_camera.rotation = Vector3(rov_pitch, rov_yaw, 0)
	_update_hud()


func instruments() -> Dictionary:
	return {"depth": -rov_position.y, "altitude": Seabed.altitude_at(rov_position), "heading": Rov.heading_degrees(rov_yaw), "cable": Seabed.cable_distance(rov_position)}


func capture_candidate() -> String:
	var selected := ""
	var closest := INF
	for feature in survey["features"]:
		var id: String = feature["id"]
		if Rules.captured_ids(session).has(id):
			continue
		if not Rules.capture_blocker(survey, id, rov_position, -rov_camera.global_basis.z).is_empty():
			continue
		var target := Seabed.feature_position(feature)
		if not rov_camera.is_position_in_frustum(target):
			continue
		var point := rov_camera.unproject_position(target)
		var rect := get_viewport().get_visible_rect()
		var normalized := (point - rect.get_center()) / rect.size
		if absf(normalized.x) > 0.3 or absf(normalized.y) > 0.3:
			continue
		var ray := PhysicsRayQueryParameters3D.create(rov_position, target + (rov_position - target).normalized() * 0.15)
		if not get_world_3d().direct_space_state.intersect_ray(ray).is_empty():
			continue
		var distance := rov_position.distance_to(target)
		if distance < closest:
			closest = distance
			selected = id
	return selected


func capture_frame() -> void:
	if capturing or phase != "survey":
		return
	if save_locked:
		notify("Save locked: back up/reset the unreadable session before capturing.", true)
		return
	var id := capture_candidate()
	if id.is_empty():
		notify("No new feature framed. Approach a numbered plot mark within 6 m and aim toward it.")
		return
	if DisplayServer.get_name() == "headless":
		notify("Capture unavailable: this renderer has no viewport image.", true)
		return
	capturing = true
	var position_at_capture := rov_position
	var forward_at_capture := -rov_camera.global_basis.z
	hud.hide()
	await RenderingServer.frame_post_draw
	var image := get_viewport().get_texture().get_image()
	hud.show()
	var directory := save_path.get_base_dir().path_join("captures")
	var problem := DirAccess.make_dir_recursive_absolute(directory)
	var frame := "%s-%d.png" % [id, Time.get_ticks_usec()]
	if problem == OK:
		problem = image.save_png(directory.path_join(frame))
	if problem != OK:
		capturing = false
		notify("Capture file failed: " + error_string(problem), true)
		return
	var added := Rules.add_capture(session, survey, id, position_at_capture, forward_at_capture, session["elapsed_seconds"])
	if added.has("error"):
		DirAccess.remove_absolute(directory.path_join(frame))
		notify(str(added["error"]), true)
	else:
		session["captures"].back()["frame"] = frame
		if persist():
			notify("CAPTURED: " + str(added["capture"]["label"]) + ". Review with Tab; choose findings and cite frames.")
	capturing = false
	_update_hud()


func frame_path(capture: Dictionary) -> String:
	var name: String = capture.get("frame", "")
	if name.is_empty() or not name.is_valid_filename() or not name.ends_with(".png"):
		return ""
	return save_path.get_base_dir().path_join("captures").path_join(name)


func _update_hud() -> void:
	if not is_instance_valid(info):
		return
	chart.visible = phase == "survey"
	if phase == "survey":
		var readings := instruments()
		info.text = "ROV / LIVE FEED\nDEPTH   %6.1f m    ALT   %4.1f m\nHDG     %03.0f deg    CABLE %4.1f m\nLOCAL   E %+.1f / S %+.1f m\nCAPTURES %d / 4    HOLD %s" % [readings["depth"], readings["altitude"], readings["heading"], readings["cable"], rov_position.x, rov_position.z, session["captures"].size(), "ON" if depth_hold else "OFF"]
		chart.rov_position = rov_position
		chart.yaw = rov_yaw
		chart.captured = Rules.captured_ids(session)
		chart.queue_redraw()
		var id := capture_candidate()
		prompt.text = "+\nF  Capture " + str(Rules.feature_by_id(survey, id).get("label", "")) if not id.is_empty() else "+\nFrame a numbered target / within 6 m"
	else:
		info.text = "AFT DECK / ON STATION\nBatanes regional setting / fictional incident\nWASD walk / mouse look / E console\n%d inspection frames retained" % session["captures"].size()
		prompt.text = "+\nE  Survey console" if console_distance() <= 3 else "+\nWalk to the glowing console"


func open_assessment() -> void:
	console_dialog.hide()
	release_mouse()
	for child in assessment_dialog.get_children():
		if child is ScrollContainer:
			assessment_dialog.remove_child(child)
			child.queue_free()
	var body := _body(assessment_dialog)
	_label(body, "INSPECTION LOG & ASSESSMENT", 25)
	_label(body, "Select each recorded frame to read the observation. Choose two conclusions,\nthen tick the supporting captures below each finding. Submit to check both.")
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 18)
	body.add_child(row)
	gallery = ItemList.new()
	gallery.custom_minimum_size = Vector2(250, 220)
	row.add_child(gallery)
	var detail := VBoxContainer.new()
	detail.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(detail)
	gallery_image = TextureRect.new()
	gallery_image.custom_minimum_size = Vector2(420, 220)
	gallery_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	gallery_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	detail.add_child(gallery_image)
	gallery_description = _label(detail, "No frame selected. Launch the ROV to collect evidence.")
	for capture in session["captures"]:
		gallery.add_item(capture["label"])
	gallery.item_selected.connect(_select_frame)
	if not session["captures"].is_empty():
		gallery.select(0)
		_select_frame(0)
	answer_controls.clear()
	citation_controls.clear()
	for finding in survey["findings"]:
		var id: String = finding["id"]
		_label(body, finding["prompt"], 21)
		var choices := OptionButton.new()
		choices.add_item("Choose a conclusion...")
		for option in finding["options"]:
			choices.add_item(option["label"])
			if session["answers"].get(id, "") == option["id"]:
				choices.select(choices.item_count - 1)
		choices.item_selected.connect(func(index: int) -> void:
			session["answers"][id] = "" if index == 0 else finding["options"][index - 1]["id"]
			_mark_edited()
		)
		body.add_child(choices)
		answer_controls[id] = choices
		citation_controls[id] = {}
		_label(body, "Cite captured evidence (tick all that support this finding):", 17)
		for capture in session["captures"]:
			var feature_id: String = capture["feature"]
			var box := CheckBox.new()
			box.text = capture["label"]
			box.button_pressed = session["citations"].get(id, []).has(feature_id)
			box.toggled.connect(func(selected: bool) -> void:
				var citations: Array = session["citations"].get(id, []).duplicate()
				if selected and not citations.has(feature_id):
					citations.append(feature_id)
				elif not selected:
					citations.erase(feature_id)
				session["citations"][id] = citations
				_mark_edited()
			)
			body.add_child(box)
			citation_controls[id][feature_id] = box
	_button(body, "Submit assessment", submit_assessment)
	result_label = _label(body, "Not submitted. Inspect frames and cite evidence before submitting.")
	_button(body, "Next hint", show_hint)
	hint_label = _label(body, _hint_text(), 17)
	_button(body, "Launch / resume ROV", launch_survey)
	assessment_dialog.popup_centered()
	if session["assessment_submitted"]:
		_render_result()


func _select_frame(index: int) -> void:
	var capture: Dictionary = session["captures"][index]
	var feature := Rules.feature_by_id(survey, capture["feature"])
	gallery_description.text = "%s\nDepth %.1f m / T+%.1f s / local %s\n\n%s" % [feature["label"], capture["depth"], capture["elapsed"], str(capture["position"]), feature["description"]]
	var image := Image.new()
	var path := frame_path(capture)
	if path.is_empty() or not FileAccess.file_exists(path):
		gallery_image.texture = null
		gallery_description.text += "\nIMAGE UNAVAILABLE: no image file for this record."
		return
	var error := image.load(path)
	if error != OK:
		gallery_image.texture = null
		notify("Cannot read captured frame: " + error_string(error), true)
		return
	gallery_image.texture = ImageTexture.create_from_image(image)


func _mark_edited() -> void:
	session["assessment_submitted"] = false
	result_label.text = "Edited since last submission. Submit again to update support."
	persist()


func submit_assessment() -> void:
	session["assessment_submitted"] = true
	_render_result()
	persist()


func _render_result() -> void:
	var evaluation := Rules.evaluate(session, survey)
	result_label.text = "%d / 2 findings supported.\n" % Rules.supported_count(evaluation)
	for result in evaluation["results"]:
		result_label.text += "\n%s: %s." % [result["id"].capitalize(), "SUPPORTED" if result["supported"] else "REVISE"]
		if not result["answer_ok"]:
			result_label.text += " Revise the conclusion using the observations."
		if not result["missing_citations"].is_empty():
			var labels: Array = []
			for id in result["missing_citations"]:
				labels.append(Rules.feature_by_id(survey, id)["label"])
			result_label.text += " Cite captured evidence: " + ", ".join(labels) + "."
	if evaluation["all_supported"]:
		result_label.text += "\n\nSURVEY COMPLETE\n" + survey["debrief"]["supported"] + "\n\nLimits: " + survey["debrief"]["unsupported"]


func _hint_text() -> String:
	var value := "Hints used: %d / 4" % session["hint_count"]
	for index in int(session["hint_count"]):
		value += "\n%d. %s" % [index + 1, survey["hints"][index]]
	return value


func show_hint() -> void:
	session["hint_count"] = mini(int(session["hint_count"]) + 1, survey["hints"].size())
	hint_label.text = _hint_text()
	persist()


func release_mouse() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	rov_velocity = Vector3.ZERO


func show_help() -> void:
	release_mouse()
	help_dialog.popup_centered()


func notify(message: String, warning: bool = false) -> void:
	status.text = message
	status.modulate = Color("#ffd39a") if warning else Color("#c8e9e1")
	if warning:
		push_warning(message)


func persist() -> bool:
	if save_locked:
		notify("SAVE LOCKED: Original preserved. Use Reset to back up and start again.", true)
		return false
	session["pilot"] = {"position": [rov_position.x, rov_position.y, rov_position.z], "yaw": rov_yaw, "pitch": rov_pitch}
	var problem := Store.write_session(save_path, session, survey)
	if not problem.is_empty():
		notify("SAVE FAILED: " + problem, true)
		return false
	return true


func _restore_pilot() -> void:
	var pilot: Dictionary = session.get("pilot", {})
	var coordinates: Array = pilot.get("position", [0, -415, 8])
	rov_position = Seabed.clamp_to_bounds(Vector3(coordinates[0], coordinates[1], coordinates[2]))
	rov_yaw = float(pilot.get("yaw", 0))
	rov_pitch = float(pilot.get("pitch", -0.35))


func reset_session() -> void:
	var problem := Store.reset_session(save_path)
	if not problem.is_empty():
		notify(problem, true)
		return
	save_locked = false
	startup_error = ""
	session = Rules.new_session(survey)
	rov_velocity = Vector3.ZERO
	depth_hold = false
	_restore_pilot()
	assessment_dialog.hide()
	reset_dialog.hide()
	return_to_deck()
	notify("Survey reset. Previous save backed up; previous frame files retained.")


func _close() -> void:
	if not startup_error.is_empty() or save_locked:
		get_tree().quit()
		return
	if persist():
		get_tree().quit()
	else:
		show_help()
		notify("Exit cancelled because save failed. Progress is still in memory; resolve save access, then close again.", true)


func _exit_tree() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
