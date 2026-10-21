extends SceneTree

const Seabed = preload("res://scripts/seabed.gd")
const Rov = preload("res://scripts/rov_model.gd")
const Rules = preload("res://scripts/survey_rules.gd")
const Store = preload("res://scripts/save_store.gd")
const Geo = preload("res://scripts/geometry.gd")

var passed := 0
var failed := 0


func check(condition: bool, label: String) -> void:
	if condition:
		passed += 1
	else:
		failed += 1
		push_error("FAIL: %s" % label)


func _initialize() -> void:
	var loaded := Rules.load_survey("res://content/survey.json")
	if loaded.has("error"):
		push_error(loaded["error"])
		quit(1)
		return
	var survey: Dictionary = loaded["survey"]

	check_content(survey)
	check_seabed(survey)
	check_rov()
	check_capture(survey)
	check_assessment(survey)
	check_save(survey)
	var terrain := Geo.seabed_mesh()
	var arrays := terrain.surface_get_arrays(0)
	var normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
	check(normals[0].y > 0.5, "Generated terrain normals face the water, not underground")
	var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
	var matching := true
	for point in vertices:
		matching = matching and absf(point.y - Seabed.height_at(point.x, point.z)) < 0.001
	check(matching, "Rendered terrain and collision/instrument floor use identical heights")
	for feature_id in ["slide_lobe", "suspended_span"]:
		var feature := Rules.feature_by_id(survey, feature_id)
		var mesh := Geo.slide_lobe_mesh(feature) if feature_id == "slide_lobe" else Geo.abrasion_mesh(feature)
		var mesh_arrays := mesh.surface_get_arrays(0)
		var mesh_normals: PackedVector3Array = mesh_arrays[Mesh.ARRAY_NORMAL]
		check(mesh_normals[0].y > 0.3, "Evidence surface faces water: " + feature_id)
	for invalid_pilot in [[], {}, {"position": [0, 0, 0], "yaw": 0, "pitch": 0}, {"position": [0, -418, 0], "yaw": "north", "pitch": 0}, {"position": [0, -418, 0], "yaw": 0, "pitch": 8}]:
		var invalid := Rules.new_session(survey)
		invalid["pilot"] = invalid_pilot
		check(not Rules.validate_session(invalid, survey).is_empty(), "Reject malformed/out-of-bounds pilot")
	for key in ["hints", "debrief", "version"]:
		var invalid := survey.duplicate(true)
		invalid[key] = "malformed"
		check(not Rules.validate(invalid).is_empty(), "Report malformed content " + key)
	var bad_option := survey.duplicate(true)
	bad_option["findings"][0]["options"][0] = 3
	check(not Rules.validate(bad_option).is_empty(), "Malformed option reports error without crashing")

	print("SURVEY TESTS: %d passed, %d failed" % [passed, failed])
	quit(0 if failed == 0 else 1)


func check_content(survey: Dictionary) -> void:
	check(Rules.validate(survey).is_empty(), "Authored survey validates")
	check(survey["features"].size() == 4, "Four capturable features")
	check(survey["findings"].size() == 2, "Two findings")
	check(survey["hints"].size() == 4, "Four staged hints")

	var ids := {}
	for feature in survey["features"]:
		ids[str(feature["id"])] = true
	check(ids.has("suspended_span") and ids.has("net_fragment"), "Supporting features present")
	check(ids.has("sediment_channel") and ids.has("slide_lobe"), "Decoy features present")

	var mechanism: Dictionary = survey["findings"][0]
	check(str(mechanism["accepted"]) == "trawl_snag", "Accepted mechanism is trawl snag")
	check(mechanism["required_citations"] == ["suspended_span", "net_fragment"], "Mechanism requires both supporting features")
	var decoy: Dictionary = survey["findings"][1]
	check(str(decoy["accepted"]) == "pre_existing_channel", "Accepted decoy reading is pre-existing channel")

	var broken := survey.duplicate(true)
	broken["features"][0]["id"] = "net_fragment"
	check(not Rules.validate(broken).is_empty(), "Duplicate feature id rejected")
	var missing := survey.duplicate(true)
	missing.erase("findings")
	check(not Rules.validate(missing).is_empty(), "Missing findings rejected")
	var bad_answer := survey.duplicate(true)
	bad_answer["findings"][0]["accepted"] = "not_an_option"
	check(not Rules.validate(bad_answer).is_empty(), "Accepted answer outside options rejected")
	var bad_citation := survey.duplicate(true)
	bad_citation["findings"][0]["required_citations"] = ["ghost_feature"]
	check(not Rules.validate(bad_citation).is_empty(), "Unknown citation rejected")
	var no_radius := survey.duplicate(true)
	no_radius["features"][0]["radius"] = 0.0
	check(not Rules.validate(no_radius).is_empty(), "Non-positive feature radius rejected")
	check(not Rules.load_survey("res://content/absent.json").has("survey"), "Missing content reports an error")


