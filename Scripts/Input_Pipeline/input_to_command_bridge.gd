class_name InputToCommandBridge
extends Node
# NOTE: after a bunch of hemming and hawwing, We have settled on using the Input Singleton for this.
# and that its the best way to handle controllers, even if it
@export var device_id: int = 0
@export var settings: Settings = Settings.new()
var state_packet: StatePacket = StatePacket.new()


@export var controller: bool = false:
	set(value):
		controller = value
		if is_inside_tree():
			_update_input_state()

func _update_input_state() -> void:
	if not controller:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	else:
		# When using a controller, we still capture to prevent accidental clicks 
		# outside the window, but we clear any pending mouse deltas.
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		state_packet.look_vec = Vector2.ZERO


func _ready() -> void:
	QuickLogger.set_script_level(self, QuickLogger.LogLevel.INFO)
	_update_input_state()


func _unhandled_input(event: InputEvent) -> void:
	if event.device != device_id:
		# If this is the primary player and we're swapping, 
		# we might need to update our device_id if it changed (reconnects)
		if LobbyManager.player_device_map.get(event.device) == self:
			device_id = event.device
		else:
			return

	if not controller and event is InputEventMouseMotion:
		# Use a small threshold to ignore high-frequency noise
		if event.relative.length_squared() > 0.1:
			state_packet.look_vec = event.relative * settings.mouse_sens * settings.mouse_inverted_axis

	for action in InputMap.get_actions():
		if str(action).begins_with("ui_"):
			continue

		if (
			action
			in [
				&"left",
				&"right",
				&"up",
				&"down",
			]
		):
			continue

		if event.is_action(action):
			state_packet.actions[action] = event.is_pressed()


func _physics_process(delta: float) -> void:
	if not controller:
		state_packet.move_vec = Input.get_vector("left", "right", "up", "down", 0.1)

	if controller:
		var move_vec := Vector2(
			Input.get_joy_axis(device_id, JOY_AXIS_LEFT_X),
			Input.get_joy_axis(device_id, JOY_AXIS_LEFT_Y)
		)

		# rescaled deadzone math
		if move_vec.length() < settings.controller_deadzone_left:
			move_vec = Vector2.ZERO
		else:
			move_vec = (
				move_vec.normalized()
				* (
					(move_vec.length() - settings.controller_deadzone_left)
					/ (1.0 - settings.controller_deadzone_left)
				)
			)

		state_packet.move_vec = move_vec

		# 2. CONTROLLER LOOK:
		var raw_look := Vector2(
			Input.get_joy_axis(device_id, JOY_AXIS_RIGHT_X),
			Input.get_joy_axis(device_id, JOY_AXIS_RIGHT_Y)
		)

		# rescaled deadzone math
		if raw_look.length() < settings.controller_deadzone_right:
			raw_look = Vector2.ZERO
		else:
			raw_look = (
				raw_look.normalized()
				* (
					(raw_look.length() - settings.controller_deadzone_right)
					/ (1.0 - settings.controller_deadzone_right)
				)
			)

		state_packet.look_vec = (
			raw_look * settings.controller_sens * settings.controller_inverted_axis * delta
		)
