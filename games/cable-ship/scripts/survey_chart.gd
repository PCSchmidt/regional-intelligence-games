extends Control

var survey: Dictionary = {}
var rov_position := Vector3.ZERO
var yaw := 0.0
var captured: Array = []


func _draw() -> void:
	var rect := Rect2(Vector2.ZERO, size)
	draw_style_box(_background(), rect)
	var origin := size * 0.5
	var scale := (size.x - 30.0) / 70.0
	for grid in range(-30, 31, 10):
		draw_line(origin + Vector2(grid, -35) * scale, origin + Vector2(grid, 35) * scale, Color("#284b50"))
		draw_line(origin + Vector2(-35, grid) * scale, origin + Vector2(35, grid) * scale, Color("#284b50"))
	draw_line(origin + Vector2(-35, 0) * scale, origin + Vector2(35, 0) * scale, Color("#b8ad69"), 2)
	var font := ThemeDB.fallback_font
	var index := 0
	for feature in survey.get("features", []):
		index += 1
		var point := origin + Vector2(feature["x"], feature["z"]) * scale
		draw_circle(point, 5, Color("#70d6b6") if captured.has(feature["id"]) else Color("#d8b26c"))
		draw_string(font, point + Vector2(7, -5), str(index), HORIZONTAL_ALIGNMENT_LEFT, -1, 16)
	var here := origin + Vector2(rov_position.x, rov_position.z) * scale
	draw_circle(here, 4, Color.WHITE)
	draw_line(here, here + Vector2(-sin(yaw), -cos(yaw)) * 14, Color.WHITE, 2)
	draw_string(font, Vector2(10, 19), "SURVEY PLOT / 70 m / N up", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("#c6e0dc"))
	draw_string(font, Vector2(10, size.y - 10), "Prior targets, not simulated sonar", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("#a5bab9"))


func _background() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.025, 0.08, 0.1, 0.93)
	return style
