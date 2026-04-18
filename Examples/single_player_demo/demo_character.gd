class_name DemoCharacter extends FlowCharacter

@export var mouse_sensitivity: float = 0.002

func _ready() -> void:
	super._ready()

func _physics_process(delta: float) -> void:
	if not state_packet:
		state_packet = StatePacket.new()

	# Capture WASD input for movement
	state_packet.move_vec = Input.get_vector("left", "right", "up", "down")
	
	# Clear look_vec each frame to prevent continuous rotation when mouse stops
	state_packet.look_vec = Vector2.ZERO

	super._physics_process(delta)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		# Capture mouse input for looking
		state_packet.look_vec = event.relative * mouse_sensitivity
