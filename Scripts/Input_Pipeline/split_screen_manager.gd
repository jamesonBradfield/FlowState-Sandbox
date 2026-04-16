extends Node

var screen_grid: GridContainer
var pause_scene: PackedScene = preload("res://Scenes/pause.tscn")

var device_to_viewport: Dictionary = {}


func _ready() -> void:
	var canvas = CanvasLayer.new()
	get_tree().root.call_deferred("add_child", canvas)

	screen_grid = GridContainer.new()
	screen_grid.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	screen_grid.columns = 1
	canvas.add_child(screen_grid)

	LobbyManager.player_spawned.connect(assign_player_to_viewport)


func assign_player_to_viewport(player_node: FlowCharacter, device_id: int) -> void:
	var vp_container = SubViewportContainer.new()
	vp_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vp_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vp_container.stretch = true

	var viewport = SubViewport.new()
	viewport.handle_input_locally = true

	var main_world = get_tree().root.get_node("Main")
	var pause_menu = pause_scene.instantiate() as Control
	pause_menu.device_id = device_id
	pause_menu.hide()
	viewport.world_3d = main_world.get_viewport().world_3d
	viewport.add_child(pause_menu)
	vp_container.add_child(viewport)
	screen_grid.add_child(vp_container)

	if screen_grid.get_child_count() > 2:
		screen_grid.columns = 2

	viewport.add_child(player_node)

	device_to_viewport[device_id] = viewport
