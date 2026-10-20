extends SceneTree

const INPUTS := [
	{"id": "basco", "file": "basco.osm", "sha256": "78a2a0abf5a3ea48cc7ecf9083d463c9179d3314b069f5eeb4fd96b5cc74bed9", "bounds": [121.93, 20.42, 122.01, 20.49], "focus": [121.9688, 20.4508], "zoom": 48},
	{"id": "itbayat", "file": "itbayat.osm", "sha256": "af620a2bd285dabf06f9258f391d5890faa68bfc310adf1ad05542f96ca02327", "bounds": [121.79, 20.74, 121.88, 20.83], "focus": [121.8396, 20.787], "zoom": 64}
]
const EXTRA_COAST := [
	{"id":"1537615984","sha256":"20f160742ba6342e0fbb31757d058634f3e03a269ef7edf14b82a169d372853f"},
	{"id":"1537615986","sha256":"42308e837c3d9e17041c6524d5d3ea95b6502cd34f28f0ef607d3a52fa7a4f2c"},
	{"id":"1537868173","sha256":"aa1bdaa72bf504c1d4fc7571e10012ab18ba37711712f4aecda9500f7235d39e"},
	{"id":"1537868175","sha256":"fa157008bc9fdf6d3c88a3df5ebe9a21c0892c362eb48d80068a7a808a6ce0e2"},
	{"id":"1537902705","sha256":"386dccbb1c115b1d58fc4e820656fc59741dda77862d4780ed6bd3b4f0dfdf26"},
	{"id":"1537902706","sha256":"584caa3cfd68298646c592628905c0ed41519c60e6e53cd9f9dd6b58c76e8880"},
	{"id":"29051695","sha256":"8796c4b41e28d56db61446caa9503ea04278fb6d5a458ef86487abb428b620c7"},
	{"id":"343516784","sha256":"54e6e94261e485da346d7e26e7603420a68a2a9ce00a5c5b660cfbf9a3ce1cf0"},
	{"id":"343724716","sha256":"e1926146fff06e5f710f4ca800eabfad40b46cafb0803907896e5fd3bab3c494"},
	{"id":"538398275","sha256":"de05a55b59f1639eec4b093f17aeffe959c765e945dfef338c8227c57d401e34"}
]
const ELEVATION := [
	{"file": "N20E121.hgt.gz", "sha256": "4b8f6b602f8bd145273c90bf3412d9b9fe673dd5f2274785651b298fce71564f"},
	{"file": "N20E122.hgt.gz", "sha256": "e4d1e1d52bce3f46c9d19874bca93ed2c2fc980f4991ec998c68a4ca04714e9d"}
]
var source_directory := ""
var tiles: Array[PackedByteArray] = []
var features: Array[Dictionary] = []
var coverage: Array[Dictionary] = []
var sources: Array[Dictionary] = []
var coast_ways: Array[Dictionary] = []
var mask := PackedByteArray()


