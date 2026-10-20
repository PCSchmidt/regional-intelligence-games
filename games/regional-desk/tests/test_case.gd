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
	print("CASE TESTS: %d passed, %d failed" % [passed, failed])
	quit(1 if failed else 0)


func check(condition: bool, description: String) -> void:
	if condition:
		passed += 1
	else:
		failed += 1
		push_error("FAIL: " + description)

