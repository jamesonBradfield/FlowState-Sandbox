extends Control

var device_id: int = 0
var is_paused: bool = false

var resume_button: Button
var options_button: Button
var quit_button: Button


func _ready() -> void:
	resume_button = get_node_or_null("AspectRatioContainer/PanelContainer/MarginContainer/MarginContainer/VBoxContainer/ResumeButton")
	options_button = get_node_or_null("AspectRatioContainer/PanelContainer/MarginContainer/MarginContainer/VBoxContainer/OptionsButton")
	quit_button = get_node_or_null("AspectRatioContainer/PanelContainer/MarginContainer/MarginContainer/VBoxContainer/QuitButton")

	if resume_button:
		resume_button.pressed.connect(_on_resume)
	if options_button:
		options_button.pressed.connect(_on_options)
	if quit_button:
		quit_button.pressed.connect(_on_quit)

	hide()


func _input(event: InputEvent) -> void:
	if event.device != device_id:
		return
	if not event.is_action_pressed(&"pause"):
		return
	# Don't toggle if a UI element already handled it
	if is_paused and get_viewport().gui_get_focus_owner():
		# If a button has focus, let the UI handle escape first
		return
	toggle_pause()


func toggle_pause() -> void:
	if is_paused:
		unpause()
	else:
		pause()


func pause() -> void:
	is_paused = true
	show()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if resume_button:
		resume_button.grab_focus.call_deferred()
	get_tree().paused = true


func unpause() -> void:
	is_paused = false
	hide()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	get_tree().paused = false


func _on_resume() -> void:
	unpause()


func _on_options() -> void:
	# Placeholder — wire up options menu later
	pass


func _on_quit() -> void:
	unpause()
	get_tree().quit()