func _initialize() -> void:
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--source="):
			source_directory = argument.trim_prefix("--source=")
	if source_directory.is_empty():
		fail("Pass --source=<directory containing the hash-pinned OSM/HGT inputs>.")
		return
	for input in INPUTS:
		if FileAccess.get_sha256(source_directory.path_join(input["file"])) != input["sha256"]:
			fail("OSM snapshot hash mismatch: " + input["file"])
			return
		if not read_osm(input):
			return
	for segment in EXTRA_COAST:
		var input := {"file": "coast-" + segment["id"] + ".osm", "sha256": segment["sha256"], "coast_only": true, "url": "https://api.openstreetmap.org/api/0.6/way/" + segment["id"] + "/full"}
		if FileAccess.get_sha256(source_directory.path_join(input["file"])) != input["sha256"]:
			fail("Coast snapshot hash mismatch: " + input["file"])
			return
		if not read_osm(input):
			return
	var coast_polygons := close_coasts()
	if coast_polygons.is_empty():
		return
	build_mask(coast_polygons)
	for input in ELEVATION:
		if FileAccess.get_sha256(source_directory.path_join(input["file"])) != input["sha256"]:
			fail("Compressed terrain hash mismatch: " + input["file"])
			return
		var compressed := FileAccess.get_file_as_bytes(source_directory.path_join(input["file"]))
		var bytes := compressed.decompress_dynamic(25934402, FileAccess.COMPRESSION_GZIP)
		if bytes.size() != 25934402:
			fail("Expected 3601 x 3601 signed big-endian samples: " + input["file"])
			return
		tiles.append(bytes)
	if not build_relief():
		return
	var terrain_sources: Array[Dictionary] = []
	for input in ELEVATION:
		terrain_sources.append({"url": "https://s3.amazonaws.com/elevation-tiles-prod/skadi/N20/" + input["file"], "sha256": input["sha256"]})
	var data := {
		"schema_version": 1, "coordinate_order": "longitude,latitude", "license": "ODbL-1.0",
		"attribution": "OpenStreetMap contributors / ODbL-1.0", "snapshot_date": "2026-10-20",
		"sources": sources, "coverage": coverage, "features": features, "coast_polygons": coast_polygons,
		"terrain": {
			"path": "res://content/map_relief.png", "bounds": [121.65, 20.2, 122.1, 20.95],
			"width": 1620, "height": 2700, "grid_spacing_arc_seconds": 1, "contour_interval_m": 100,
			"sources": terrain_sources, "void_samples": 0,
			"attribution": "Mapzen Global Terrain; USGS SRTM/GMTED2010; NOAA ETOPO1",
			"license": "Public-domain US government elevation; ODbL coastline masking; Mapzen and OSM attribution retained",
			"processing": "Bounded nearest-sample relief, hillshade and raster 100 m contour crossings. Batan/Itbayat land/sea masking from complete OSM coastline rings. Flat sea is not bathymetry. One-arc-second (~30 m) output grid; merged source resolution varies and can be coarser. Not survey accuracy.",
			"source_documentation": "https://github.com/tilezen/joerd/tree/0b86765156d0612d837548c2cf70376c43b3405c/docs"
		}
	}
	var output := FileAccess.open("res://content/offline_map.json", FileAccess.WRITE)
	if output == null:
		fail("Cannot write offline_map.json: " + error_string(FileAccess.get_open_error()))
		return
	output.store_string(JSON.stringify(data))
	output.close()
	print("Wrote %d bounded OSM features and 1620 x 2700 shaded relief with 100 m contour crossings." % features.size())
	quit()


