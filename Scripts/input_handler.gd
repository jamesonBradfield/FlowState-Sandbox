extends Node
signal new_device_connected(is_controller: bool, device_id: int)
var used_device_ids: Array[int]


func _ready() -> void:
	self.new_device_connected.connect(log_device_info)
	QuickLogger.set_script_level(self, QuickLogger.LogLevel.DEBUG)


func _unhandled_input(event: InputEvent) -> void:
	var is_controller = event is InputEventJoypadButton or event is InputEventJoypadMotion
	var tracking_id = event.device
	if not is_controller:
		tracking_id = -1
	if used_device_ids.has(tracking_id):
		return
	used_device_ids.append(tracking_id)
	new_device_connected.emit(is_controller, tracking_id)


func log_device_info(is_controller: bool, _device_id: int) -> void:
	QuickLogger.debug("Device with id " + str(_device_id) + " connected ")
	QuickLogger.debug("is_controller: " + str(is_controller))
