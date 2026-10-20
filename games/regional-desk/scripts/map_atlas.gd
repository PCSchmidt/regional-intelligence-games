extends RefCounted

const Rules = preload("res://scripts/case_rules.gd")


static func load_atlas(path: String) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {"error": "Cannot read offline atlas: " + error_string(FileAccess.get_open_error())}
	var parser := JSON.new()
	if parser.parse(file.get_as_text()) != OK:
		return {"error": "Invalid offline atlas JSON: " + parser.get_error_message()}
	var error := validate(parser.data)
	if not error.is_empty():
		return {"error": "Invalid offline atlas: " + error}
	var data: Dictionary = parser.data
	if not FileAccess.file_exists("res://content/MAP_DATA_LICENSES.md"):
		return {"error": "Offline map source/license notice is missing."}
	if not ResourceLoader.exists(data["terrain"]["path"]):
		return {"error": "Offline relief texture is missing."}
	var texture := load(data["terrain"]["path"]) as Texture2D
	if texture == null or texture.get_width() != data["terrain"]["width"] or texture.get_height() != data["terrain"]["height"]:
		return {"error": "Offline relief texture has an invalid format or size."}
	var features: Array[Dictionary] = []
	for feature in data["features"]:
		var points := PackedVector2Array()
		for point in feature["points"]:
			points.append(Vector2(point[0], point[1]))
		var bounds := Rect2(points[0], Vector2.ZERO)
		for point in points:
			bounds = bounds.expand(point)
		features.append({"id": feature["id"], "kind": feature["kind"], "name": feature["name"], "class": feature["class"], "points": points, "bounds": bounds})
	return {"atlas": {"texture": texture, "terrain_bounds": data["terrain"]["bounds"], "features": features, "coverage": data["coverage"]}}


static func validate(value: Variant) -> String:
	if not value is Dictionary or value.get("schema_version") != 1:
		return "Expected atlas schema 1."
	if value.get("coordinate_order") != "longitude,latitude" or value.get("license") != "ODbL-1.0":
		return "Expected WGS84 longitude/latitude and ODbL-1.0 vector license."
	if not value.get("attribution") is String or value["attribution"].is_empty():
		return "Missing OSM attribution."
	if not value.get("sources") is Array or value["sources"].size() != 12:
		return "Expected two town snapshots and ten coastline continuations."
	for source in value["sources"]:
		if not source is Dictionary or not source.get("url") is String or not source.get("sha256") is String or source["sha256"].length() != 64:
			return "Invalid source provenance."
	if not value.get("coast_polygons") is Array or value["coast_polygons"].size() != 3:
		return "Expected three complete OSM coastline rings."
	for ring in value["coast_polygons"]:
		if not ring is Array or ring.size() < 4 or ring[0] != ring[-1]:
			return "Invalid coastline mask ring."
		for point in ring:
			if not valid_point(point):
				return "Invalid coastline mask coordinate."
	if not value.get("terrain") is Dictionary:
		return "Missing terrain metadata."
	var terrain: Dictionary = value["terrain"]
	if terrain.get("path") != "res://content/map_relief.png" or not valid_bounds(terrain.get("bounds")):
		return "Invalid terrain resource or extent."
	if terrain.get("width") != 1620 or terrain.get("height") != 2700 or terrain.get("void_samples") != 0:
		return "Invalid terrain dimensions or unresolved elevation voids."
	for key in ["license", "attribution", "processing", "source_documentation"]:
		if not terrain.get(key) is String or terrain[key].is_empty():
			return "Missing terrain provenance: " + key
	if not terrain.get("sources") is Array or terrain["sources"].size() != 2:
		return "Missing terrain sources."
	if not value.get("coverage") is Array or value["coverage"].size() != 2:
		return "Expected Basco and Itbayat coverage."
	for area in value["coverage"]:
		if not area is Dictionary or area.get("id") not in ["basco", "itbayat"] or not valid_bounds(area.get("bounds")) or not valid_point(area.get("focus")):
			return "Invalid coverage or town focus."
		if not (area.get("zoom") is float or area.get("zoom") is int) or area["zoom"] < 8 or area["zoom"] > 96:
			return "Invalid town zoom."
		if not bounds_rect(area["bounds"]).has_point(Vector2(area["focus"][0], area["focus"][1])):
			return "Town focus must be inside detail coverage."
	if not value.get("features") is Array or value["features"].is_empty():
		return "Missing vector detail."
	var ids: Dictionary = {}
	for feature in value["features"]:
		if not feature is Dictionary or not feature.get("id") is String or feature["id"].is_empty() or ids.has(feature["id"]):
			return "Invalid or duplicate feature identity."
		ids[feature["id"]] = true
		if feature.get("kind") not in ["building", "road", "pier", "coast", "landmark"]:
			return "Unsupported geographic feature."
		if not feature.get("name") is String or not feature.get("class") is String or not feature.get("points") is Array:
			return "Invalid feature labels or geometry."
		var minimum := 1 if feature["kind"] == "landmark" else (3 if feature["kind"] == "building" else 2)
		if feature["points"].size() < minimum:
			return "Incomplete feature geometry."
		var polygon := PackedVector2Array()
		for point in feature["points"]:
			if not valid_point(point):
				return "Invalid feature coordinate."
			var vector := Vector2(point[0], point[1])
			var covered := false
			for area in value["coverage"]:
				var bounds: Array = area["bounds"]
				if point[0] >= bounds[0] - 0.0000001 and point[0] <= bounds[2] + 0.0000001 and point[1] >= bounds[1] - 0.0000001 and point[1] <= bounds[3] + 0.0000001:
					covered = true
			if not covered:
				return "Feature extends outside bounded detail coverage: " + feature["id"]
			polygon.append(vector)
		if feature["kind"] == "building" and Geometry2D.triangulate_polygon(polygon).is_empty():
			return "Invalid building footprint: " + feature["id"]
	return ""


static func valid_point(point: Variant) -> bool:
	return point is Array and point.size() == 2 and Rules.valid_coordinate({"lon": point[0], "lat": point[1]})


static func valid_bounds(bounds: Variant) -> bool:
	return bounds is Array and bounds.size() == 4 and valid_point([bounds[0], bounds[1]]) and valid_point([bounds[2], bounds[3]]) and bounds[0] < bounds[2] and bounds[1] < bounds[3]


static func bounds_rect(bounds: Array) -> Rect2:
	return Rect2(Vector2(bounds[0], bounds[1]), Vector2(bounds[2] - bounds[0], bounds[3] - bounds[1]))
