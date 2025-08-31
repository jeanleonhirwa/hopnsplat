extends Control

# Audio Settings Menu - Volume controls and audio options

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
	# Find UI elements
	music_volume_slider = get_node_or_null("VBoxContainer/MusicContainer/MusicVolumeSlider")
	sfx_volume_slider = get_node_or_null("VBoxContainer/SFXContainer/SFXVolumeSlider")
	music_toggle = get_node_or_null("VBoxContainer/MusicContainer/MusicToggle")
	sfx_toggle = get_node_or_null("VBoxContainer/SFXContainer/SFXToggle")
	music_volume_label = get_node_or_null("VBoxContainer/MusicContainer/MusicVolumeLabel")
	sfx_volume_label = get_node_or_null("VBoxContainer/SFXContainer/SFXVolumeLabel")
	close_button = get_node_or_null("VBoxContainer/CloseButton")
	
	# Connect signals
	if music_volume_slider:
		music_volume_slider.value_changed.connect(_on_music_volume_changed)
	if sfx_volume_slider:
		sfx_volume_slider.value_changed.connect(_on_sfx_volume_changed)
	if music_toggle:
		music_toggle.toggled.connect(_on_music_toggle_changed)
	if sfx_toggle:
		sfx_toggle.toggled.connect(_on_sfx_toggle_changed)
	if close_button:
		close_button.pressed.connect(_on_close_pressed)
	
	# Load current settings
	load_current_settings()

func load_current_settings():
	"""Load current audio settings from AudioManager"""
	if music_volume_slider:
		music_volume_slider.value = AudioManager.get_music_volume()
	if sfx_volume_slider:
		sfx_volume_slider.value = AudioManager.get_sfx_volume()
	if music_toggle:
		music_toggle.button_pressed = AudioManager.is_music_enabled()
	if sfx_toggle:
		sfx_toggle.button_pressed = AudioManager.is_sfx_enabled()
	
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
	AudioManager.set_music_volume(value)
	update_volume_labels()

func _on_sfx_volume_changed(value: float):
	"""Handle SFX volume slider change"""
	AudioManager.set_sfx_volume(value)
	update_volume_labels()

func _on_music_toggle_changed(enabled: bool):
	"""Handle music toggle change"""
	AudioManager.toggle_music(enabled)

func _on_sfx_toggle_changed(enabled: bool):
	"""Handle SFX toggle change"""
	AudioManager.toggle_sfx(enabled)

func _on_close_pressed():
	"""Handle close button press"""
	hide()

func show_settings():
	"""Show the settings menu"""
	load_current_settings()
	visible = true

func hide_settings():
	"""Hide the settings menu"""
	visible = false
