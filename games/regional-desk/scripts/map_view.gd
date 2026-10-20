extends Control

signal observation_selected(index: int)

const Rules = preload("res://scripts/case_rules.gd")
const INK := Color("#dce8ee")
const ACCENT := Color("#65d9c2")
const LAND := Color("#254b45")
const COAST := Color("#739b83")
const PLACE := Color("#dfc38a")
const KM_PER_DEGREE := 111.195
const REFERENCE_LATITUDE := 20.6
const ISLAND_LABELS := [
	{"name": "Itbayat", "lat": 20.735, "lon": 121.85},
	{"name": "Batan", "lat": 20.405, "lon": 121.985},
	{"name": "Sabtang", "lat": 20.30, "lon": 121.87}
]

var case_data: Dictionary = {}
var atlas: Dictionary = {}
var land_polygons: Array[PackedVector2Array] = []
var selected_index := -1
var zoom := 1.0
var pan := Vector2.ZERO
var center := Vector2(121.88, 20.56)
var dragging := false


static func load_coastlines(path: String) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {"error": "Cannot read coastline data: " + error_string(FileAccess.get_open_error())}
	var parser := JSON.new()
	if parser.parse(file.get_as_text()) != OK:
		return {"error": "Coastline data is not valid JSON: " + parser.get_error_message()}
	var error := validate_coastlines(parser.data)
	if not error.is_empty():
		return {"error": "Invalid coastline data: " + error}
	var polygons: Array[PackedVector2Array] = []
	for ring in parser.data["polygons"]:
		var polygon := PackedVector2Array()
		for index in range(ring.size() - 1):
			polygon.append(Vector2(ring[index][0], ring[index][1]))
		if Geometry2D.triangulate_polygon(polygon).is_empty():
			return {"error": "Invalid coastline data: an island cannot be triangulated."}
		polygons.append(polygon)
	return {"polygons": polygons}


static func validate_coastlines(value: Variant) -> String:
	if not value is Dictionary:
		return "Root must be an object."
	for key in ["source", "revision", "license", "coordinate_order"]:
		if not value.get(key) is String or value[key].is_empty():
			return "Missing provenance field: " + key
	if value["coordinate_order"] != "longitude, latitude (WGS84 degrees)":
		return "Expected longitude, latitude in WGS84 degrees."
	if not value.get("polygons") is Array or value["polygons"].is_empty():
		return "Expected nonempty island polygons."
	for ring in value["polygons"]:
		if not ring is Array or ring.size() < 4 or ring[0] != ring[-1]:
			return "Island exterior must be a closed ring with at least four points."
		for point in ring:
			if not point is Array or point.size() != 2:
				return "Expected longitude/latitude pairs."
			if not Rules.valid_coordinate({"lon": point[0], "lat": point[1]}):
				return "Invalid coastline coordinate."
	return ""


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	clip_contents = true
	custom_minimum_size = Vector2(280, 290)
	tooltip_text = "Real terrain and bounded OpenStreetMap detail; synthetic observations. Click a marker to open its source. Drag to pan; wheel to zoom. Expand map for town presets. Not for navigation."
	resized.connect(queue_redraw)


func plot_rect() -> Rect2:
	return Rect2(Vector2(16, 34), Vector2(maxf(1, size.x - 32), maxf(1, size.y - 86)))


func pixels_per_km() -> float:
	return minf(plot_rect().size.x / 0.65, plot_rect().size.y / 0.74) * zoom / KM_PER_DEGREE


func project(lat: float, lon: float) -> Vector2:
	var scale_value := pixels_per_km() * KM_PER_DEGREE
	var location := Vector2(lon, lat)
	return plot_rect().get_center() + Vector2((location.x - center.x) * cos(deg_to_rad(REFERENCE_LATITUDE)), center.y - location.y) * scale_value + pan


func unproject(point: Vector2) -> Vector2:
	var offset := (point - plot_rect().get_center() - pan) / (pixels_per_km() * KM_PER_DEGREE)
	return center + Vector2(offset.x / cos(deg_to_rad(REFERENCE_LATITUDE)), -offset.y)


func detail_status() -> String:
	if zoom < 8:
		return "REGIONAL RELIEF / expand for towns"
	var focus := unproject(plot_rect().get_center())
	for area in atlas.get("coverage", []):
		var bounds: Array = area["bounds"]
		if focus.x >= bounds[0] and focus.x <= bounds[2] and focus.y >= bounds[1] and focus.y <= bounds[3]:
			return "LOCAL DETAIL / " + str(area["id"]).capitalize()
	return "Street detail not supplied here"


