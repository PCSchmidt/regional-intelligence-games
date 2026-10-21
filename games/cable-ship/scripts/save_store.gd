extends RefCounted

## Versioned local save. Corrupt or incompatible files are preserved, never
## silently replaced.

const SurveyRules = preload("res://scripts/survey_rules.gd")

const SAVE_VERSION := 1


static func load_session(path: String, survey: Dictionary) -> Dictionary:
	if not FileAccess.file_exists(path):
		return { "new": true, "state": SurveyRules.new_session(survey) }
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return { "error": "Cannot read save. Original preserved: %s" % path }
	var parser := JSON.new()
	if parser.parse(file.get_as_text()) != OK or typeof(parser.data) != TYPE_DICTIONARY:
		return { "error": "Save is not valid JSON. Original file preserved: %s" % path }
	var data: Dictionary = parser.data
	if data.get("save_version", 0) != SAVE_VERSION:
		return { "error": "Save version %s is not supported. Original file preserved: %s" % [str(data.get("save_version", "?")), path] }
	if str(data.get("survey_id", "")) != str(survey.get("survey_id", "")):
		return { "error": "Save belongs to a different survey. Original file preserved: %s" % path }
	var state = data.get("state")
	if typeof(state) != TYPE_DICTIONARY:
		return { "error": "Save has no state object. Original file preserved: %s" % path }
	var merged := SurveyRules.new_session(survey)
	for key in (state as Dictionary).keys():
		merged[key] = state[key]
	var problem := SurveyRules.validate_session(merged, survey)
	if not problem.is_empty():
		return {"error": problem + " Original file preserved: " + path}
	return { "state": merged }


static func write_session(path: String, state: Dictionary, survey: Dictionary) -> String:
	if path.is_empty():
		return "Save path is empty."
	var problem := SurveyRules.validate_session(state, survey)
	if not problem.is_empty():
		return "Refusing invalid save: " + problem
	if FileAccess.file_exists(path):
		var existing := load_session(path, survey)
		if existing.has("error"):
			return "Save locked: " + str(existing["error"])
	var directory := path.get_base_dir()
	if not DirAccess.dir_exists_absolute(directory):
		var made := DirAccess.make_dir_recursive_absolute(directory)
		if made != OK:
			return "Save directory does not exist: %s" % directory
	var payload := {
		"save_version": SAVE_VERSION,
		"survey_id": str(survey.get("survey_id", "")),
		"state": state
	}
	var temporary := path + ".tmp"
	var file := FileAccess.open(temporary, FileAccess.WRITE)
	if file == null:
		return "Cannot write save: %s" % temporary
	file.store_string(JSON.stringify(payload, "\t"))
	file.flush()
	var write_error := file.get_error()
	file.close()
	if write_error != OK:
		DirAccess.remove_absolute(temporary)
		return "Save flush failed: " + error_string(write_error)
	var error := DirAccess.rename_absolute(temporary, path)
	if error != OK:
		DirAccess.remove_absolute(temporary)
		return "Cannot replace save: %s" % path
	return ""


static func reset_session(path: String) -> String:
	if not FileAccess.file_exists(path):
		return ""
	var backup := path + ".backup-%d-%d" % [Time.get_ticks_usec(), OS.get_process_id()]
	var result := DirAccess.rename_absolute(path, backup)
	return "" if result == OK else "Cannot back up original save: " + error_string(result)
