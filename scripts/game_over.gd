extends Control

# Signals to communicate with main game
signal restart_requested
signal menu_requested

# UI References
@onready var final_score_label = $FinalScoreLabel
@onready var currency_earned_label = $CurrencyEarnedLabel
@onready var jumps_label = $JumpsLabel
@onready var high_score_label = $HighScoreLabel
@onready var restart_button = $RestartButton
@onready var menu_button = $MenuButton

func _ready():
	# Connect button signals
	restart_button.pressed.connect(_on_restart_button_pressed)
	menu_button.pressed.connect(_on_menu_button_pressed)

func show_game_over(final_score: int, currency_earned: int, jumps: int, high_score: int, is_new_high_score: bool):
	"""Display the game over screen with stats"""
	
	# Update labels with game stats
	final_score_label.text = "Final Score: " + str(final_score)
	currency_earned_label.text = "Coins Earned: " + str(currency_earned)
	jumps_label.text = "Successful Jumps: " + str(jumps)
	
	# Handle high score display
	if is_new_high_score:
		high_score_label.text = "NEW HIGH SCORE!"
		high_score_label.modulate = Color.GOLD
	else:
		high_score_label.text = "High Score: " + str(high_score)
		high_score_label.modulate = Color.WHITE
	
	# Show the screen
	visible = true
	
	print("Game Over screen displayed - Score: ", final_score, " Currency: ", currency_earned)

func hide_game_over():
	"""Hide the game over screen"""
	visible = false

func _on_restart_button_pressed():
	"""Handle restart button press"""
	print("Restart button pressed in GameOver scene")
	emit_signal("restart_requested")

func _on_menu_button_pressed():
	"""Handle menu button press"""
	print("Menu button pressed in GameOver scene")
	emit_signal("menu_requested")
