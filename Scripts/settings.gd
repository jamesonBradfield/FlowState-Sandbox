class_name Settings
extends Resource
## NOTE: should store a resource or dict with easily saved/loaded config files,
## this way it can be passed around, and hopefully the end game of subresources for different menus/systems can be achieved...

@export var mouse_sens: Vector2 = Vector2(.002, .002)
@export var controller_sens: Vector2 = Vector2(1.5, 1.5)
@export var controller_deadzone_left: float = 0.1
@export var controller_deadzone_right: float = 0.1
@export var mouse_inverted_axis: Vector2 = Vector2(-1, -1)
@export var controller_inverted_axis: Vector2 = Vector2(-1, -1)
