extends Timer

@onready var clock = $"../Clock"

func _process(delta):
	clock.text = str(int(time_left))
