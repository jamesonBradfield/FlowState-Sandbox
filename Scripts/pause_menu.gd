extends Control


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if self.hidden:
			self.show()
		elif not self.hidden:
			self.hide()
		QuickLogger.info("pause pressed")
