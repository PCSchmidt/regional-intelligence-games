extends SceneTree

const Rules = preload("res://scripts/case_rules.gd")
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
		push_error("Offline atlas test timeout")
		quit(1)
	)
	check(ResourceLoader.exists("res://scripts/map_atlas.gd"), "Offline terrain/street atlas implementation exists")
	if not ResourceLoader.exists("res://scripts/map_atlas.gd"):
		quit(1)
		return
	var Atlas: Script = load("res://scripts/map_atlas.gd")
	var loaded: Dictionary = Atlas.load_atlas("res://content/offline_map.json")
	check(not loaded.has("error"), "Bundled terrain and OSM features load and validate: " + str(loaded.get("error", "OK")))
	if loaded.has("error"):
		quit(1)
		return
	var atlas: Dictionary = loaded["atlas"]
	check(atlas["texture"].get_width() == 1620 and atlas["texture"].get_height() == 2700, "Relief preserves one-arc-second sampling across its declared extent")
	check(atlas["features"].filter(func(item: Dictionary) -> bool: return item["kind"] == "building").size() > 3000, "Thousands of actual sourced building footprints, not invented decoration")
	check(atlas["features"].filter(func(item: Dictionary) -> bool: return item["kind"] == "road").size() > 450, "Real roads remain vector detail at close zoom")
	check(atlas["features"].filter(func(item: Dictionary) -> bool: return item["kind"] == "pier").size() == 5, "Only the five supplied port outlines are rendered")
	check(atlas["features"].any(func(item: Dictionary) -> bool: return item["name"] == "Chinapoliran Port"), "Itbayat source supplies a named port point without invented pier outlines")
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://content/offline_map.json"))
	check(data["license"] == "ODbL-1.0" and data["sources"].size() == 12 and data["terrain"]["sources"].size() == 2, "Vector/terrain provenance and separate source licenses are retained")
	check(data["coast_polygons"].size() == 3, "Complete sourced coast rings mask the coarse elevation shoreline")
	var notices := FileAccess.get_file_as_string("res://content/MAP_DATA_LICENSES.md")
	check(notices.contains("ODbL") and notices.contains("contributors") and notices.contains("U.S. Geological Survey") and notices.contains("NOAA"), "Offline notice credits both geographic datasets and explains redistribution")
	var relief: Image = atlas["texture"].get_image()
	var sea := relief.get_pixel(roundi((121.95 - 121.65) * 3600), roundi((20.95 - 20.45) * 3600))
	var town := relief.get_pixel(roundi((121.9688 - 121.65) * 3600), roundi((20.95 - 20.4508) * 3600))
	check(sea.is_equal_approx(Color("#163d4e")) and not town.is_equal_approx(sea), "Actual relief pixels distinguish offshore water from Basco land")
	for source in data["sources"]:
		check(source["sha256"].length() == 64 and source["url"].begins_with("https://api.openstreetmap.org/"), "Each bounded OSM snapshot has a reproducible source and hash")
	check(Atlas.load_atlas("res://content/absent-atlas.json").has("error"), "Missing atlas is an explicit error, not a fake detailed map")
	var broken := data.duplicate(true)
	broken["features"][0]["points"][0][0] = 200
	check(not Atlas.validate(broken).is_empty(), "Reject invalid detail coordinate")
	broken = data.duplicate(true)
	broken["features"][0]["kind"] = "invented"
	check(not Atlas.validate(broken).is_empty(), "Reject unsupported detail kind")
	broken = data.duplicate(true)
	broken["terrain"]["bounds"] = [122.1, 20.2, 121.65, 20.95]
	check(not Atlas.validate(broken).is_empty(), "Reject reversed terrain bounds")
	broken = data.duplicate(true)
	broken["license"] = ""
	check(not Atlas.validate(broken).is_empty(), "Reject missing redistribution license")
	broken = data.duplicate(true)
	broken["coverage"][0]["focus"] = [500, 20]
	check(not Atlas.validate(broken).is_empty(), "Reject invalid focus coordinates")

	if DisplayServer.get_name() == "headless":
		root.size = Vector2i(1280, 900)
	else:
		DisplayServer.window_set_size(Vector2i(1280, 900))
	var directory := "user://atlas-tests-%d" % OS.get_process_id()
	check(DirAccess.make_dir_absolute(directory) == OK, "Create isolated atlas scene save directory")
	var scene: PackedScene = load("res://main.tscn")
	var app = scene.instantiate()
	app.save_path = directory.path_join("session.json")
	root.add_child(app)
	await settle()
	app.help_dialog.hide()
	var before: Dictionary = app.state.duplicate(true)
	check(app.map_view.atlas["texture"] is Texture2D, "Desk uses real relief texture")
	app.expand_map_button.pressed.emit()
	await settle()
	check(app.map_dialog.visible and app.expanded_map.atlas["features"].size() == atlas["features"].size(), "Expand opens a readable map with the same offline dataset")
	var window_bounds := Rect2(Vector2.ZERO, Vector2(root.size))
	var physical_rect: Rect2 = root.get_final_transform() * app.expanded_map.get_global_rect()
	check(window_bounds.encloses(physical_rect), "Expanded map fits the target physical window: %s; popup %s" % [physical_rect, app.map_dialog.size])
	check(app.map_dialog.size.y < root.size.y and app.map_dialog.size.x < root.size.x and app.map_dialog.position.y >= 0, "Expanded dialog itself remains inside target window")
	await capture("-region")
	for index in [1, 2]:
		app.map_focus.select(index)
		app.map_focus.item_selected.emit(index)
		await settle()
		check(app.expanded_map.zoom >= 14 and app.expanded_map.zoom > 4, "Town preset goes beyond old four-times zoom")
		check(app.expanded_map.detail_status().contains("LOCAL DETAIL"), "Town preset identifies actual street coverage")
		var focus: Array = atlas["coverage"][index - 1]["focus"]
		check(app.expanded_map.project(focus[1], focus[0]).distance_to(app.expanded_map.plot_rect().get_center()) < 0.5, "Terrain and street focus align within half a display pixel")
		var location: Vector2 = app.expanded_map.unproject(app.expanded_map.project(focus[1] + 0.001, focus[0] + 0.001))
		check(location.is_equal_approx(Vector2(focus[0] + 0.001, focus[1] + 0.001)), "Forward and inverse projection round-trip through close zoom")
		await capture("-basco" if index == 1 else "-itbayat")
	app.map_focus.select(3)
	app.map_focus.item_selected.emit(3)
	await settle()
	check(app.expanded_map.center.distance_to(Vector2(121.8200742, 20.780804)) < 0.00001 and app.expanded_map.zoom == 64, "Port preset centers on the actual sourced point at readable close zoom")
	await capture("-port")
	app.expanded_map.center = Vector2(121.7, 20.4)
	app.expanded_map.pan = Vector2.ZERO
	check(app.expanded_map.detail_status().contains("not supplied"), "Panning outside detail coverage reports the real limit")
	app.expanded_map.zoom_by(100000)
	check(app.expanded_map.zoom == 96, "Zoom stops at a bounded useful maximum")
	check(app.expanded_map.scale_distance_km() < 1 and app.expanded_map.scale_distance_km() * app.expanded_map.pixels_per_km() <= 95, "Close zoom uses a truthful sub-kilometer scale")
	app.expanded_map.reset_view()
	check(app.expanded_map.zoom == 1 and app.expanded_map.center == Vector2(121.88, 20.56), "Region reset restores initial geographic center")
	check(app.state.recursive_equal(before, 8), "Map browsing does not alter evidence, citations, notes or hints")
	app.map_dialog.hide()
	for index in range(3):
		app._request_case(index)
		await settle()
		app.help_dialog.hide()
		app.expand_map_button.pressed.emit()
		await settle()
		check(app.expanded_map.case_data["id"] == app.case_data["id"], "Expanded map uses currently selected case, never stale observations")
		if index < 2:
			var event_index := -1
			for event in range(app.case_data["timeline"].size()):
				if app.case_data["timeline"][event].has("lat"):
					event_index = event
					break
			var event: Dictionary = app.case_data["timeline"][event_index]
			app.expanded_map.center = Vector2(event["lon"], event["lat"])
			app.expanded_map.pan = Vector2.ZERO
			var click := InputEventMouseButton.new()
			click.button_index = MOUSE_BUTTON_LEFT
			click.pressed = true
			click.position = app.expanded_map.project(event["lat"], event["lon"])
			app.expanded_map._gui_input(click)
			check(not app.map_dialog.visible and app.selected_evidence == event["evidence_id"] and app.map_view.selected_index == event_index, "Expanded observation click closes map and opens the correct source")
		else:
			check(app.expanded_map.case_data["timeline"].all(func(event: Dictionary) -> bool: return not event.has("lat")), "Third expanded map has no invented observations or A/B positions")
			app.map_dialog.hide()
		check(Rules.validate_session(app.state, app.case_data).is_empty(), "Map controls preserve valid case-specific save state")
	check(app._save(), "Current case still saves after expanded map use")
	root.remove_child(app)
	app.queue_free()
	await settle()
	for suffix in ["", "-case-02", "-case-03"]:
		for extension in [".json", ".json.tmp"]:
			DirAccess.remove_absolute(directory.path_join("session" + suffix + extension))
	check(DirAccess.remove_absolute(directory) == OK, "Clean up isolated atlas save fixtures")
	print("ATLAS TESTS: %d passed, %d failed" % [passed, failed])
	quit(1 if failed else 0)


func settle() -> void:
	await process_frame
	await process_frame


func capture(suffix: String) -> void:
	if preview_path.is_empty() or DisplayServer.get_name() == "headless":
		return
	await settle()
	check(root.get_texture().get_image().save_png(preview_path.get_basename() + suffix + ".png") == OK, "Capture real offline map preview")


func check(condition: bool, description: String) -> void:
	if condition:
		passed += 1
	else:
		failed += 1
		push_error("FAIL: " + description)
