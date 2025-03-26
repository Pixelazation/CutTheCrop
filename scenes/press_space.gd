extends Label

func _ready():
	get_tree().paused = true  # Pause the game at the start
	process_mode = Node.PROCESS_MODE_ALWAYS  # Ensure input is processed even when paused

func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_SPACE:
		get_tree().paused = false  # Unpause the game
		self.visible = false  # Hide the label
		set_process_input(false)  # Stop processing input for this label
