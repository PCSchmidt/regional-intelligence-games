extends Control

signal observation_selected(index: int)

var case_data: Dictionary = {}
var selected_index := -1
var zoom := 1.0
var pan := Vector2.ZERO
var dragging := false

const INK := Color("#dce8ee")
const ACCENT := Color("#65d9c2")


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	clip_contents = true
	custom_minimum_size = Vector2(280, 270)
	tooltip_text = "Click an observation to open its evidence. Drag empty space to pan. Wheel to zoom."
	resized.connect(queue_redraw)


func project(lat: float, lon: float) -> Vector2:
	var scale_value := minf(size.x / 0.65, size.y / 0.60) * zoom
	return size * 0.5 + Vector2((lon - 121.89) * cos(deg_to_rad(20.6)), 20.63 - lat) * scale_value + pan


func set_selection(index: int) -> void:
	selected_index = index
	queue_redraw()


func zoom_by(factor: float) -> void:
	zoom = clampf(zoom * factor, 0.65, 4.0)
	queue_redraw()


func reset_view() -> void:
	zoom = 1.0
	pan = Vector2.ZERO
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color("#091c28"))
	var font := ThemeDB.fallback_font
	for column in range(1, 6):
		var x := size.x * column / 6.0
		draw_line(Vector2(x, 0), Vector2(x, size.y), Color("#16313f"), 1.0)
	for row in range(1, 6):
		var y := size.y * row / 6.0
		draw_line(Vector2(0, y), Vector2(size.x, y), Color("#16313f"), 1.0)
	draw_string(font, Vector2(12, 24), "N ^  /  BATANES, PHILIPPINES", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, INK)
	draw_string(font, Vector2(12, size.y - 14), "SCHEMATIC / NO OBSERVED ROUTE IN GAP", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, INK)
	if case_data.is_empty():
		return
	for place in case_data["places"]:
		var point := project(place["lat"], place["lon"])
		draw_rect(Rect2(point - Vector2(5, 5), Vector2(10, 10)), Color("#c2a76e"))
		draw_string(font, point + Vector2(12, -10), place["name"], HORIZONTAL_ALIGNMENT_LEFT, -1, 14, INK)
	for index in range(case_data["timeline"].size()):
		var event: Dictionary = case_data["timeline"][index]
		if not event.has("lat"):
			continue
		var point := project(event["lat"], event["lon"])
		var color := Color("#ffce7a") if index == selected_index else ACCENT
		draw_circle(point, 6.0, color)
		if index == selected_index:
			draw_arc(point, 10.0, 0, TAU, 32, color, 2.0)
		draw_string(font, point + Vector2(10, 17), event["time"], HORIZONTAL_ALIGNMENT_LEFT, -1, 13, color)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			zoom_by(1.15)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			zoom_by(1.0 / 1.15)
		elif event.button_index == MOUSE_BUTTON_LEFT:
			dragging = event.pressed
			if event.pressed:
				for index in range(case_data.get("timeline", []).size()):
					var observation: Dictionary = case_data["timeline"][index]
					if observation.has("lat") and project(observation["lat"], observation["lon"]).distance_to(event.position) < 12:
						observation_selected.emit(index)
						dragging = false
						break
	elif event is InputEventMouseMotion and dragging:
		pan += event.relative
		queue_redraw()

