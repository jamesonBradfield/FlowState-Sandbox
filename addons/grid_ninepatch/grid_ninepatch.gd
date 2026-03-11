@tool
extends EditorPlugin

# Define your grid plane.
# Vector3.UP (0, 1, 0) defines the normal (pointing up).
# 0.0 defines the distance from the origin. This creates a standard XZ ground plane at Y=0.
var grid_plane := Plane(Vector3.UP, 0.0)

# Optional: Keep a reference to the active GridMap you are editing
var active_gridmap: GridMap


func _handles(object: Object) -> bool:
	# Tell the editor this plugin should be active when a GridMap is selected
	if object is GridMap:
		active_gridmap = object
		return true
	return false


func _forward_3d_gui_input(viewport_camera: Camera3D, event: InputEvent) -> int:
	# Only react to mouse events (motion, clicks, or drags)
	if event is InputEventMouseMotion or event is InputEventMouseButton:
		var mouse_pos = event.position

		# 1. Get the ray origin and direction from the camera
		var ray_origin = viewport_camera.project_ray_origin(mouse_pos)
		var ray_normal = viewport_camera.project_ray_normal(mouse_pos)

		# 2. Mathematically intersect the ray with your infinite plane
		var hit_position = grid_plane.intersects_ray(ray_origin, ray_normal)

		# intersects_ray returns a Vector3 if it hits, or null if the ray is parallel to the plane
		if hit_position != null:
			_handle_grid_interaction(hit_position, event)

			# If you are actively drawing your nine-patch, you might want to consume the event:
			# return EditorPlugin.AFTER_GUI_INPUT_STOP

	# Let the default editor handle the input otherwise
	return EditorPlugin.AFTER_GUI_INPUT_PASS


func _handle_grid_interaction(hit_position: Vector3, event: InputEvent) -> void:
	if active_gridmap == null:
		return

	# 3. Convert the exact 3D world coordinate to a GridMap cell coordinate
	var local_hit = active_gridmap.to_local(hit_position)
	var grid_cell = active_gridmap.local_to_map(local_hit)

	# Now you have the exact Vector3i cell!
	# You can store the starting click as corner A, and the drag position as corner B
	# to calculate your nine-patch bounds.
