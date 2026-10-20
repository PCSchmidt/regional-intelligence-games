extends SceneTree

const Rules = preload("res://scripts/case_rules.gd")
var passed := 0
var failed := 0


func _initialize() -> void:
	var loaded := Rules.load_case("res://content/case_01.json")
	check(loaded.has("case"), "Case fixture loads and validates")
	if not loaded.has("case"):
		quit(1)
		return
	var data: Dictionary = loaded["case"]
	check(data["evidence"].size() == 6, "Six evidence records")
	check(data["findings"].size() == 3, "Three findings")
	check(Rules.validate(null).size() > 0, "Reject non-object")
	var broken := data.duplicate(true)
	broken["timeline"][0]["evidence_id"] = "missing"
	check(not Rules.validate(broken).is_empty(), "Reject dangling timeline evidence")
	broken = data.duplicate(true)
	broken["evidence"][1]["id"] = broken["evidence"][0]["id"]
	check(not Rules.validate(broken).is_empty(), "Reject duplicate evidence")
	broken = data.duplicate(true)
	broken["findings"][0]["accepted"] = "missing"
	check(not Rules.validate(broken).is_empty(), "Reject missing accepted option")
	broken = data.duplicate(true)
	broken["places"][0]["lat"] = 95
	check(not Rules.validate(broken).is_empty(), "Reject invalid latitude")
	broken = data.duplicate(true)
	broken["findings"][0]["required_evidence"] = ["missing"]
	check(not Rules.validate(broken).is_empty(), "Reject dangling required support")
	broken = data.duplicate(true)
	broken["timeline"][0]["time"] = "99:00"
	check(not Rules.validate(broken).is_empty(), "Reject invalid UTC time")
	broken = data.duplicate(true)
	broken["timeline"].reverse()
	check(not Rules.validate(broken).is_empty(), "Reject unsorted chronology")
	broken = data.duplicate(true)
	broken["version"] = 1.5
	check(not Rules.validate(broken).is_empty(), "Reject fractional content version")

	var state := Rules.new_session(data)
	check(Rules.validate_session(state, data).is_empty(), "Fresh session validates")
	var result := Rules.assess(data, state)
	check(not result["complete"], "Incomplete assessment cannot pass")
	check(result["results"][0]["status"] == "incomplete", "Incomplete feedback classification")
	for finding in data["findings"]:
		state["answers"][finding["id"]] = finding["accepted"]
	result = Rules.assess(data, state)
	check(result["results"][0]["status"] == "needs_support", "Right answer without citations needs support")
	for finding in data["findings"]:
		for id in finding["required_evidence"]:
			if id not in state["read"]:
				state["read"].append(id)
				state["pinned"].append(id)
		state["citations"][finding["id"]] = finding["required_evidence"].duplicate()
	check(Rules.assess(data, state)["complete"], "Fully supported assessment passes")
	for level in ["Low", "Medium", "High", "Unrecorded"]:
		state["confidence"] = level
		check(Rules.assess(data, state)["complete"], "Confidence is not penalized: " + level)
	state["answers"]["intent"] = "cleared"
	check(Rules.assess(data, state)["results"][2]["status"] == "revise", "Reject overclaim that all misconduct is disproven")
	state["answers"]["intent"] = "hostile"
	check(Rules.assess(data, state)["results"][2]["status"] == "revise", "Reject gap as proof of hostile intent")
	state["answers"]["intent"] = "not_established"
	state["citations"]["stop"] = ["manifest", "tracks"]
	check(Rules.assess(data, state)["results"][0]["status"] == "needs_support", "Unrelated citations do not replace corroboration")
	var second := Rules.load_case("res://content/case_02.json")
	check(second.has("case"), "Second case loads and validates")
	if not second.has("case"):
		quit(1)
		return
	var data2: Dictionary = second["case"]
	check(data2["evidence"].size() == 7 and data2["findings"].size() == 3, "Second case has seven records and three distinct findings")
	var state2 := Rules.new_session(data2)
	check(not Rules.assess(data2, state2)["complete"], "Second case starts incomplete")
	for evidence in data2["evidence"]:
		state2["read"].append(evidence["id"])
		state2["pinned"].append(evidence["id"])
	for finding in data2["findings"]:
		state2["answers"][finding["id"]] = finding["accepted"]
		state2["citations"][finding["id"]] = finding["required_evidence"].duplicate()
	check(Rules.assess(data2, state2)["complete"] and Rules.validate_session(state2, data2).is_empty(), "Second case fully supported state passes and validates")
	for index in range(data2["findings"].size()):
		var finding: Dictionary = data2["findings"][index]
		for option in finding["options"]:
			if option["id"] != finding["accepted"]:
				state2["answers"][finding["id"]] = option["id"]
				check(Rules.assess(data2, state2)["results"][index]["status"] == "revise", "Reject second-case alternative " + option["id"])
		state2["answers"][finding["id"]] = finding["accepted"]
		for id in finding["required_evidence"]:
			state2["citations"][finding["id"]] = finding["required_evidence"].duplicate()
			state2["citations"][finding["id"]].erase(id)
			check(Rules.assess(data2, state2)["results"][index]["status"] == "needs_support", "Require decisive source " + id + " for " + finding["id"])
		state2["citations"][finding["id"]] = ["assignment", "claim"]
		check(Rules.assess(data2, state2)["results"][index]["status"] == "needs_support", "Unrelated sources cannot substitute for " + finding["id"])
		state2["citations"][finding["id"]] = finding["required_evidence"].duplicate()
	check(not Rules.validate_session(state2, data).is_empty(), "Second-case state cannot overwrite first case")
	check(not Rules.validate_session(state, data2).is_empty(), "First-case state cannot masquerade as second case")
	var image_events: Array = data2["timeline"].filter(func(event: Dictionary) -> bool: return event["evidence_id"] == "image")
	check(image_events.size() == 1 and image_events[0]["time"] == "08:45" and not image_events[0].has("lat"), "Timeline shows image indexing, not a pre-solved capture fix")
	broken = data2.duplicate(true)
	broken["timeline"][0]["kind"] = "unknown"
	check(not Rules.validate(broken).is_empty(), "Reject unknown observation symbol")
	broken = data2.duplicate(true)
	broken["timeline"][0]["marker_label"] = 42
	check(not Rules.validate(broken).is_empty(), "Reject malformed observation label")
	broken = data2.duplicate(true)
	broken["evidence"][2]["time_label"] = " "
	check(not Rules.validate(broken).is_empty(), "Reject blank evidence timestamp meaning")
	broken["evidence"][2]["time_label"] = 42
	check(not Rules.validate(broken).is_empty(), "Reject non-text evidence timestamp meaning")
	test_third_case(data, data2)
	print("CASE TESTS: %d passed, %d failed" % [passed, failed])
	quit(1 if failed else 0)