func read_osm(input: Dictionary) -> bool:
	var parser := XMLParser.new()
	var error := parser.open(source_directory.path_join(input["file"]))
	if error != OK:
		fail("Cannot parse " + input["file"] + ": " + error_string(error))
		return false
	var nodes: Dictionary = {}
	var ways: Array[Dictionary] = []
	var current: Dictionary = {}
	while true:
		error = parser.read()
		if error == ERR_FILE_EOF:
			break
		if error != OK:
			fail("Malformed OSM XML: " + input["file"])
			return false
		if parser.get_node_type() == XMLParser.NODE_ELEMENT:
			var element := parser.get_node_name()
			if element == "node":
				var id := parser.get_named_attribute_value("id")
				var point := Vector2(float(parser.get_named_attribute_value("lon")), float(parser.get_named_attribute_value("lat")))
				nodes[id] = point
				current = {"id": "node/" + id, "point": point, "tags": {}}
				if parser.is_empty():
					current = {}
			elif element == "way":
				current = {"id": "way/" + parser.get_named_attribute_value("id"), "refs": [], "tags": {}}
			elif element == "relation":
				current = {}
			elif element == "nd" and current.has("refs"):
				current["refs"].append(parser.get_named_attribute_value("ref"))
			elif element == "tag" and current.has("tags"):
				current["tags"][parser.get_named_attribute_value("k")] = parser.get_named_attribute_value("v")
		elif parser.get_node_type() == XMLParser.NODE_ELEMENT_END:
			var element := parser.get_node_name()
			if element == "way" and current.has("refs"):
				ways.append(current)
				current = {}
			elif element == "node" and current.has("point"):
				var label: String = current["tags"].get("name", "")
				if not input.get("coast_only", false) and (label.ends_with(" Port") or current["tags"].get("man_made") == "lighthouse") and contains(input["bounds"], current["point"]):
					features.append({"id": current["id"], "kind": "landmark", "name": label, "class": "", "points": [[current["point"].x, current["point"].y]]})
				current = {}
	var bounds: Array = input.get("bounds", [121.65, 20.2, 122.1, 20.95])
	var clip := PackedVector2Array([Vector2(bounds[0], bounds[1]), Vector2(bounds[2], bounds[1]), Vector2(bounds[2], bounds[3]), Vector2(bounds[0], bounds[3])])
	var counts: Dictionary = {}
	for way in ways:
		var tags: Dictionary = way["tags"]
		var kind := ""
		if tags.has("building"):
			kind = "building"
		elif tags.has("highway"):
			kind = "road"
		elif tags.get("man_made", "") in ["pier", "breakwater", "quay"]:
			kind = "pier"
		elif tags.get("natural") == "coastline":
			kind = "coast"
		if kind.is_empty():
			continue
		var points := PackedVector2Array()
		for ref in way["refs"]:
			if not nodes.has(ref):
				fail("Missing OSM node " + ref + " in " + way["id"])
				return false
			if points.is_empty() or points[-1] != nodes[ref]:
				points.append(nodes[ref])
		if points.size() < 2:
			fail("Degenerate source geometry: " + way["id"])
			return false
		if kind == "coast":
			coast_ways.append({"first": way["refs"][0], "last": way["refs"][-1], "points": points})
		if input.get("coast_only", false):
			continue
		var parts: Array[PackedVector2Array]
		if kind == "building" and points.size() >= 4 and points[0] == points[-1]:
			points.remove_at(points.size() - 1)
			if Geometry2D.triangulate_polygon(points).is_empty():
				fail("Building ring cannot be triangulated: " + way["id"])
				return false
			parts = Geometry2D.intersect_polygons(points, clip)
		else:
			if kind == "building":
				fail("Unclosed building source way: " + way["id"])
				return false
			parts = Geometry2D.intersect_polyline_with_polygon(points, clip)
		for index in parts.size():
			var coordinates: Array = []
			for point in parts[index]:
				coordinates.append([snappedf(clampf(point.x, bounds[0], bounds[2]), 0.0000001), snappedf(clampf(point.y, bounds[1], bounds[3]), 0.0000001)])
			features.append({"id": way["id"] + "/%d" % index, "kind": kind, "name": tags.get("name", ""), "class": tags.get("highway", ""), "points": coordinates})
			counts[kind] = counts.get(kind, 0) + 1
	if not input.get("coast_only", false):
		coverage.append({"id": input["id"], "bounds": bounds, "focus": input["focus"], "zoom": input["zoom"], "counts": counts})
		print("%s: %s" % [input["id"], counts])
	sources.append({"url": input.get("url", "https://api.openstreetmap.org/api/0.6/map?bbox=%s,%s,%s,%s" % bounds), "sha256": input["sha256"], "processing": "Simple building ways, road/coast/port lines and selected named points clipped to town bounds; complete coastline ways joined by node IDs for land masking. Relations and unmapped features are not reconstructed."})
	return true


func close_coasts() -> Array:
	var polygons: Array = []
	while not coast_ways.is_empty():
		var way: Dictionary = coast_ways.pop_back()
		var points: PackedVector2Array = way["points"]
		var end: String = way["last"]
		while end != way["first"]:
			var next := -1
			for index in coast_ways.size():
				if coast_ways[index]["first"] == end:
					next = index
					break
			if next < 0:
				fail("Coastline is not closed at node " + end)
				return []
			var continuation: Dictionary = coast_ways[next]
			coast_ways.remove_at(next)
			points.append_array(continuation["points"].slice(1))
			end = continuation["last"]
		var coordinates: Array = []
		for point in points:
			coordinates.append([point.x, point.y])
		polygons.append(coordinates)
	print("Joined %d complete OSM coast rings." % polygons.size())
	return polygons


