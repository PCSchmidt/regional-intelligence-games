extends SceneTree

const MapView = preload("res://scripts/map_view.gd")
const Rules = preload("res://scripts/case_rules.gd")
var passed := 0
var failed := 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var loaded := MapView.load_coastlines("res://content/batanes_coastline.json")
	check(not loaded.has("error"), "Bundled coastlines load and triangulate")
	if loaded.has("error"):
		quit(1)
		return
	var map := MapView.new()
	map.land_polygons = loaded["polygons"]
	root.add_child(map)
	map.size = Vector2(500, 470)
	map.case_data = Rules.load_case("res://content/case_01.json")["case"]
	check(map.land_polygons.size() == 6, "Six complete sourced island exteriors bundled")
	check(map.is_land(20.46, 122.00), "Batan is land, not an invented rectangle")
	check(map.is_land(20.78, 121.84), "Itbayat town lies on Itbayat")
	check(map.is_land(20.31, 121.87), "Sabtang has its own coastline")
	for event in map.case_data["timeline"]:
		if event.has("lat"):
			check(not map.is_land(event["lat"], event["lon"]), "Synthetic vessel observation %s is offshore" % event["time"])
			var body: String = map.case_data["evidence"].filter(func(item: Dictionary) -> bool: return item["id"] == event["evidence_id"])[0]["body"]
			check(body.contains("%.3f N" % event["lat"]) and body.contains("%.3f E" % event["lon"]), "Source coordinates match mapped observation %s" % event["time"])
	var first := map.project(20.45, 121.95)
	map.pan = Vector2(30, -10)
	check(map.project(20.45, 121.95).is_equal_approx(first + map.pan), "Coastline/observation projection shares pan transform")
	map.reset_view()
	var base_scale := map.pixels_per_km()
	map.zoom_by(2)
	check(is_equal_approx(map.pixels_per_km(), base_scale * 2), "Distance scale tracks zoom")
	var longitude_delta := 10.0 / (MapView.KM_PER_DEGREE * cos(deg_to_rad(MapView.REFERENCE_LATITUDE)))
	var ten_km := map.project(MapView.REFERENCE_LATITUDE, 121.88 + longitude_delta).distance_to(map.project(MapView.REFERENCE_LATITUDE, 121.88))
	check(absf(ten_km / (map.pixels_per_km() * 10) - 1) < 0.01, "Scale matches a known 10 km distance within 1 percent")
	map.reset_view()
	check(map.project(20.45, 121.95).is_equal_approx(first), "Reset realigns map and observations")
	var selected: Array[int] = []
	map.observation_selected.connect(func(index: int) -> void: selected.append(index))
	var click := InputEventMouseButton.new()
	click.button_index = MOUSE_BUTTON_LEFT
	click.pressed = true
	click.position = map.project(20.48, 121.96)
	map._gui_input(click)
	check(selected == [8] and not map.dragging, "Click selects nearest timestamp, not an overlapping earlier fix")
	check(MapView.load_coastlines("res://content/no-such-coastline.json").has("error"), "Missing geography produces explicit startup error")
	var fixture: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://content/batanes_coastline.json"))
	fixture["polygons"][0][0][0] = 200
	fixture["polygons"][0][-1][0] = 200
	check(not MapView.validate_coastlines(fixture).is_empty(), "Reject malformed geographic coordinate")
	check(not MapView.validate_coastlines({"polygons": []}).is_empty(), "Reject missing map provenance and geometry")
	map.queue_free()
	await process_frame
	print("MAP TESTS: %d passed, %d failed" % [passed, failed])
	quit(1 if failed else 0)


func check(condition: bool, description: String) -> void:
	if condition:
		passed += 1
	else:
		failed += 1
		push_error("FAIL: " + description)