func focus_area(index: int) -> void:
	var area: Dictionary = atlas["coverage"][index]
	center = Vector2(area["focus"][0], area["focus"][1])
	zoom = area["zoom"]
	pan = Vector2.ZERO
	dragging = false
	queue_redraw()


func scale_distance_km() -> float:
	var target_width := minf(95, size.x * 0.3)
	var distance := 0.02
	for candidate in [0.02, 0.05, 0.1, 0.2, 0.5, 1.0, 2.0, 5.0, 10.0, 20.0, 50.0, 100.0]:
		if candidate * pixels_per_km() <= target_width:
			distance = candidate
	return distance


func is_land(lat: float, lon: float) -> bool:
	for polygon in land_polygons:
		if Geometry2D.is_point_in_polygon(Vector2(lon, lat), polygon):
			return true
	return false


func set_selection(index: int) -> void:
	selected_index = index
	queue_redraw()


func zoom_by(factor: float) -> void:
	zoom = clampf(zoom * factor, 0.65, 96.0)
	queue_redraw()


func reset_view() -> void:
	zoom = 1.0
	center = Vector2(121.88, 20.56)
	pan = Vector2.ZERO
	dragging = false
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color("#091c28"))
	var font := ThemeDB.fallback_font
	for column in range(1, 6):
		var x := size.x * column / 6.0
		draw_line(Vector2(x, 0), Vector2(x, size.y), Color("#16313f"))
	for row in range(1, 6):
		var y := size.y * row / 6.0
		draw_line(Vector2(0, y), Vector2(size.x, y), Color("#16313f"))
	if atlas.is_empty():
		for polygon in land_polygons:
			var projected := PackedVector2Array()
			for point in polygon:
				projected.append(project(point.y, point.x))
			draw_colored_polygon(projected, LAND)
			projected.append(projected[0])
			draw_polyline(projected, COAST, 1.5, true)
	else:
		var bounds: Array = atlas["terrain_bounds"]
		var northwest := project(bounds[3], bounds[0])
		var southeast := project(bounds[1], bounds[2])
		draw_texture_rect(atlas["texture"], Rect2(northwest, southeast - northwest), false)
		_draw_detail()
	var occupied: Array[Rect2] = []
	for island in ISLAND_LABELS:
		_draw_label(island["name"], project(island["lat"], island["lon"]), INK, occupied)
	for place in case_data.get("places", []):
		var point := project(place["lat"], place["lon"])
		if not plot_rect().has_point(point):
			continue
		draw_rect(Rect2(point - Vector2(4, 4), Vector2(8, 8)), PLACE)
		_draw_label(place["name"], point, PLACE, occupied)
	if not atlas.is_empty() and zoom >= 8:
		for feature in _visible_features():
			var points: PackedVector2Array = feature["points"]
			if feature["name"].is_empty():
				continue
			if feature["kind"] == "landmark":
				var point := project(points[0].y, points[0].x)
				draw_circle(point, 4, PLACE)
				_draw_label(feature["name"], point, PLACE, occupied)
		if zoom >= 14:
			var named_roads: Dictionary = {}
			for feature in _visible_features():
				if feature["kind"] == "road" and not feature["name"].is_empty() and not named_roads.has(feature["name"]) and occupied.size() < 22:
					var point: Vector2 = feature["points"][feature["points"].size() / 2]
					if _draw_label(feature["name"], project(point.y, point.x), INK, occupied):
						named_roads[feature["name"]] = true
	for index in range(case_data.get("timeline", []).size()):
		var event: Dictionary = case_data["timeline"][index]
		if not event.has("lat"):
			continue
		var point := project(event["lat"], event["lon"])
		if not plot_rect().has_point(point):
			continue
		var color := Color("#ffce7a") if index == selected_index else ACCENT
		draw_circle(point, 7, Color("#091c28"))
		if event.get("kind", "sighting" if event["evidence_id"] == "lookout" else "public_fix") == "sighting":
			draw_polyline(PackedVector2Array([point + Vector2(0, -6), point + Vector2(6, 0), point + Vector2(0, 6), point + Vector2(-6, 0), point + Vector2(0, -6)]), color, 2, true)
		else:
			draw_circle(point, 5, color)
		if index == selected_index:
			draw_arc(point, 10, 0, TAU, 32, color, 2, true)
		_draw_label(event.get("marker_label", event["time"]), point, color, occupied)
	draw_rect(Rect2(0, 0, size.x, 32), Color("#091c28"))
	draw_string(font, Vector2(12, 20), "N ^  /  BATANES, PHILIPPINES", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, INK)
	draw_rect(Rect2(0, size.y - 50, size.x, 50), Color("#091c28"))
	var origin := Vector2(14, size.y - 34)
	var length := scale_distance_km() * pixels_per_km()
	draw_line(origin, origin + Vector2(length, 0), INK, 2)
	draw_line(origin - Vector2(0, 4), origin + Vector2(0, 4), INK)
	draw_line(origin + Vector2(length, -4), origin + Vector2(length, 4), INK)
	var distance := scale_distance_km()
	var scale_text := "%d m" % roundi(distance * 1000) if distance < 1 else "%d km" % roundi(distance)
	draw_string(font, origin + Vector2(length + 8, 4), scale_text + " (approx.)", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, INK)
	draw_string(font, Vector2(12, size.y - 10), "OSM contributors / ODbL | Mapzen terrain", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, INK)
	if size.x > 500:
		draw_string(font, Vector2(300, 20), detail_status() + " / NOT FOR NAVIGATION", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, INK)


