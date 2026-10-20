extends RefCounted


static func load_case(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {"error": "Case file not found: " + path}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {"error": "Cannot open case: " + error_string(FileAccess.get_open_error())}
	var parser := JSON.new()
	var parse_error := parser.parse(file.get_as_text())
	if parse_error != OK:
		return {"error": "Case JSON line %d: %s" % [parser.get_error_line(), parser.get_error_message()]}
	var errors := validate(parser.data)
	if not errors.is_empty():
		return {"error": "Invalid case:\n" + "\n".join(errors)}
	return {"case": parser.data}


static func validate(value: Variant) -> PackedStringArray:
	var errors := PackedStringArray()
	if not value is Dictionary:
		errors.append("Root must be an object.")
		return errors
	var data: Dictionary = value
	for key in ["id", "title", "date", "brief", "disclaimer"]:
		if not data.get(key) is String or str(data.get(key, "")).strip_edges().is_empty():
			errors.append("Missing nonempty text field: " + key)
	if not is_positive_integer(data.get("version")):
		errors.append("version must be a positive integer.")
	for key in ["evidence", "timeline", "places", "findings", "hints"]:
		if not data.get(key) is Array or data.get(key, []).is_empty():
			errors.append(key + " must be a nonempty array.")
	if not errors.is_empty():
		return errors

	var evidence_ids: Array[String] = []
	for item in data["evidence"]:
		if not item is Dictionary:
			errors.append("Evidence must be an object.")
			continue
		for key in ["id", "title", "source", "body", "time"]:
			if not item.get(key) is String or str(item.get(key, "")).strip_edges().is_empty():
				errors.append("Evidence missing text field: " + key)
		if not valid_time(item.get("time")):
			errors.append("Evidence time must be HH:MM UTC.")
		if item.has("time_label") and (not item["time_label"] is String or item["time_label"].strip_edges().is_empty()):
			errors.append("Evidence time label must be nonempty text.")
		var id := str(item.get("id", ""))
		if id in evidence_ids:
			errors.append("Duplicate evidence ID: " + id)
		evidence_ids.append(id)

	var previous_time := ""
	for event in data["timeline"]:
		if not event is Dictionary:
			errors.append("Timeline entry must be an object.")
			continue
		if not valid_time(event.get("time")):
			errors.append("Timeline time must be HH:MM UTC.")
		elif str(event["time"]) < previous_time:
			errors.append("Timeline must be chronological.")
		else:
			previous_time = event["time"]
		if not event.get("label") is String:
			errors.append("Timeline label must be text.")
		if event.get("evidence_id") not in evidence_ids:
			errors.append("Timeline has dangling evidence reference.")
		if event.has("lat") or event.has("lon"):
			if not valid_coordinate(event):
				errors.append("Timeline coordinates out of range or incomplete.")
		if event.has("kind") and event["kind"] not in ["sighting", "public_fix"]:
			errors.append("Unknown observation marker kind.")
		if event.has("marker_label") and (not event["marker_label"] is String or event["marker_label"].is_empty()):
			errors.append("Observation marker label must be nonempty text.")

	for place in data["places"]:
		if not place is Dictionary:
			errors.append("Place must be an object.")
		elif not valid_coordinate(place) or not place.get("name") is String:
			errors.append("Place needs a name and valid coordinates.")

	var finding_ids: Array[String] = []
	for finding in data["findings"]:
		if not finding is Dictionary:
			errors.append("Finding must be an object.")
			continue
		for key in ["id", "question", "explanation", "accepted"]:
			if not finding.get(key) is String or str(finding.get(key, "")).is_empty():
				errors.append("Finding missing text field: " + key)
		var id := str(finding.get("id", ""))
		if id in finding_ids:
			errors.append("Duplicate finding ID: " + id)
		finding_ids.append(id)
		if not finding.get("options") is Array or finding.get("options", []).is_empty():
			errors.append("Finding needs options.")
			continue
		var option_ids: Array[String] = []
		for option in finding["options"]:
			if not option is Dictionary or not option.get("id") is String or not option.get("label") is String:
				errors.append("Option needs text id and label.")
				continue
			if option["id"] in option_ids:
				errors.append("Duplicate option: " + option["id"])
			option_ids.append(option["id"])
		if finding.get("accepted") not in option_ids:
			errors.append("Accepted option does not exist: " + id)
		if not finding.get("required_evidence") is Array or finding.get("required_evidence", []).is_empty():
			errors.append("Finding needs support requirements.")
		else:
			for evidence_id in finding["required_evidence"]:
				if evidence_id not in evidence_ids:
					errors.append("Finding has dangling evidence reference.")
	for hint in data["hints"]:
		if not hint is String or str(hint).is_empty():
			errors.append("Hint must be nonempty text.")
	return errors


static func valid_time(value: Variant) -> bool:
	if not value is String or value.length() != 5 or value[2] != ":":
		return false
	var hours: String = value.substr(0, 2)
	var minutes: String = value.substr(3, 2)
	return hours.is_valid_int() and minutes.is_valid_int() and int(hours) in range(24) and int(minutes) in range(60) and "%02d:%02d" % [int(hours), int(minutes)] == value


static func valid_coordinate(value: Dictionary) -> bool:
	return is_number(value.get("lat")) and is_number(value.get("lon")) and absf(float(value["lat"])) <= 90.0 and absf(float(value["lon"])) <= 180.0


static func is_number(value: Variant) -> bool:
	return (value is float or value is int) and is_finite(float(value))


static func is_positive_integer(value: Variant) -> bool:
	return is_number(value) and float(value) >= 1 and float(value) == floorf(float(value))


static func new_session(data: Dictionary) -> Dictionary:
	var answers := {}
	var citations := {}
	for finding in data["findings"]:
		answers[finding["id"]] = ""
		citations[finding["id"]] = []
	return {
		"save_version": 1,
		"case_id": data["id"],
		"case_version": data["version"],
		"read": [],
		"pinned": [],
		"notes": "",
		"answers": answers,
		"citations": citations,
		"confidence": "Unrecorded",
		"assessment_submitted": false,
		"hint_count": 0
	}


static func validate_session(value: Variant, data: Dictionary) -> String:
	if not value is Dictionary:
		return "Save root must be an object."
	var state: Dictionary = value
	if not state.get("assessment_submitted", false) is bool:
		return "Invalid assessment submission marker."
	if state.get("save_version") != 1 or state.get("case_id") != data["id"] or state.get("case_version") != data["version"]:
		return "Save version or case identity does not match this build."
	if not state.get("notes") is String or state.get("confidence") not in ["Unrecorded", "Low", "Medium", "High"]:
		return "Invalid notes or confidence selection."
	if not is_number(state.get("hint_count")) or float(state["hint_count"]) != floorf(float(state["hint_count"])) or state["hint_count"] < 0 or state["hint_count"] > data["hints"].size():
		return "Invalid hint progress."
	var evidence_ids: Array = data["evidence"].map(func(item: Dictionary) -> String: return item["id"])
	for key in ["read", "pinned"]:
		if not state.get(key) is Array:
			return "Invalid evidence collection: " + key
		var seen: Array = []
		for id in state[key]:
			if id not in evidence_ids or id in seen:
				return "Unknown or repeated evidence ID."
			seen.append(id)
	for id in state["pinned"]:
		if id not in state["read"]:
			return "Pinned evidence must have been read."
	if not state.get("answers") is Dictionary or not state.get("citations") is Dictionary:
		return "Invalid assessment."
	if state["answers"].size() != data["findings"].size() or state["citations"].size() != data["findings"].size():
		return "Unexpected assessment fields."
	for finding in data["findings"]:
		var id: String = finding["id"]
		var options: Array = finding["options"].map(func(item: Dictionary) -> String: return item["id"])
		if state["answers"].get(id) != "" and state["answers"].get(id) not in options:
			return "Unknown assessment answer."
		if not state["citations"].get(id) is Array:
			return "Missing citation collection."
		var seen: Array = []
		for evidence_id in state["citations"][id]:
			if evidence_id not in state["pinned"] or evidence_id in seen:
				return "Citations must refer to distinct pinned evidence."
			seen.append(evidence_id)
	return ""


static func assess(data: Dictionary, state: Dictionary) -> Dictionary:
	var results: Array[Dictionary] = []
	var complete := true
	for finding in data["findings"]:
		var id: String = finding["id"]
		var answer: String = state["answers"][id]
		var missing: Array[String] = []
		for evidence_id in finding["required_evidence"]:
			if evidence_id not in state["citations"][id]:
				missing.append(evidence_id)
		var status := "supported"
		if answer.is_empty():
			status = "incomplete"
		elif answer != finding["accepted"]:
			status = "revise"
		elif not missing.is_empty():
			status = "needs_support"
		if status != "supported":
			complete = false
		results.append({"id": id, "status": status, "missing": missing, "explanation": finding["explanation"]})
	return {"complete": complete, "results": results}