func check_seabed(survey: Dictionary) -> void:
	var centre := Seabed.height_at(0.0, 0.0)
	check(absf(centre - Seabed.BASE_DEPTH) < 3.0, "Seabed sits near the authored base depth")
	check(Seabed.height_at(10.0, 5.0) != Seabed.height_at(-10.0, -5.0), "Seabed height varies across the survey box")

	var span := Seabed.cable_y(0.0)
	check(span > Seabed.height_at(0.0, 0.0) + 1.0, "Cable is lifted above its local seabed at the span centre")
	check(absf(Seabed.cable_y(Seabed.SPAN_HALF_LENGTH) - (Seabed.height_at(Seabed.SPAN_HALF_LENGTH, 0.0) + Seabed.CABLE_RADIUS)) < 0.001, "Span meets the seabed at its contact point")

	var feature := Rules.feature_by_id(survey, "suspended_span")
	var position := Seabed.feature_position(feature)
	check(absf(position.y - Seabed.cable_y(0.0)) < 0.001, "On-cable feature sits on the cable")
	var decoy := Seabed.feature_position(Rules.feature_by_id(survey, "sediment_channel"))
	check(absf(decoy.y - Seabed.height_at(decoy.x, decoy.z)) < 0.001, "Seabed feature sits on the seabed")

	var inside := Vector3(0.0, Seabed.height_at(0.0, 0.0) + 5.0, 0.0)
	check(Seabed.is_inside_bounds(inside), "Interior position is inside bounds")
	check(not Seabed.is_inside_bounds(Vector3(Seabed.HALF_EXTENT + 1.0, inside.y, 0.0)), "Position beyond the box is outside bounds")
	check(not Seabed.is_inside_bounds(Vector3(0.0, Seabed.height_at(0.0, 0.0) + 0.1, 0.0)), "Position below minimum altitude is outside bounds")
	check(not Seabed.is_inside_bounds(Vector3(0.0, Seabed.height_at(0.0, 0.0) + Seabed.MAX_ALTITUDE + 1.0, 0.0)), "Position above maximum altitude is outside bounds")

	var clamped := Seabed.clamp_to_bounds(Vector3(100.0, 0.0, -100.0))
	check(absf(clamped.x) <= Seabed.HALF_EXTENT and absf(clamped.z) <= Seabed.HALF_EXTENT, "Clamp keeps position inside the horizontal box")
	check(Seabed.altitude_at(clamped) >= Seabed.MIN_ALTITUDE - 0.001, "Clamp keeps position above the seabed floor")

	check(Seabed.cable_distance(Vector3(0.0, Seabed.cable_y(0.0), 0.0)) < 0.001, "Cable distance is zero on the cable")
	check(Seabed.cable_distance(Vector3(0.0, Seabed.cable_y(0.0) + 3.0, 0.0)) > 2.9, "Cable distance grows with separation")


