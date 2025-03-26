extends Timer 

@onready var clock = $"../Clock"
@onready var winnerPlayer1 = $"../../GameResultsPopup/WinnerPlayer1"
@onready var winnerPlayer2 = $"../../GameResultsPopup/WinnerPlayer2"
@onready var draw = $"../../GameResultsPopup/Draw"
@onready var restart = $"../../StartPopup/PressSpaceToRestart"

var game_over = false  # Flag to check if the game is over

func _process(delta):
	clock.text = str(int(time_left))  # Update clock text
	if time_left == 0 and not game_over:
		game_over = true  # Set game over flag
		show_results()
		get_tree().paused = true  # Pause the game
		process_mode = Node.PROCESS_MODE_ALWAYS # Allow input handling even when paused

func _input(event):
	if game_over and event is InputEventKey and event.pressed and event.keycode == KEY_SPACE:
		get_tree().paused = false  # Unpause before reloading
		get_tree().reload_current_scene()

func show_results():
	if Globals.player1_score > Globals.player2_score:
		winnerPlayer1.visible = true			
	elif Globals.player1_score < Globals.player2_score:
		winnerPlayer2.visible = true
	else:
		draw.visible = true
	restart.visible = true