func build_mask(polygons: Array) -> void:
	mask.resize(1620 * 2700)
	var rings: Array[PackedVector2Array] = []
	for polygon in polygons:
		var ring := PackedVector2Array()
		var bounds := Rect2(Vector2((polygon[0][0] - 121.65) * 3600, (20.95 - polygon[0][1]) * 3600), Vector2.ZERO)
		for point in polygon:
			var pixel := Vector2((point[0] - 121.65) * 3600, (20.95 - point[1]) * 3600)
			ring.append(pixel)
			bounds = bounds.expand(pixel)
		rings.append(ring)
		bounds = bounds.grow(36)
		for y in range(maxi(0, floori(bounds.position.y)), mini(2700, ceili(bounds.end.y))):
			for x in range(maxi(0, floori(bounds.position.x)), mini(1620, ceili(bounds.end.x))):
				mask[y * 1620 + x] = 1
	for ring in rings:
		for y in 2700:
			var scan := y + 0.5
			var crossings: Array[float] = []
			for index in range(ring.size() - 1):
				var a := ring[index]
				var b := ring[index + 1]
				if (a.y <= scan and b.y > scan) or (b.y <= scan and a.y > scan):
					crossings.append(a.x + (scan - a.y) * (b.x - a.x) / (b.y - a.y))
			crossings.sort()
			for index in range(0, crossings.size(), 2):
				for x in range(maxi(0, ceili(crossings[index] - 0.5)), mini(1620, ceili(crossings[index + 1] - 0.5))):
					mask[y * 1620 + x] = 2


func contains(bounds: Array, point: Vector2) -> bool:
	return point.x >= bounds[0] and point.x <= bounds[2] and point.y >= bounds[1] and point.y <= bounds[3]


func elevation(lon: float, lat: float) -> int:
	var tile := 0 if lon < 122 else 1
	var x := clampi(roundi((lon - (121 + tile)) * 3600), 0, 3600)
	var y := clampi(roundi((21 - lat) * 3600), 0, 3600)
	var offset := (y * 3601 + x) * 2
	var value: int = (int(tiles[tile][offset]) << 8) | int(tiles[tile][offset + 1])
	return value - 65536 if value >= 32768 else value


func build_relief() -> bool:
	var image := Image.create(1620, 2700, false, Image.FORMAT_RGB8)
	var light := Vector3(-0.6, -0.5, 0.65).normalized()
	for y in image.get_height():
		var lat := 20.95 - (y + 0.5) / 3600.0
		for x in image.get_width():
			var lon := 121.65 + (x + 0.5) / 3600.0
			var height := elevation(lon, lat)
			var east := elevation(lon + 1.0 / 3600, lat)
			var north := elevation(lon, lat + 1.0 / 3600)
			if -32768 in [height, east, north]:
				fail("Terrain void at %s,%s; do not silently replace unknown elevation with sea." % [lon, lat])
				return false
			var color := Color("#163d4e")
			if (height > 0 and mask[y * 1620 + x] != 1) or mask[y * 1620 + x] == 2:
				var normal := Vector3(-(east - height) / 28.9, -(north - height) / 30.9, 1).normalized()
				var shade := clampf(0.65 + 0.45 * normal.dot(light), 0.35, 1.1)
				color = Color("#b9caa0").lerp(Color("#789268"), clampf(height / 600.0, 0, 1))
				if height > 600:
					color = color.lerp(Color("#c3b59b"), clampf((height - 600) / 600.0, 0, 1))
				color *= Color(shade, shade, shade)
				if height >= 100 and (height / 100 != east / 100 or height / 100 != north / 100):
					color = color.darkened(0.18)
			image.set_pixel(x, y, color)
	var error := image.save_png("res://content/map_relief.png")
	if error != OK:
		fail("Cannot write relief PNG: " + error_string(error))
		return false
	return true


func fail(message: String) -> void:
	push_error(message)
	quit(1)
