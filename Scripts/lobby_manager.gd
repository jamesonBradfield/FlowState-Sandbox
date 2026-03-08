extends Node

var doll: PackedScene = load("res://Scenes/player.tscn")
signal doll_spawned(doll: Doll)


func _ready() -> void:
	InputHandler.new_device_connected.connect(create_player)


func create_player(is_controller: bool, tracking_id: int) -> void:
	var new_doll = doll.instantiate()
	var new_input_poller = LocalInputPoller.new()
	new_input_poller.device_id = tracking_id
	new_input_poller.controller = is_controller
	new_doll.local_input_poller = new_input_poller
	new_doll.add_child(new_input_poller)
	doll_spawned.emit(new_doll)
	QuickLogger.info("Player Spawned for device : " + str(tracking_id))
