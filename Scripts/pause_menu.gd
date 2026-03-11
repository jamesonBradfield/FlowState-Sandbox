extends Control
var device_id: int


func _input(event: InputEvent) -> void:
	if event.device == device_id:
		if event.is_action_pressed("pause"):
			if self.hidden:
				self.show()
			else:
				# DOESN'T HIDE DAMMIT
				self.hide()
