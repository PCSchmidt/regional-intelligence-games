extends RefCounted

const Rules = preload("res://scripts/case_rules.gd")


static func load_session(path: String, data: Dictionary) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {"state": Rules.new_session(data), "new": true}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {"error": "Could not read save: " + error_string(FileAccess.get_open_error())}
	var parser := JSON.new()
	if parser.parse(file.get_as_text()) != OK:
		return {"error": "Save is not valid JSON. Original file preserved: " + path}
	var error := Rules.validate_session(parser.data, data)
	if not error.is_empty():
		return {"error": error + " Original file preserved: " + path}
	return {"state": parser.data, "new": false}


static func write_session(path: String, state: Dictionary, data: Dictionary) -> String:
	var validation_error := Rules.validate_session(state, data)
	if not validation_error.is_empty():
		return "Refusing invalid save: " + validation_error
	var directory := path.get_base_dir()
	if not DirAccess.dir_exists_absolute(directory):
		return "Save directory does not exist: " + directory
	var temporary := path + ".tmp"
	var file := FileAccess.open(temporary, FileAccess.WRITE)
	if file == null:
		return "Could not write save: " + error_string(FileAccess.get_open_error())
	file.store_string(JSON.stringify(state, "\t"))
	file.flush()
	var write_error := file.get_error()
	file.close()
	if write_error != OK:
		DirAccess.remove_absolute(temporary)
		return "Could not flush save: " + error_string(write_error)
	var rename_error := DirAccess.rename_absolute(temporary, path)
	if rename_error != OK:
		DirAccess.remove_absolute(temporary)
		return "Could not replace save; previous file preserved: " + error_string(rename_error)
	return ""

