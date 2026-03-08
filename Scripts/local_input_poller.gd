class_name LocalInputPoller
extends Node
var device_id: int
var controller: bool
var tracked_actions: Array[StringName] = [&"jump"]
var mouse_sens: Vector2 = Vector2(.002, .002)
var inverted_axis: Vector2 = Vector2(-1, -1)  #-1 not inverted, 1 inverted.
var user_command: UserCommand


func _ready() -> void:
	user_command = UserCommand.new()
	if not controller:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	QuickLogger.set_script_level(self, QuickLogger.LogLevel.INFO)


func _unhandled_input(event: InputEvent) -> void:
	if event.device != device_id and controller:
		QuickLogger.info("device id didn't match")
		return
	if not controller:
		process_mouse_and_keyboard(event)
	else:
		process_controller(event)
	for action in tracked_actions:
		if event.is_action(action):
			user_command.actions[action] = event.is_pressed()


func process_mouse_and_keyboard(event: InputEvent):
	if event is InputEventMouseMotion:
		user_command.look_vec = event.relative * mouse_sens * inverted_axis
	user_command.move_vec = Input.get_vector("left", "right", "up", "down")
	QuickLogger.debug("LookVec : " + str(user_command.look_vec))
	QuickLogger.debug("MoveVec : " + str(user_command.move_vec))
	return


func process_controller(_event: InputEvent):
	user_command.move_vec.x = Input.get_joy_axis(device_id, JOY_AXIS_LEFT_X)
	user_command.move_vec.y = Input.get_joy_axis(device_id, JOY_AXIS_LEFT_Y)

	if user_command.move_vec.length() < 0.2:
		user_command.move_vec = Vector2.ZERO
	user_command.look_vec.x = Input.get_joy_axis(device_id, JOY_AXIS_RIGHT_X)
	user_command.look_vec.y = Input.get_joy_axis(device_id, JOY_AXIS_RIGHT_Y)

	if user_command.look_vec.length() < 0.2:
		user_command.look_vec = Vector2.ZERO
	return