func test_third_case(first: Dictionary, second: Dictionary) -> void:
	var loaded := Rules.load_case("res://content/case_03.json")
	check(loaded.has("case"), "Approved third case loads and validates")
	if not loaded.has("case"):
		return
	var data: Dictionary = loaded["case"]
	check(data["id"] == "echoed-warning" and data["version"] == 1 and data["date"] == "2026-09-16", "Third-case identity and date match design")
	check(data["evidence"].size() == 6 and data["findings"].size() == 3 and data["hints"].size() == 4, "Third case has six records, three findings and four hints")
	check(data["timeline"].size() == 8 and data["places"] == second["places"], "Eight timeline events reuse real places without new facilities")
	var expected_times := ["07:55", "08:00", "08:10", "08:25", "08:40", "08:45", "08:55", "09:00"]
	for index in range(data["timeline"].size()):
		var event: Dictionary = data["timeline"][index]
		check(event["time"] == expected_times[index] and not event.has("lat") and not event.has("lon") and not event.has("kind"), "Third-case timeline event has explicit UTC without invented position")
	for evidence in data["evidence"]:
		check(evidence.has("time_label") and evidence["body"].contains("UTC"), "Third-case source labels event/publication clock: " + evidence["id"])
	check(data["evidence"][2]["body"].contains("M17") and data["evidence"][3]["body"].contains("RB4"), "Both attribution links are present")
	check(data["evidence"][4]["body"].contains("M17-C") and data["evidence"][4]["body"].contains("B remains cordoned"), "Correction explicitly revises the original without erasing disruption")
	check(data["evidence"][5]["body"].contains("DH21") and data["evidence"][5]["body"].contains("08:45 UTC") and data["evidence"][5]["body"].contains("08:55 UTC"), "Independent ledger distinguishes event and filing times")
	var rubric := {
		"origins": {"accepted": "one_origin", "required": ["original", "bulletin", "digest"]},
		"corrected_scope": {"accepted": "limited_restriction", "required": ["original", "correction"]},
		"corroboration": {"accepted": "bounded_corroboration", "required": ["correction", "ledger"]}
	}
	var state := Rules.new_session(data)
	check(not Rules.assess(data, state)["complete"], "Third case starts incomplete")
	for evidence in data["evidence"]:
		state["read"].append(evidence["id"])
		state["pinned"].append(evidence["id"])
	for finding in data["findings"]:
		var id: String = finding["id"]
		check(rubric.has(id) and finding["accepted"] == rubric[id]["accepted"] and finding["required_evidence"] == rubric[id]["required"] and finding["options"].size() == 3, "Exact approved rubric for " + id)
		state["answers"][id] = rubric[id]["accepted"]
		state["citations"][id] = rubric[id]["required"].duplicate()
	check(Rules.assess(data, state)["complete"] and Rules.validate_session(state, data).is_empty(), "Third case accepts the exact fully supported authored assessment")
	for index in range(data["findings"].size()):
		var finding: Dictionary = data["findings"][index]
		var id: String = finding["id"]
		for option in finding["options"]:
			if option["id"] != finding["accepted"]:
				state["answers"][id] = option["id"]
				check(Rules.assess(data, state)["results"][index]["status"] == "revise", "Reject third-case alternative " + option["id"])
		state["answers"][id] = finding["accepted"]
		for source in finding["required_evidence"]:
			state["citations"][id] = finding["required_evidence"].duplicate()
			state["citations"][id].erase(source)
			var result: Dictionary = Rules.assess(data, state)["results"][index]
			check(result["status"] == "needs_support" and result["missing"] == [source], "Require each approved source " + source + " for " + id)
		state["citations"][id] = ["assignment"]
		check(Rules.assess(data, state)["results"][index]["status"] == "needs_support", "Request cannot substitute for third-case support " + id)
		state["citations"][id] = finding["required_evidence"].duplicate()
	state["citations"]["origins"] = ["original", "bulletin", "ledger"]
	check(Rules.assess(data, state)["results"][0]["missing"] == ["digest"], "Independent ledger cannot replace a missing attribution link")
	state["citations"]["origins"] = rubric["origins"]["required"].duplicate()
	state["citations"]["corroboration"] = ["original", "bulletin", "digest"]
	check(Rules.assess(data, state)["results"][2]["status"] == "needs_support", "Repeated reports cannot replace independent corroboration")
	state["citations"]["corroboration"] = rubric["corroboration"]["required"].duplicate()
	for other in [first, second]:
		check(not Rules.validate_session(state, other).is_empty(), "Third session cannot overwrite an earlier case")
		check(not Rules.validate_session(Rules.new_session(other), data).is_empty(), "Earlier session cannot masquerade as third case")


func check(condition: bool, description: String) -> void:
	if condition:
		passed += 1
	else:
		failed += 1
		push_error("FAIL: " + description)
