extends Control

var device_id: int = 0

var state_label: Label
var speed_label: Label
var device_label: Label

var _player: FlowCharacter = null


func _ready() -> void:
	state_label = get_node_or_null("BottomLeft/VBox/StateLabel")
	speed_label = get_node_or_null("BottomLeft/VBox/SpeedLabel")
	device_label = get_node_or_null("TopRight/DeviceLabel")


func setup(player: FlowCharacter, dev_id: int) -> void:
	_player = player
	device_id = dev_id
	if device_label:
		device_label.text = "P%d" % (dev_id + 1)
	# Connect state changes to update the HUD
	if player and player.root_state:
		_connect_state_signals(player.root_state)


func _process(_delta: float) -> void:
	if _player and speed_label:
		var h_speed := Vector2(_player.velocity.x, _player.velocity.z).length()
		speed_label.text = "Speed: %.1f" % h_speed


func update_state_name(state_name: String) -> void:
	if state_label:
		state_label.text = state_name


func _connect_state_signals(state: Node) -> void:
	if state.has_signal("state_entered"):
		if not state.state_entered.is_connected(_on_state_entered):
			state.state_entered.connect(_on_state_entered)
	for child in state.get_children():
		_connect_state_signals(child)


func _on_state_entered(state: FlowState) -> void:
	update_state_name(state.name)
