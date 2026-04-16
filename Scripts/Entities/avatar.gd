class_name Avatar
extends FlowCharacter

func _ready() -> void:
	if not camera:
		camera = get_node_or_null("head/Camera3D")
	super._ready()
	QuickLogger.set_script_level(self, QuickLogger.LogLevel.INFO)
	QuickLogger.info("Cam : " + str(camera))

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if state_packet:
		QuickLogger.info(str(state_packet))

