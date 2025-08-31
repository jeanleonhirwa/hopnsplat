extends Control

# Audio Settings Menu - Volume controls and audio options

# Get reference to AudioManager autoload
var audio_manager

# UI References
@onready var music_volume_slider: HSlider
@onready var sfx_volume_slider: HSlider
@onready var music_toggle: CheckButton
@onready var sfx_toggle: CheckButton
@onready var music_volume_label: Label
@onready var sfx_volume_label: Label
@onready var close_button: Button

func _ready():
	"""Initialize audio settings menu"""
	# Wait a frame for the scene tree to be ready
	await get_tree().process_frame
	
	# Get AudioManager reference
	audio_manager = get_node("/root/AudioManager")
	
	# Find UI elements
	music_volume_slider = get_node_or_null("Panel/VBoxContainer/MusicContainer/MusicVolumeSlider")
	sfx_volume_slider = get_node_or_null("Panel/VBoxContainer/SFXContainer/SFXVolumeSlider")
	music_toggle = get_node_or_null("Panel/VBoxContainer/MusicContainer/MusicToggle")
	sfx_toggle = get_node_or_null("Panel/VBoxContainer/SFXContainer/SFXToggle")
	music_volume_label = get_node_or_null("Panel/VBoxContainer/MusicContainer/MusicVolumeLabel")
	sfx_volume_label = get_node_or_null("Panel/VBoxContainer/SFXContainer/SFXVolumeLabel")
	close_button = get_node_or_null("Panel/VBoxContainer/CloseButton")
	
	# Debug: Print if nodes are found
	print("AudioManager found: ", audio_manager != null)
	print("Music slider found: ", music_volume_slider != null)
	print("SFX slider found: ", sfx_volume_slider != null)
	print("Music toggle found: ", music_toggle != null)
	print("SFX toggle found: ", sfx_toggle != null)
	print("Close button found: ", close_button != null)
	
	# Connect signals manually
	if music_volume_slider:
		if not music_volume_slider.value_changed.is_connected(_on_music_volume_changed):
			music_volume_slider.value_changed.connect(_on_music_volume_changed)
			print("Connected music slider signal")
	if sfx_volume_slider:
		if not sfx_volume_slider.value_changed.is_connected(_on_sfx_volume_changed):
			sfx_volume_slider.value_changed.connect(_on_sfx_volume_changed)
			print("Connected SFX slider signal")
	if music_toggle:
		if not music_toggle.toggled.is_connected(_on_music_toggle_changed):
			music_toggle.toggled.connect(_on_music_toggle_changed)
			print("Connected music toggle signal")
	if sfx_toggle:
		if not sfx_toggle.toggled.is_connected(_on_sfx_toggle_changed):
			sfx_toggle.toggled.connect(_on_sfx_toggle_changed)
			print("Connected SFX toggle signal")
	if close_button:
		if not close_button.pressed.is_connected(_on_close_pressed):
			close_button.pressed.connect(_on_close_pressed)
			print("Connected close button signal")
	
	# Load current settings
	load_current_settings()

func load_current_settings():
	"""Load current audio settings from AudioManager"""
	# Wait for AudioManager to be ready
	if not audio_manager:
		print("AudioManager not available yet")
		return
		
	if music_volume_slider:
		music_volume_slider.value = audio_manager.get_music_volume()
		print("Set music slider to: ", audio_manager.get_music_volume())
	if sfx_volume_slider:
		sfx_volume_slider.value = audio_manager.get_sfx_volume()
		print("Set SFX slider to: ", audio_manager.get_sfx_volume())
	if music_toggle:
		music_toggle.button_pressed = audio_manager.is_music_enabled()
		print("Set music toggle to: ", audio_manager.is_music_enabled())
	if sfx_toggle:
		sfx_toggle.button_pressed = audio_manager.is_sfx_enabled()
		print("Set SFX toggle to: ", audio_manager.is_sfx_enabled())
	
	# Update labels
	update_volume_labels()

func update_volume_labels():
	"""Update volume percentage labels"""
	if music_volume_label and music_volume_slider:
		music_volume_label.text = "Music: " + str(int(music_volume_slider.value * 100)) + "%"
	if sfx_volume_label and sfx_volume_slider:
		sfx_volume_label.text = "SFX: " + str(int(sfx_volume_slider.value * 100)) + "%"

func _on_music_volume_changed(value: float):
	"""Handle music volume slider change"""
	print("Music volume changed to: ", value)
	if audio_manager:
		audio_manager.set_music_volume(value)
		update_volume_labels()

func _on_sfx_volume_changed(value: float):
	"""Handle SFX volume slider change"""
	print("SFX volume changed to: ", value)
	if audio_manager:
		audio_manager.set_sfx_volume(value)
		update_volume_labels()

func _on_music_toggle_changed(enabled: bool):
	"""Handle music toggle change"""
	print("Music toggle changed to: ", enabled)
	if audio_manager:
		audio_manager.toggle_music(enabled)

func _on_sfx_toggle_changed(enabled: bool):
	"""Handle SFX toggle change"""
	print("SFX toggle changed to: ", enabled)
	if audio_manager:
		audio_manager.toggle_sfx(enabled)

func _on_close_pressed():
	"""Handle close button press"""
	print("Close button pressed")
	hide()

func show_settings():
	"""Show the settings menu"""
	load_current_settings()
	visible = true

func hide_settings():
	"""Hide the settings menu"""
	visible = false
