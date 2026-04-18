extends Node

## The AI brain generates movement context instead of reading player input.
## Demonstrates the puppet pattern: same FlowHFSM, different data source.

@export var patrol_points: Array[Vector3] = []
@export var wait_time: float = 2.0
@export var patrol_speed: float = 3.0
@export var chase_speed: float = 6.0
@export var detection_range: float = 8.0

var _character: FlowCharacter
var _current_patrol_index: int = 0
var _wait_timer: float = 0.0
var _is_waiting: bool = false

enum AIState { PATROL, CHASE, WAIT }
var _ai_state: AIState = AIState.PATROL
var _player_ref: Node3D = null


func setup(character: FlowCharacter) -> void:
    _character = character
    # The AICharacter itself will have physics_process disabled.
    # We will manually call process_state and _apply_physics.
    set_physics_process(true) # Ensure the brain itself processes physics


func _physics_process(delta: float) -> void:
    if not _character or not _character.is_node_ready():
        return

    _update_ai_state(delta)

    # Build AI context — this replaces FlowDataMap.resolve()
    var context: Dictionary[StringName, Variant] = {}
    var current_speed: float = 0.0

    match _ai_state:
        AIState.PATROL:
            context = _patrol_context(delta)
            current_speed = patrol_speed
        AIState.CHASE:
            context = _chase_context(delta)
            current_speed = chase_speed
        AIState.WAIT:
            context = _wait_context(delta)
            current_speed = 0.0

    # Add speed to context for BehaviorPhysics
    context[&"speed"] = current_speed

    # Feed context to the state machine
    if _character.root_state:
        _character.root_state.process_state(delta, _character, context)

    # Still need physics
    _character._apply_physics(delta)


func _update_ai_state(delta: float) -> void:
    # Find nearest player (in group "players")
    var players = get_tree().get_nodes_in_group("players")
    _player_ref = null
    var closest_dist = detection_range + 1.0 # Initialize with a value outside detection range
    for p in players:
        if not p is Node3D:
            continue
        var dist = _character.global_position.distance_to(p.global_position)
        if dist < closest_dist:
            closest_dist = dist
            _player_ref = p

    # Transition logic
    match _ai_state:
        AIState.PATROL:
            if _player_ref and closest_dist <= detection_range:
                _ai_state = AIState.CHASE
        AIState.CHASE:
            if not _player_ref or closest_dist > detection_range:
                _is_waiting = true
                _wait_timer = wait_time
                _ai_state = AIState.WAIT
        AIState.WAIT:
            _wait_timer -= delta
            if _player_ref and closest_dist <= detection_range:
                _ai_state = AIState.CHASE
            elif _wait_timer <= 0:
                _is_waiting = false
                _ai_state = AIState.PATROL


func _patrol_context(_delta: float) -> Dictionary[StringName, Variant]:
    if patrol_points.is_empty():
        return _idle_context()

    var target = patrol_points[_current_patrol_index]
    var direction = _character.global_position.direction_to(target)
    direction.y = 0
    direction = direction.normalized()

    # Close enough? Move to next patrol point
    if _character.global_position.distance_to(target) < 0.5: # Smaller threshold for arrival
        _current_patrol_index = (_current_patrol_index + 1) % patrol_points.size()
        _is_waiting = true
        _wait_timer = wait_time
        _ai_state = AIState.WAIT
        return _idle_context()

    return {
        &"move_input": direction,
        &"is_moving": true,
        &"camera": _character.camera, # Assuming AICharacter has a camera property for rotation behavior
        &"model": _character.model,   # Assuming AICharacter has a model property for rotation behavior
    }


func _chase_context(_delta: float) -> Dictionary[StringName, Variant]:
    if not _player_ref:
        return _idle_context()

    var direction = _character.global_position.direction_to(_player_ref.global_position)
    direction.y = 0
    direction = direction.normalized()

    return {
        &"move_input": direction,
        &"is_moving": true,
        &"camera": _character.camera,
        &"model": _character.model,
    }


func _wait_context(_delta: float) -> Dictionary[StringName, Variant]:
    return _idle_context()


func _idle_context() -> Dictionary[StringName, Variant]:
    return {
        &"move_input": Vector3.ZERO,
        &"is_moving": false,
        &"camera": _character.camera,
        &"model": _character.model,
    }
