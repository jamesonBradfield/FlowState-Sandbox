extends Node

var screen_grid: GridContainer
var canvas: CanvasLayer
var pause_scene: PackedScene = preload("res://Scenes/pause.tscn")
var hud_scene: PackedScene = preload("res://Scenes/hud.tscn")

var device_to_viewport: Dictionary = {}
var pause_menus: Dictionary = {}  # device_id -> Control
var huds: Dictionary = {}  # device_id -> Control


func _ready() -> void:
	canvas = CanvasLayer.new()
	canvas.layer = 10  # Above game content
	get_tree().root.call_deferred("add_child", canvas)

	screen_grid = GridContainer.new()
	screen_grid.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	screen_grid.columns = 1
	canvas.add_child(screen_grid)

	LobbyManager.player_spawned.connect(assign_player_to_viewport)


func assign_player_to_viewport(player_node: FlowCharacter, device_id: int) -> void:
	# 1. Create SubViewport for this player's camera view
	var vp_container = SubViewportContainer.new()
	vp_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vp_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vp_container.stretch = true

	var viewport = SubViewport.new()
	viewport.handle_input_locally = true

	var main_world = get_tree().root.get_node("Main")
	viewport.world_3d = main_world.get_viewport().world_3d
	vp_container.add_child(viewport)
	screen_grid.add_child(vp_container)

	# 2. Add player to the SubViewport
	viewport.add_child(player_node)

	# 3. Create HUD overlay on the CanvasLayer
	var hud = hud_scene.instantiate() as Control
	hud.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(hud)
	# setup() must run after add_child so @onready refs are valid
	hud.setup(player_node, device_id)
	huds[device_id] = hud

	# 4. Create pause menu ON the main CanvasLayer (not inside SubViewport)
	# This ensures _unhandled_input works properly
	var pause_menu = pause_scene.instantiate() as Control
	pause_menu.device_id = device_id
	pause_menu.hide()
	# Add pause menu directly to canvas, positioned over this player's viewport
	canvas.add_child(pause_menu)
	pause_menus[device_id] = pause_menu

	# 5. Adjust grid columns for split-screen
	if screen_grid.get_child_count() > 2:
		screen_grid.columns = 2

	device_to_viewport[device_id] = viewport
