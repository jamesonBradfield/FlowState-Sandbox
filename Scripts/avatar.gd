class_name Avatar
extends CharacterBody3D

var speed = 5.0
var jump_impulse = 4.5
var state_packet: StatePacket
var cam: Camera3D


func _ready() -> void:
	QuickLogger.set_script_level(self, QuickLogger.LogLevel.INFO)
	cam = get_node("head/Camera3D")
	QuickLogger.info("Cam : " + str(cam))


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	if not state_packet:
		move_and_slide()
		return
	# Handle jump.
	if state_packet.actions.get(&"jump", false) and is_on_floor():
		velocity.y = jump_impulse

	var input_dir := state_packet.move_vec
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	if state_packet.look_vec != Vector2.ZERO:
		rotate_y(state_packet.look_vec.x)
		if cam:
			cam.rotate_x(state_packet.look_vec.y)
			cam.rotation.x = clamp(cam.rotation.x, deg_to_rad(-89), deg_to_rad(89))
	QuickLogger.info(str(state_packet))
	move_and_slide()
	state_packet.look_vec = Vector2.ZERO
