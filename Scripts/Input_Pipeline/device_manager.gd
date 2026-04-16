extends Node
signal new_device_connected(is_controller: bool, device_id: int)
signal update_input_device(is_controller: bool, device_id: int)
var used_device_ids: Array[int]

var p1_is_controller: bool = false
var p1_device_id: int = -1 # Track which device P1 is actually using

func _ready() -> void:
	self.new_device_connected.connect(log_device_info)
	QuickLogger.set_script_level(self, QuickLogger.LogLevel.DEBUG)


func _unhandled_input(event: InputEvent) -> void:
	var is_controller = event is InputEventJoypadButton or event is InputEventJoypadMotion
	
	# Ignore small mouse jitters if we are using a controller
	if event is InputEventMouseMotion and p1_is_controller:
		if event.relative.length_squared() < 10: # Threshold to prevent accidental swaps
			return

	# INITIAL CONNECTION
	if not used_device_ids.has(event.device):
		used_device_ids.append(event.device)
		
		# If this is our FIRST device, or we have no P1 device yet, assign it.
		if p1_device_id == -1:
			p1_device_id = event.device
			p1_is_controller = is_controller
			new_device_connected.emit(is_controller, event.device)
		else:
			# Subsequent unique devices spawn new players (Split-Screen)
			new_device_connected.emit(is_controller, event.device)
		return

	# SWAP LOGIC
	# If the event comes from P1's current device, OR P1 is currently using a shared ID (like 0)
	if event.device == p1_device_id or (p1_device_id == 0 and event.device == 0):
		if is_controller != p1_is_controller:
			p1_is_controller = is_controller
			update_input_device.emit(is_controller, event.device)


func log_device_info(is_controller: bool, _device_id: int) -> void:
	QuickLogger.debug("Device with id " + str(_device_id) + " connected ")
	QuickLogger.debug("is_controller: " + str(is_controller))
