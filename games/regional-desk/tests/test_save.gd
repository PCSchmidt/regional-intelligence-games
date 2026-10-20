extends SceneTree

const Rules = preload("res://scripts/case_rules.gd")
const Store = preload("res://scripts/save_store.gd")
var passed := 0
var failed := 0


func _initialize() -> void:
	var loaded := Rules.load_case("res://content/case_01.json")
	if loaded.has("error"):
		push_error(loaded["error"])
		quit(1)
		return
	var data: Dictionary = loaded["case"]
	var directory := "user://save-tests-%d" % OS.get_process_id()
	check(DirAccess.make_dir_absolute(directory) == OK, "Create isolated test directory")
	var path := directory.path_join("session.json")
	check(Store.load_session(path, data).get("new", false), "Missing save starts a new session")
	var state := Rules.new_session(data)
	state["notes"] = "My notes: a claim is not an observation.\nSecond line."
	state["read"] = ["lookout", "receipt"]
	state["pinned"] = ["lookout", "receipt"]
	state["answers"]["stop"] = "itbayat"
	state["citations"]["stop"] = ["lookout", "receipt"]
	state["confidence"] = "Medium"
	state["hint_count"] = 2
	state["assessment_submitted"] = true
	check(Store.write_session(path, state, data).is_empty(), "Write valid save")
	var restored := Store.load_session(path, data)
	check(not restored.has("error"), "Load written save")
	var expected: Dictionary = JSON.parse_string(JSON.stringify(state))
	check(restored["state"].recursive_equal(expected, 8), "Every state field round trips through JSON numeric types")
	state["notes"] = "Updated notes"
	check(Store.write_session(path, state, data).is_empty(), "Replace existing save safely")
	check(Store.load_session(path, data)["state"]["notes"] == "Updated notes", "Replacement persists")
	var legacy := state.duplicate(true)
	legacy.erase("assessment_submitted")
	check(Store.write_session(path, legacy, data).is_empty(), "Older save without submission marker remains compatible")
	check(Store.load_session(path, data)["state"]["notes"] == state["notes"], "Legacy notes remain intact")
	check(Store.write_session(path, state, data).is_empty(), "Restore current save fixture")

	var original := FileAccess.get_file_as_string(path)
	var invalid := state.duplicate(true)
	invalid["case_version"] = 99
	check(not Store.write_session(path, invalid, data).is_empty(), "Refuse incompatible state")
	check(FileAccess.get_file_as_string(path) == original, "Invalid write preserves original")
	invalid = state.duplicate(true)
	invalid["assessment_submitted"] = "yes"
	check(not Rules.validate_session(invalid, data).is_empty(), "Reject malformed submission marker")
	invalid = state.duplicate(true)
	invalid["hint_count"] = 1.5
	check(not Rules.validate_session(invalid, data).is_empty(), "Reject fractional hint position")
	invalid = state.duplicate(true)
	invalid["pinned"] = ["unknown"]
	check(not Rules.validate_session(invalid, data).is_empty(), "Reject unknown pinned source")
	invalid = state.duplicate(true)
	invalid["citations"]["stop"] = ["relay"]
	check(not Rules.validate_session(invalid, data).is_empty(), "Reject unpinned citations")
	invalid = state.duplicate(true)
	invalid["answers"]["extra"] = "itbayat"
	check(not Rules.validate_session(invalid, data).is_empty(), "Reject stale extra findings")

	write_raw(path, "{corrupt")
	check(Store.load_session(path, data).has("error"), "Corrupt JSON produces explicit error")
	check(FileAccess.get_file_as_string(path) == "{corrupt", "Corrupt save not silently overwritten")
	invalid = state.duplicate(true)
	invalid["case_id"] = "another-case"
	write_raw(path, JSON.stringify(invalid))
	check(Store.load_session(path, data).has("error"), "Wrong case identity produces error")
	check(FileAccess.get_file_as_string(path) == JSON.stringify(invalid), "Incompatible save preserved")
	check(not Store.write_session(directory.path_join("missing").path_join("session.json"), state, data).is_empty(), "Missing save directory produces explicit write failure")

	DirAccess.remove_absolute(path)
	DirAccess.remove_absolute(path + ".tmp")
	check(DirAccess.remove_absolute(directory) == OK, "Clean up isolated test directory")
	print("SAVE TESTS: %d passed, %d failed" % [passed, failed])
	quit(1 if failed else 0)


func write_raw(path: String, text: String) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		check(false, "Test fixture write")
		return
	file.store_string(text)
	file.close()


func check(condition: bool, description: String) -> void:
	if condition:
		passed += 1
	else:
		failed += 1
		push_error("FAIL: " + description)
