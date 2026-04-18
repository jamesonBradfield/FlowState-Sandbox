extends Node3D

## AI Demo scene setup script.
## Wires the AiBrain to its FlowCharacter puppet,
## gives the player a StatePacket so it can move,
## and adds the player to the "players" group so the AI can detect it.

@export var ai_character_path: NodePath
@export var player_path: NodePath


func _ready() -> void:
	# Disable the singleton pipeline — this scene manages its own players.
	LobbyManager.auto_spawn_enabled = false

	var ai_char: FlowCharacter = get_node_or_null(ai_character_path)
	var player: FlowCharacter = get_node_or_null(player_path)

	if ai_char:
		# Disable the character's own physics processing;
		# the AiBrain will drive it manually.
		ai_char.set_physics_process(false)

		# Find the AiBrain child and wire it up
		var brain = ai_char.get_node_or_null("AiBrain")
		if brain and brain.has_method("setup"):
			brain.setup(ai_char)

	if player:
		# Give the player a StatePacket so FlowCharacter._poll_input can read it
		if not player.state_packet:
			player.state_packet = StatePacket.new()
		player.add_to_group("players")
