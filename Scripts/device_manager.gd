extends Node
signal new_device_connected(is_controller: bool, device_id: int)
signal update_input_device(is_controller: bool, device_id: int)
var used_device_ids: Array[int]

var p1_is_controller: bool = false


func _ready() -> void:
	self.new_device_connected.connect(log_device_info)
	QuickLogger.set_script_level(self, QuickLogger.LogLevel.DEBUG)


func _unhandled_input(event: InputEvent) -> void:
	var is_controller = event is InputEventJoypadButton or event is InputEventJoypadMotion

	if used_device_ids.has(event.device):
		if event.device == 0:
			if is_controller != p1_is_controller:
				p1_is_controller = is_controller
				update_input_device.emit(is_controller, event.device)
		return

	used_device_ids.append(event.device)

	if event.device == 0:
		p1_is_controller = is_controller

	new_device_connected.emit(is_controller, event.device)


func log_device_info(is_controller: bool, _device_id: int) -> void:
	QuickLogger.debug("Device with id " + str(_device_id) + " connected ")
	QuickLogger.debug("is_controller: " + str(is_controller))
