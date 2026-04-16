extends Node

var player_scene: PackedScene = load("res://Scenes/player.tscn")
signal player_spawned(player: FlowCharacter, id: int)

var player_device_map: Dictionary = {}


func _ready() -> void:
	DeviceManager.new_device_connected.connect(create_player)
	DeviceManager.update_input_device.connect(update_player_device)


func create_player(is_controller: bool, tracking_id: int) -> void:
	var new_player = player_scene.instantiate() as FlowCharacter
	var new_bridge = InputToCommandBridge.new()

	new_bridge.device_id = tracking_id
	new_bridge.controller = is_controller

	new_player.state_packet = new_bridge.state_packet

	player_device_map[tracking_id] = new_bridge

	add_child(new_bridge)
	player_spawned.emit(new_player, tracking_id)


func update_player_device(is_controller: bool, tracking_id: int) -> void:
	if player_device_map.has(tracking_id):
		var input_poller = player_device_map[tracking_id]
		input_poller.device_id = tracking_id
		input_poller.controller = is_controller
		QuickLogger.info("Updated Player 1 input method. Controller: " + str(is_controller))
