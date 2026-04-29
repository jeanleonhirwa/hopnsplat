extends Control

# Game Settings Menu - Comprehensive settings with reset functionality

# UI References
@onready var music_slider: HSlider
@onready var sfx_slider: HSlider
@onready var music_label: Label
@onready var sfx_label: Label
@onready var music_toggle: CheckButton
@onready var sfx_toggle: CheckButton
@onready var reset_button: Button
@onready var close_button: Button
@onready var confirmation_dialog: ConfirmationDialog

# Managers
var audio_manager
var achievement_system

func _ready():
	"""Initialize settings menu"""
	# Wait for scene tree
	await get_tree().process_frame
	
	# Get manager references
	audio_manager = get_node("/root/AudioManager")
	achievement_system = get_node("/root/AchievementSystem")
	
	# Get UI references
	music_slider = get_node_or_null("Panel/VBoxContainer/AudioSection/MusicContainer/MusicSlider")
	sfx_slider = get_node_or_null("Panel/VBoxContainer/AudioSection/SFXContainer/SFXSlider")
	music_label = get_node_or_null("Panel/VBoxContainer/AudioSection/MusicContainer/MusicLabel")
	sfx_label = get_node_or_null("Panel/VBoxContainer/AudioSection/SFXContainer/SFXLabel")
	music_toggle = get_node_or_null("Panel/VBoxContainer/AudioSection/MusicContainer/MusicToggle")
	sfx_toggle = get_node_or_null("Panel/VBoxContainer/AudioSection/SFXContainer/SFXToggle")
	reset_button = get_node_or_null("Panel/VBoxContainer/ResetSection/ResetButton")
	close_button = get_node_or_null("Panel/VBoxContainer/ButtonContainer/CloseButton")
	confirmation_dialog = get_node_or_null("ConfirmationDialog")
	
	# Connect signals
	if music_slider:
		music_slider.value_changed.connect(_on_music_volume_changed)
	if sfx_slider:
		sfx_slider.value_changed.connect(_on_sfx_volume_changed)
	if music_toggle:
		music_toggle.toggled.connect(_on_music_toggle_changed)
	if sfx_toggle:
		sfx_toggle.toggled.connect(_on_sfx_toggle_changed)
	if reset_button:
		reset_button.pressed.connect(_on_reset_button_pressed)
	if close_button:
		close_button.pressed.connect(_on_close_button_pressed)
	if confirmation_dialog:
		confirmation_dialog.confirmed.connect(_on_reset_confirmed)
	
	# Load current settings
	load_current_settings()
	
	print("Game Settings Menu initialized")

func load_current_settings():
	"""Load current settings from managers"""
	if not audio_manager:
		return
	
	# Load audio settings
	if music_slider:
		music_slider.value = audio_manager.get_music_volume()
	if sfx_slider:
		sfx_slider.value = audio_manager.get_sfx_volume()
	if music_toggle:
		music_toggle.button_pressed = audio_manager.is_music_enabled()
	if sfx_toggle:
		sfx_toggle.button_pressed = audio_manager.is_sfx_enabled()
	
	update_volume_labels()

func update_volume_labels():
	"""Update volume percentage labels"""
	if music_label and music_slider:
		music_label.text = "Music Volume: " + str(int(music_slider.value * 100)) + "%"
	if sfx_label and sfx_slider:
		sfx_label.text = "SFX Volume: " + str(int(sfx_slider.value * 100)) + "%"

func _on_music_volume_changed(value: float):
	"""Handle music volume change"""
	if audio_manager:
		audio_manager.set_music_volume(value)
		update_volume_labels()

func _on_sfx_volume_changed(value: float):
	"""Handle SFX volume change"""
	if audio_manager:
		audio_manager.set_sfx_volume(value)
		update_volume_labels()

func _on_music_toggle_changed(enabled: bool):
	"""Handle music toggle"""
	if audio_manager:
		audio_manager.toggle_music(enabled)

func _on_sfx_toggle_changed(enabled: bool):
	"""Handle SFX toggle"""
	if audio_manager:
		audio_manager.toggle_sfx(enabled)

func _on_reset_button_pressed():
	"""Show confirmation dialog for reset"""
	if confirmation_dialog:
		confirmation_dialog.popup_centered()
	else:
		# Fallback if dialog doesn't exist
		_on_reset_confirmed()

func _on_reset_confirmed():
	"""Reset all game data"""
	print("Resetting all game data...")
	
	# Reset save data
	reset_save_data()
	
	# Reset achievements
	reset_achievements()
	
	# Reset audio settings
	reset_audio_settings()
	
	# Reload settings UI
	load_current_settings()
	
	print("Game data reset complete!")
	
	# Show feedback to user
	show_reset_feedback()

func reset_save_data():
	"""Reset game save data (scores, coins, purchases)"""
	var save_file = FileAccess.open("user://hopnsplat_save.dat", FileAccess.WRITE)
	if save_file:
		var default_data = {
			"total_currency": 0,
			"highest_score": 0,
			"purchased_items": {}
		}
		save_file.store_string(JSON.stringify(default_data))
		save_file.close()
		print("Save data reset")

func reset_achievements():
	"""Reset all achievements"""
	var achievement_file = FileAccess.open("user://achievements.dat", FileAccess.WRITE)
	if achievement_file:
		var default_data = {
			"progress": {},
			"unlocked": []
		}
		achievement_file.store_string(JSON.stringify(default_data))
		achievement_file.close()
		print("Achievements reset")
	
	# Reload achievement system
	if achievement_system:
		achievement_system._load_progress()

func reset_audio_settings():
	"""Reset audio settings to defaults"""
	var audio_file = FileAccess.open("user://audio_settings.dat", FileAccess.WRITE)
	if audio_file:
		var default_settings = {
			"master_volume": 1.0,
			"music_volume": 0.7,
			"sfx_volume": 0.8,
			"music_enabled": true,
			"sfx_enabled": true
		}
		audio_file.store_string(JSON.stringify(default_settings))
		audio_file.close()
		print("Audio settings reset")
	
	# Reload audio manager settings
	if audio_manager:
		audio_manager.load_audio_settings()
		audio_manager.update_volumes()

func show_reset_feedback():
	"""Show visual feedback that reset was successful"""
	# Create a temporary label to show feedback
	var feedback_label = Label.new()
	feedback_label.text = "✓ Game Reset Complete!"
	feedback_label.add_theme_font_size_override("font_size", 24)
	feedback_label.add_theme_color_override("font_color", Color.GREEN)
	feedback_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	feedback_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	
	# Position at center
	feedback_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	feedback_label.offset_left = -150
	feedback_label.offset_right = 150
	feedback_label.offset_top = -50
	feedback_label.offset_bottom = 50
	
	add_child(feedback_label)
	
	# Fade out and remove
	var tween = create_tween()
	tween.tween_property(feedback_label, "modulate:a", 0.0, 2.0)
	tween.tween_callback(func(): feedback_label.queue_free())

func _on_close_button_pressed():
	"""Close settings menu"""
	hide()

func show_settings():
	"""Show settings menu"""
	load_current_settings()
	visible = true

func hide_settings():
	"""Hide settings menu"""
	visible = false