func check_rov() -> void:
	var start := Vector3(0.0, Seabed.height_at(0.0, 0.0) + 6.0, 0.0)
	var idle := Rov.step(start, Vector3.ZERO, 0.0, {}, 0.1)
	check((idle["position"] as Vector3).distance_to(start) < 0.001, "No input holds position")
	check((idle["velocity"] as Vector3).length() < 0.001, "No input holds zero velocity")

	var forward := Rov.step(start, Vector3.ZERO, 0.0, { "forward": 1.0 }, 0.1)
	check((forward["position"] as Vector3).z < start.z, "Forward thrust moves along -Z at zero yaw")
	check((forward["velocity"] as Vector3).length() > 0.0, "Forward thrust builds velocity")

	var strafe := Rov.step(start, Vector3.ZERO, 0.0, { "strafe": 1.0 }, 0.1)
	check((strafe["position"] as Vector3).x > start.x, "Strafe moves along +X at zero yaw")

	var rise := Rov.step(start, Vector3.ZERO, 0.0, { "vertical": 1.0 }, 0.1)
	check((rise["position"] as Vector3).y > start.y, "Vertical thrust rises")

	var yawed := Rov.step(start, Vector3.ZERO, 0.0, { "yaw": 1.0 }, 0.1)
	check(float(yawed["yaw"]) > 0.0, "Yaw input rotates the ROV")
	check(absf(Rov.heading_degrees(0.0)) < 0.001, "Zero yaw reads as heading 000")
	check(absf(Rov.heading_degrees(-PI / 2.0) - 90.0) < 0.001, "Negative quarter yaw reads as heading 090")

	var fast := Vector3(Rov.MAX_SPEED * 4.0, 0.0, 0.0)
	var limited := Rov.step(start, fast, 0.0, {}, 0.1)
	var horizontal := Vector2((limited["velocity"] as Vector3).x, (limited["velocity"] as Vector3).z)
	check(horizontal.length() <= Rov.MAX_SPEED + 0.001, "Horizontal speed is capped")
	check(absf((limited["velocity"] as Vector3).y) <= Rov.MAX_VERTICAL_SPEED + 0.001, "Vertical speed is capped")

	var low := Vector3(0.0, Seabed.height_at(0.0, 0.0) + 0.85, 0.0)
	var floor_hit := Rov.step(low, Vector3(0.0, -2.0, 0.0), 0.0, {}, 0.1)
	check(bool(floor_hit["clamped"]), "Seabed floor clamps the ROV")
	check(Seabed.altitude_at(floor_hit["position"]) >= Seabed.MIN_ALTITUDE - 0.001, "Clamped ROV stays above the floor")

	var outside := Vector3(Seabed.HALF_EXTENT + 5.0, start.y, 0.0)
	var box_hit := Rov.step(outside, Vector3(2.0, 0.0, 0.0), 0.0, {}, 0.1)
	check(absf((box_hit["position"] as Vector3).x) <= Seabed.HALF_EXTENT + 0.001, "Survey box clamps the ROV")

	var position := start
	var velocity := Vector3.ZERO
	var yaw := 0.0
	var inputs := [
		{ "forward": 1.0 }, { "forward": 1.0, "yaw": 0.5 }, { "strafe": -1.0 },
		{ "vertical": 1.0 }, { "forward": -1.0 }, {}
	]
	for input in inputs:
		var result := Rov.step(position, velocity, yaw, input, 1.0 / 60.0)
		position = result["position"]
		velocity = result["velocity"]
		yaw = result["yaw"]
	var replay := start
	var replay_velocity := Vector3.ZERO
	var replay_yaw := 0.0
	for input in inputs:
		var result := Rov.step(replay, replay_velocity, replay_yaw, input, 1.0 / 60.0)
		replay = result["position"]
		replay_velocity = result["velocity"]
		replay_yaw = result["yaw"]
	check(position.is_equal_approx(replay), "Fixed input sequence is reproducible")
	check(absf(yaw - replay_yaw) < 0.000001, "Fixed yaw sequence is reproducible")