func _visible_features() -> Array[Dictionary]:
	var visible: Array[Dictionary] = []
	if atlas.is_empty():
		return visible
	var first := unproject(plot_rect().position)
	var second := unproject(plot_rect().end)
	var bounds := Rect2(Vector2(first.x, second.y), Vector2(second.x - first.x, first.y - second.y))
	for feature in atlas["features"]:
		if bounds.intersects(feature["bounds"], true):
			visible.append(feature)
	return visible


func _draw_detail() -> void:
	if zoom < 8:
		return
	var visible := _visible_features()
	for kind in ["building", "coast", "road", "pier"]:
		for feature in visible:
			if feature["kind"] != kind or (kind == "building" and zoom < 14):
				continue
			var points := PackedVector2Array()
			for point in feature["points"]:
				points.append(project(point.y, point.x))
			match kind:
				"building":
					draw_colored_polygon(points, Color("#d9cdb0"))
					points.append(points[0])
					draw_polyline(points, Color("#6e6b5b"), 0.8, true)
				"road":
					var width := 3.0 if feature["class"] in ["primary", "secondary", "tertiary"] else 1.6
					draw_polyline(points, Color("#595d52"), width + 1.5, true)
					draw_polyline(points, Color("#f4e9cc"), width, true)
				"pier":
					draw_polyline(points, Color("#e6c497"), 4, true)
				"coast":
					draw_polyline(points, Color("#c0d9c8"), 1.5, true)


func _draw_label(text: String, point: Vector2, color: Color, occupied: Array[Rect2]) -> bool:
	var font := ThemeDB.fallback_font
	var width := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, 13).x
	for offset in [Vector2(10, -8), Vector2(10, 19), Vector2(-width - 10, -8), Vector2(-width - 10, 19), Vector2(10, 37), Vector2(-width - 10, 37), Vector2(10, -26), Vector2(-width - 10, -26)]:
		var baseline: Vector2 = point + offset
		var bounds := Rect2(baseline - Vector2(2, 14), Vector2(width + 4, 18))
		if not plot_rect().encloses(bounds):
			continue
		var overlaps := false
		for previous in occupied:
			if previous.intersects(bounds):
				overlaps = true
				break
		if overlaps:
			continue
		occupied.append(bounds)
		draw_rect(bounds, Color(0.035, 0.11, 0.16, 0.85))
		draw_string(font, baseline, text, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, color)
		return true
	return false


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			zoom_by(1.15)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			zoom_by(1.0 / 1.15)
		elif event.button_index == MOUSE_BUTTON_LEFT:
			dragging = event.pressed and plot_rect().has_point(event.position)
			if dragging:
				var nearest := -1
				var distance := 12.0
				for index in range(case_data.get("timeline", []).size()):
					var observation: Dictionary = case_data["timeline"][index]
					if observation.has("lat"):
						var separation := project(observation["lat"], observation["lon"]).distance_to(event.position)
						if separation < distance:
							distance = separation
							nearest = index
				if nearest >= 0:
					observation_selected.emit(nearest)
					dragging = false
	elif event is InputEventMouseMotion and dragging:
		pan += event.relative
		queue_redraw()
