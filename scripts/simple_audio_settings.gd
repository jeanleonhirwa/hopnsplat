extends Control

# Simple Audio Settings - Direct AudioServer control

@onready var music_label: Label
@onready var music_slider: HSlider
@onready var sfx_label: Label
@onready var sfx_slider: HSlider
@onready var close_button: Button

func _ready():
	# Get UI references
	music_label = $CenterContainer/Panel/VBox/MusicLabel
	music_slider = $CenterContainer/Panel/VBox/MusicSlider
	sfx_label = $CenterContainer/Panel/VBox/SFXLabel
	sfx_slider = $CenterContainer/Panel/VBox/SFXSlider
	close_button = $CenterContainer/Panel/VBox/CloseButton
	
	# Connect signals directly
	music_slider.value_changed.connect(_on_music_changed)
	sfx_slider.value_changed.connect(_on_sfx_changed)
	close_button.pressed.connect(_on_close_pressed)
	
	# Load current volumes from AudioServer
	var music_bus = AudioServer.get_bus_index("Music")
	var sfx_bus = AudioServer.get_bus_index("SFX")
	
	if music_bus != -1:
		var music_db = AudioServer.get_bus_volume_db(music_bus)
		music_slider.value = db_to_linear(music_db)
	
	if sfx_bus != -1:
		var sfx_db = AudioServer.get_bus_volume_db(sfx_bus)
		sfx_slider.value = db_to_linear(sfx_db)
	
	# Update labels
	_update_labels()
	
	print("Simple audio settings initialized")

func _on_music_changed(value: float):
	print("Music volume changed to: ", value)
	var music_bus = AudioServer.get_bus_index("Music")
	if music_bus != -1:
		AudioServer.set_bus_volume_db(music_bus, linear_to_db(value))
	_update_labels()

func _on_sfx_changed(value: float):
	print("SFX volume changed to: ", value)
	var sfx_bus = AudioServer.get_bus_index("SFX")
	if sfx_bus != -1:
		AudioServer.set_bus_volume_db(sfx_bus, linear_to_db(value))
	_update_labels()

func _on_close_pressed():
	print("Close button pressed")
	hide()

func _update_labels():
	if music_label and music_slider:
		music_label.text = "Music Volume: " + str(int(music_slider.value * 100)) + "%"
	if sfx_label and sfx_slider:
		sfx_label.text = "SFX Volume: " + str(int(sfx_slider.value * 100)) + "%"