func check_capture(survey: Dictionary) -> void:
	var session := Rules.new_session(survey)
	var span := Seabed.feature_position(Rules.feature_by_id(survey, "suspended_span"))
	var near := span + Vector3(0.0, 1.5, 3.0)
	var toward := (span - near).normalized()

	check(Rules.capture_blocker(survey, "suspended_span", near, toward).is_empty(), "In-range framed feature has no blocker")
	var far := span + Vector3(0.0, 0.0, 20.0)
	check(Rules.capture_blocker(survey, "suspended_span", far, Vector3.FORWARD).contains("Too far"), "Out-of-range capture is blocked")
	var behind := span + Vector3(0.0, 1.5, 3.0)
	check(Rules.capture_blocker(survey, "suspended_span", behind, -toward).contains("outside the camera frame"), "Feature behind the camera is blocked")
	check(Rules.capture_blocker(survey, "ghost", near, toward).contains("Unknown feature"), "Unknown feature is blocked")

	var added := Rules.add_capture(session, survey, "suspended_span", near, toward, 12.345)
	check(not added.has("error"), "Valid capture is recorded")
	check(session["captures"].size() == 1, "Capture log grows")
	var capture: Dictionary = session["captures"][0]
	check(str(capture["feature"]) == "suspended_span", "Capture records the feature id")
	check(absf(float(capture["elapsed"]) - 12.35) < 0.001, "Capture records elapsed time")
	check(absf(float(capture["depth"]) - (-near.y)) < 0.01, "Capture records actual depth below sea level, not offset from seabed")
	check((capture["position"] as Array).size() == 3, "Capture records position")

	check(Rules.add_capture(session, survey, "suspended_span", near, toward, 13.0).has("error"), "Duplicate capture is rejected")
	check(Rules.captured_ids(session) == ["suspended_span"], "Captured ids list recorded features")

	var net := Seabed.feature_position(Rules.feature_by_id(survey, "net_fragment"))
	var net_near := net + Vector3(0.0, 1.0, 2.5)
	check(not Rules.add_capture(session, survey, "net_fragment", net_near, (net - net_near).normalized(), 20.0).has("error"), "Second feature can be captured")

	var full := Rules.new_session(survey)
	full["captures"] = []
	for index in Rules.MAX_CAPTURES:
		full["captures"].append({ "feature": "filler_%d" % index })
	check(Rules.add_capture(full, survey, "suspended_span", near, toward, 1.0).get("error", "").contains("full"), "Full log hits capacity rule, not an unrelated range failure")


func check_assessment(survey: Dictionary) -> void:
	var session := Rules.new_session(survey)
	var empty := Rules.evaluate(session, survey)
	check(not bool(empty["all_supported"]), "Empty assessment is unsupported")
	check(Rules.supported_count(empty) == 0, "Empty assessment supports nothing")

	session["answers"]["mechanism"] = "trawl_snag"
	session["citations"]["mechanism"] = ["suspended_span", "net_fragment"]
	session["answers"]["decoy"] = "pre_existing_channel"
	session["citations"]["decoy"] = ["sediment_channel"]
	check(not bool(Rules.evaluate(session, survey)["all_supported"]), "Citations without captured evidence cannot complete the survey")
	for feature in survey["features"]:
		var target := Seabed.feature_position(feature)
		var camera := target + Vector3(0, 1.5, 3)
		Rules.add_capture(session, survey, feature["id"], camera, (target - camera).normalized(), 10.0)
	var complete := Rules.evaluate(session, survey)
	check(bool(complete["all_supported"]), "Correct answers with citations are supported")
	check(Rules.supported_count(complete) == 2, "Both findings supported")

	for alternative in ["anchor_drag", "slope_failure"]:
		var wrong := session.duplicate(true)
		wrong["answers"]["mechanism"] = alternative
		var result := Rules.evaluate(wrong, survey)
		check(not bool(result["all_supported"]), "Rejected mechanism %s is unsupported" % alternative)
		check(not bool(result["results"][0]["answer_ok"]), "Rejected mechanism %s is marked wrong" % alternative)

	for alternative in ["recent_anchor_drag", "active_slope_failure"]:
		var wrong := session.duplicate(true)
		wrong["answers"]["decoy"] = alternative
		check(not bool(Rules.evaluate(wrong, survey)["all_supported"]), "Rejected decoy reading %s is unsupported" % alternative)

	for missing in ["suspended_span", "net_fragment"]:
		var partial := session.duplicate(true)
		partial["citations"]["mechanism"] = ["suspended_span", "net_fragment"].filter(func(id): return id != missing)
		var result := Rules.evaluate(partial, survey)
		check(not bool(result["all_supported"]), "Missing citation %s is unsupported" % missing)
		check(result["results"][0]["missing_citations"] == [missing], "Missing citation %s is reported" % missing)

	var no_decoy_citation := session.duplicate(true)
	no_decoy_citation["citations"]["decoy"] = []
	var decoy_result := Rules.evaluate(no_decoy_citation, survey)
	check(not bool(decoy_result["all_supported"]), "Missing decoy citation is unsupported")
	check(decoy_result["results"][1]["missing_citations"] == ["sediment_channel"], "Missing decoy citation is reported")

	var answer_only := session.duplicate(true)
	answer_only["citations"]["mechanism"] = []
	var answer_only_result := Rules.evaluate(answer_only, survey)
	check(bool(answer_only_result["results"][0]["answer_ok"]), "Answer-only correction is recognised as correct")
	check(not bool(answer_only_result["results"][0]["supported"]), "Answer-only correction is still unsupported")


