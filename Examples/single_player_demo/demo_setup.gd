extends Node3D

## Single-player demo setup script.
## Disables the singleton spawn pipeline since this scene
## has a DemoCharacter that handles its own input directly.

func _ready() -> void:
	LobbyManager.auto_spawn_enabled = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
