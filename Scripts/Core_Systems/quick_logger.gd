extends Node

enum LogLevel { DEBUG, INFO, WARNING, ERROR, NONE }

# Default global level
var global_level: LogLevel = LogLevel.INFO

# Dictionary to store script-specific overrides
# Example: {"doll.gd": LogLevel.ERROR}
var script_overrides: Dictionary = {}

const COLORS = {
	LogLevel.DEBUG: "gray",
	LogLevel.INFO: "green",
	LogLevel.WARNING: "yellow",
	LogLevel.ERROR: "red",
	"header": "orange"
}


func info(message: String) -> void:
	_log(message, LogLevel.INFO)


func debug(message: String) -> void:
	_log(message, LogLevel.DEBUG)


func warning(message: String) -> void:
	_log(message, LogLevel.WARNING)
	push_warning(message)  # Still sends to Godot's native debugger


func error(message: String) -> void:
	_log(message, LogLevel.ERROR)
	push_error(message)  # Still sends to Godot's native debugger


func _log(message: String, level: LogLevel) -> void:
	var stack = get_stack()
	if stack.size() <= 2:
		return

	var caller = stack[2]
	var source_path = str(caller.get("source", ""))
	var file_name = source_path.get_file()

	# Determine the required level for this specific script
	var required_level = script_overrides.get(file_name, global_level)

	# Skip if the message level is lower than the required level
	if level < required_level:
		return

	var function_name = caller.get("function", "Unknown")
	var line_number = caller.get("line", "0")
	var header = "[%s::%s:%s]" % [file_name, function_name, line_number]
	var color = COLORS.get(level, "white")

	print_rich(
		(
			"[color=%s][b]%s[/b][/color]: [color=%s]%s[/color]"
			% [COLORS.header, header, color, message]
		)
	)

	if Engine.has_singleton("Panku"):
		var panku_msg = "%s: %s" % [header, message]
		# Map LogLevel enum back to string for Panku if needed
		get_tree().root.get_node("/root/Panku").gd_logger.append_log(panku_msg, str(level))


# Call this in _ready() of any script to set its specific level
func set_script_level(script: Object, level: LogLevel):
	var file_name = script.get_script().get_path().get_file()
	script_overrides[file_name] = level
