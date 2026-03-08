extends Node

var screen_grid: GridContainer


func _ready() -> void:
	var canvas = CanvasLayer.new()
	get_tree().root.call_deferred("add_child", canvas)

	screen_grid = GridContainer.new()
	screen_grid.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	screen_grid.columns = 1
	canvas.add_child(screen_grid)
	LobbyManager.doll_spawned.connect(assign_player_to_viewport)


func assign_player_to_viewport(player_node: Node3D) -> void:
	var vp_container = SubViewportContainer.new()
	vp_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vp_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vp_container.stretch = true
	var viewport = SubViewport.new()
	var main_world = get_tree().root.get_node("Node3D")
	viewport.world_3d = main_world.get_viewport().world_3d
	vp_container.add_child(viewport)
	screen_grid.add_child(vp_container)
	if screen_grid.get_child_count() > 2:
		screen_grid.columns = 2
	viewport.add_child(player_node)
