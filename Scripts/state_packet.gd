class_name StatePacket
extends RefCounted
### SUMMARY: this is a abstract data package that will handle puppetting the player dolls.
### I believe there should be a way to have everything after jump just be dynamically "meta coded" based on any extra input actions we add...

## look vector, will have to be evaluated separately based on input.
var look_vec: Vector2
## move vector, godot input actions can handle both mk.
var move_vec: Vector2
##Stores the true/false state of any button press
var actions: Dictionary[StringName, bool] = {}
