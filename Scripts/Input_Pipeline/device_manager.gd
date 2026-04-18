extends Node
signal new_device_connected(is_controller: bool, device_id: int)
signal update_input_device(is_controller: bool, device_id: int)
var used_device_ids: Array[int]

var p1_is_controller: bool = false
var p1_device_id: int = -1 # Track which device P1 is actually using

func _ready() -> void:
	self.new_device_connected.connect(log_device_info)
	QuickLogger.set_script_level(self, QuickLogger.LogLevel.DEBUG)
	Input.joy_connection_changed.connect(_on_joy_connection_changed)
	# Register any controllers already connected at startup
	for pad_id in Input.get_connected_joypads():
		_register_device(true, pad_id)


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


func _on_joy_connection_changed(device: int, connected: bool) -> void:
	if connected:
		_register_device(true, device)


func _register_device(is_controller: bool, device_id: int) -> void:
	if used_device_ids.has(device_id):
		return
	used_device_ids.append(device_id)
	if p1_device_id == -1:
		p1_device_id = device_id
		p1_is_controller = is_controller
	new_device_connected.emit(is_controller, device_id)