func check_save(survey: Dictionary) -> void:
	var directory := "user://survey-tests-%d" % OS.get_process_id()
	check(DirAccess.make_dir_recursive_absolute(directory) == OK, "Create isolated save directory")
	var path := directory.path_join("session.json")

	var fresh := Store.load_session(path, survey)
	check(bool(fresh.get("new", false)), "Missing save starts a new session")
	check(str(fresh["state"]["phase"]) == "deck", "New session starts on deck")

	var state := Rules.new_session(survey)
	state["phase"] = "survey"
	state["answers"]["mechanism"] = "trawl_snag"
	state["citations"]["mechanism"] = ["suspended_span", "net_fragment"]
	state["hint_count"] = 2
	state["elapsed_seconds"] = 91.5
	for feature in survey["features"]:
		var target := Seabed.feature_position(feature)
		var camera := target + Vector3(0, 1.5, 3)
		Rules.add_capture(state, survey, feature["id"], camera, (target - camera).normalized(), 10.0)
	check(Store.write_session(path, state, survey).is_empty(), "Write valid save")
	var restored := Store.load_session(path, survey)
	check(not restored.has("error"), "Load written save")
	var expected: Dictionary = JSON.parse_string(JSON.stringify(state))
	check(restored["state"].recursive_equal(expected, 8), "Every state field round trips")

	state["hint_count"] = 3
	check(Store.write_session(path, state, survey).is_empty(), "Replace existing save")
	check(int(Store.load_session(path, survey)["state"]["hint_count"]) == 3, "Replacement persists")

	var legacy := state.duplicate(true)
	legacy.erase("assessment_submitted")
	check(Store.write_session(path, legacy, survey).is_empty(), "Older save without a newer field remains writable")
	check(Store.load_session(path, survey)["state"].has("assessment_submitted"), "Missing field is filled from defaults")

	check(Store.write_session(path, state, survey).is_empty(), "Restore current fixture")
	var original := FileAccess.get_file_as_string(path)
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string("{ not json")
	file.close()
	var corrupt := Store.load_session(path, survey)
	check(corrupt.has("error"), "Corrupt save reports an error")
	check(FileAccess.get_file_as_string(path) == "{ not json", "Corrupt save is preserved, not overwritten")
	check(not Store.write_session(path, state, survey).is_empty(), "Writing cannot overwrite an unreadable save without explicit reset")
	check(FileAccess.get_file_as_string(path) == "{ not json", "Failed write preserves corrupt original")

	file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(original)
	file.close()
	var wrong_version: Dictionary = JSON.parse_string(original)
	wrong_version["save_version"] = 99
	file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(JSON.stringify(wrong_version))
	file.close()
	check(Store.load_session(path, survey).has("error"), "Unsupported save version reports an error")

	var other := survey.duplicate(true)
	other["survey_id"] = "different-survey"
	file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(original)
	file.close()
	check(Store.load_session(path, other).has("error"), "Save from another survey reports an error")

	check(Store.write_session(directory.path_join("missing").path_join("session.json"), state, survey).is_empty(), "Nested save directory is created")
	check(Store.write_session("", state, survey) != "", "Empty save path reports an error")

	DirAccess.remove_absolute(path)
	DirAccess.remove_absolute(directory.path_join("missing").path_join("session.json"))
	DirAccess.remove_absolute(directory.path_join("missing"))
	DirAccess.remove_absolute(directory)
	check(not DirAccess.dir_exists_absolute(directory), "Isolated save directory cleaned up")
