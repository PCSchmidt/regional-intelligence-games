extends RefCounted

## Content validation, capture rules and assessment scoring. No scene access, so
## every rule is testable headlessly.

const Seabed = preload("res://scripts/seabed.gd")

const CAPTURE_RANGE := 6.0
const CAPTURE_CONE_DOT := 0.55
const MAX_CAPTURES := 12


static func load_survey(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return { "error": "Survey content missing: %s" % path }
	var text := FileAccess.get_file_as_string(path)
	var parser := JSON.new()
	if parser.parse(text) != OK or typeof(parser.data) != TYPE_DICTIONARY:
		return { "error": "Survey content is not valid JSON: %s" % path }
	var survey: Dictionary = parser.data
	var problem := validate(survey)
	if not problem.is_empty():
		return { "error": problem }
	return { "survey": survey }


static func validate(survey: Dictionary) -> String:
	for key in ["survey_id", "version", "title", "brief", "question", "features", "findings", "hints", "debrief"]:
		if not survey.has(key):
			return "Survey is missing required key: %s" % key
	for key in ["survey_id", "title", "brief", "question"]:
		if typeof(survey[key]) != TYPE_STRING or survey[key].is_empty():
			return "Survey needs nonempty text for %s" % key
	if typeof(survey["version"]) not in [TYPE_INT, TYPE_FLOAT] or float(survey["version"]) < 1 or float(survey["version"]) != int(survey["version"]):
		return "Survey version must be a positive integer"
	if typeof(survey["hints"]) != TYPE_ARRAY:
		return "Survey hints must be an array"
	for hint in survey["hints"]:
		if typeof(hint) != TYPE_STRING:
			return "Hints must be text"
	if typeof(survey["debrief"]) != TYPE_DICTIONARY:
		return "Survey debrief must be an object"
	for key in ["supported", "unsupported"]:
		if typeof(survey["debrief"].get(key)) != TYPE_STRING:
			return "Survey debrief needs %s text" % key
	if typeof(survey["features"]) != TYPE_ARRAY or (survey["features"] as Array).is_empty():
		return "Survey must define at least one feature"
	if typeof(survey["findings"]) != TYPE_ARRAY or (survey["findings"] as Array).is_empty():
		return "Survey must define at least one finding"

	var feature_ids := {}
	for feature in survey["features"]:
		if typeof(feature) != TYPE_DICTIONARY:
			return "Feature entries must be objects"
		var id := str(feature.get("id", ""))
		if id.is_empty():
			return "Feature is missing an id"
		if feature_ids.has(id):
			return "Duplicate feature id: %s" % id
		feature_ids[id] = true
		if not feature.has("x") or not feature.has("z"):
			return "Feature %s is missing coordinates" % id
		for key in ["x", "z", "radius"]:
			if typeof(feature.get(key)) not in [TYPE_INT, TYPE_FLOAT] or not is_finite(float(feature[key])):
				return "Feature %s has invalid %s" % [id, key]
		if absf(feature["x"]) > Seabed.HALF_EXTENT or absf(feature["z"]) > Seabed.HALF_EXTENT:
			return "Feature %s is outside the survey box" % id
		for key in ["label", "description"]:
			if typeof(feature.get(key)) != TYPE_STRING:
				return "Feature %s needs %s text" % [id, key]
		if float(feature["radius"]) <= 0.0:
			return "Feature %s must have a positive radius" % id

	var finding_ids := {}
	for finding in survey["findings"]:
		if typeof(finding) != TYPE_DICTIONARY:
			return "Finding entries must be objects"
		var id := str(finding.get("id", ""))
		if id.is_empty():
			return "Finding is missing an id"
		if finding_ids.has(id):
			return "Duplicate finding id: %s" % id
		finding_ids[id] = true
		if typeof(finding.get("prompt")) != TYPE_STRING or typeof(finding.get("options")) != TYPE_ARRAY:
			return "Finding %s needs a prompt and options array" % id
		var options: Array = finding["options"]
		if options.size() < 2:
			return "Finding %s needs at least two options" % id
		var option_ids := {}
		for option in options:
			if typeof(option) != TYPE_DICTIONARY or typeof(option.get("label")) != TYPE_STRING:
				return "Finding %s has an invalid option" % id
			var option_id := str(option.get("id", ""))
			if option_id.is_empty():
				return "Finding %s has an option without an id" % id
			if option_ids.has(option_id):
				return "Finding %s has duplicate option %s" % [id, option_id]
			option_ids[option_id] = true
		var accepted := str(finding.get("accepted", ""))
		if not option_ids.has(accepted):
			return "Finding %s accepted answer is not one of its options" % id
		if typeof(finding.get("required_citations")) != TYPE_ARRAY:
			return "Finding %s needs a citation array" % id
		var required: Array = finding["required_citations"]
		if required.is_empty():
			return "Finding %s must require at least one citation" % id
		for citation in required:
			if not feature_ids.has(str(citation)):
				return "Finding %s cites unknown feature %s" % [id, str(citation)]
	return ""


static func new_session(survey: Dictionary) -> Dictionary:
	return {
		"survey_id": str(survey.get("survey_id", "")),
		"survey_version": int(survey.get("version", 1)),
		"phase": "deck",
		"captures": [],
		"answers": {},
		"citations": {},
		"hint_count": 0,
		"assessment_submitted": false,
		"elapsed_seconds": 0.0
	}


static func feature_by_id(survey: Dictionary, feature_id: String) -> Dictionary:
	for feature in survey.get("features", []):
		if str(feature.get("id", "")) == feature_id:
			return feature
	return {}


static func capture_blocker(survey: Dictionary, feature_id: String, rov_position: Vector3, rov_forward: Vector3) -> String:
	var feature := feature_by_id(survey, feature_id)
	if feature.is_empty():
		return "Unknown feature: %s" % feature_id
	var target := Seabed.feature_position(feature)
	var offset := target - rov_position
	var distance := offset.length()
	if distance > CAPTURE_RANGE:
		return "Too far from %s (%.1f m, limit %.1f m)" % [str(feature.get("label", feature_id)), distance, CAPTURE_RANGE]
	if distance > 0.001 and rov_forward.normalized().dot(offset.normalized()) < CAPTURE_CONE_DOT:
		return "%s is outside the camera frame" % str(feature.get("label", feature_id))
	return ""


static func add_capture(session: Dictionary, survey: Dictionary, feature_id: String, rov_position: Vector3, rov_forward: Vector3, elapsed: float) -> Dictionary:
	var blocker := capture_blocker(survey, feature_id, rov_position, rov_forward)
	if not blocker.is_empty():
		return { "error": blocker }
	var captures: Array = session.get("captures", [])
	if captures.size() >= MAX_CAPTURES:
		return { "error": "Capture log is full (%d)" % MAX_CAPTURES }
	for capture in captures:
		if str(capture.get("feature", "")) == feature_id:
			return { "error": "Already captured: %s" % feature_id }
	var feature := feature_by_id(survey, feature_id)
	captures.append({
		"feature": feature_id,
		"label": str(feature.get("label", feature_id)),
		"elapsed": snappedf(elapsed, 0.01),
		"depth": snappedf(-rov_position.y, 0.01),
		"position": [snappedf(rov_position.x, 0.01), snappedf(rov_position.y, 0.01), snappedf(rov_position.z, 0.01)]
	})
	session["captures"] = captures
	return { "capture": captures[captures.size() - 1] }


static func captured_ids(session: Dictionary) -> Array:
	var ids := []
	for capture in session.get("captures", []):
		ids.append(str(capture.get("feature", "")))
	return ids


static func evaluate(session: Dictionary, survey: Dictionary) -> Dictionary:
	var results := []
	var all_supported := true
	for finding in survey.get("findings", []):
		var id := str(finding.get("id", ""))
		var answer := str(session.get("answers", {}).get(id, ""))
		var citations: Array = session.get("citations", {}).get(id, [])
		var required: Array = finding.get("required_citations", [])
		var missing := []
		for citation in required:
			if not citations.has(str(citation)) or not captured_ids(session).has(str(citation)):
				missing.append(str(citation))
		var answer_ok := answer == str(finding.get("accepted", ""))
		var supported := answer_ok and missing.is_empty()
		if not supported:
			all_supported = false
		results.append({
			"id": id,
			"answer": answer,
			"answer_ok": answer_ok,
			"missing_citations": missing,
			"supported": supported
		})
	return { "results": results, "all_supported": all_supported }


static func supported_count(evaluation: Dictionary) -> int:
	var count := 0
	for result in evaluation.get("results", []):
		if bool(result.get("supported", false)):
			count += 1
	return count


static func validate_session(state: Dictionary, survey: Dictionary) -> String:
	if state.get("survey_id", "") != survey["survey_id"] or state.get("survey_version", 0) != survey["version"]:
		return "Save content identity/version mismatch."
	if state.get("phase", "") not in ["deck", "survey"]:
		return "Invalid saved phase."
	for key in ["answers", "citations"]:
		if typeof(state.get(key)) != TYPE_DICTIONARY:
			return "Invalid saved %s." % key
	if typeof(state.get("captures")) != TYPE_ARRAY or state["captures"].size() > MAX_CAPTURES:
		return "Invalid capture log."
	var ids := []
	for capture in state["captures"]:
		if typeof(capture) != TYPE_DICTIONARY:
			return "Invalid capture entry."
		var id := str(capture.get("feature", ""))
		if feature_by_id(survey, id).is_empty() or ids.has(id):
			return "Unknown or repeated captured feature."
		ids.append(id)
		if capture.has("frame") and (typeof(capture["frame"]) != TYPE_STRING or not capture["frame"].is_valid_filename() or not capture["frame"].ends_with(".png")):
			return "Invalid captured image filename."
		var point = capture.get("position")
		if typeof(point) != TYPE_ARRAY or point.size() != 3:
			return "Invalid capture coordinates."
		for value in point:
			if typeof(value) not in [TYPE_INT, TYPE_FLOAT] or not is_finite(float(value)):
				return "Invalid capture coordinate value."
		for key in ["depth", "elapsed"]:
			if typeof(capture.get(key)) not in [TYPE_INT, TYPE_FLOAT] or not is_finite(float(capture[key])) or float(capture[key]) < 0:
				return "Invalid capture %s." % key
		if absf(float(capture["depth"]) + float(point[1])) > 0.02:
			return "Capture depth disagrees with position."
	for finding in survey["findings"]:
		var id: String = finding["id"]
		var answer: String = str(state["answers"].get(id, ""))
		if not answer.is_empty() and not finding["options"].any(func(option: Dictionary) -> bool: return option["id"] == answer):
			return "Invalid answer for %s." % id
		var citations = state["citations"].get(id, [])
		if typeof(citations) != TYPE_ARRAY:
			return "Invalid citations."
		for citation in citations:
			if not ids.has(citation):
				return "Citation refers to an uncaptured feature."
	if typeof(state.get("hint_count")) not in [TYPE_INT, TYPE_FLOAT] or not is_finite(float(state["hint_count"])) or float(state["hint_count"]) != int(state["hint_count"]) or int(state["hint_count"]) < 0 or int(state["hint_count"]) > survey["hints"].size():
		return "Invalid hint count."
	if typeof(state.get("elapsed_seconds")) not in [TYPE_INT, TYPE_FLOAT] or not is_finite(float(state["elapsed_seconds"])) or float(state["elapsed_seconds"]) < 0:
		return "Invalid elapsed time."
	if typeof(state.get("assessment_submitted", false)) != TYPE_BOOL:
		return "Invalid submission flag."
	if state.has("pilot"):
		if typeof(state["pilot"]) != TYPE_DICTIONARY:
			return "Invalid pilot state."
		var point = state["pilot"].get("position")
		if typeof(point) != TYPE_ARRAY or point.size() != 3:
			return "Invalid pilot coordinates."
		for value in point:
			if typeof(value) not in [TYPE_INT, TYPE_FLOAT] or not is_finite(float(value)):
				return "Invalid pilot coordinate value."
		for key in ["yaw", "pitch"]:
			if typeof(state["pilot"].get(key)) not in [TYPE_INT, TYPE_FLOAT] or not is_finite(float(state["pilot"][key])):
				return "Invalid pilot orientation."
		if not Seabed.is_inside_bounds(Vector3(float(point[0]), float(point[1]), float(point[2]))):
			return "Pilot outside survey bounds."
		if float(state["pilot"]["pitch"]) < -1.25 or float(state["pilot"]["pitch"]) > 0.8:
			return "Pilot pitch outside camera limits."
	return ""
