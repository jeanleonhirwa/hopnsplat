extends Control

# Audio Settings Menu - Volume controls and audio options

# Get reference to AudioManager autoload
var audio_manager

# UI References
@onready var music_volume_slider: HSlider
@onready var sfx_volume_slider: HSlider
@onready var music_value_label: Label
@onready var sfx_value_label: Label
@onready var music_toggle_checkbox: TextureButton
@onready var sfx_toggle_checkbox: TextureButton
@onready var test_sound_button: TextureButton
@onready var close_button: TextureButton

# Checkbox textures
var checkbox_unchecked: Texture2D
var checkbox_checked: Texture2D

# Animation tweens
var checkbox_tween: Tween

func _ready():
	"""Initialize audio settings menu"""
	# Wait a frame for the scene tree to be ready
	await get_tree().process_frame
	
	# Get AudioManager reference
	audio_manager = get_node("/root/AudioManager")
	
	# Load checkbox textures
	checkbox_unchecked = preload("res://assets/ui_packs/Yellow/Default/check_square_grey.png")
	checkbox_checked = preload("res://assets/ui_packs/Yellow/Default/check_square_color_checkmark.png")
	
	# Find UI elements
	music_volume_slider = get_node_or_null("Panel/VBoxContainer/MusicVolumeRow/HBoxContainer/SliderContainer/SliderRow/MusicVolumeSlider")
	sfx_volume_slider = get_node_or_null("Panel/VBoxContainer/SFXVolumeRow/HBoxContainer/SliderContainer/SliderRow/SFXVolumeSlider")
	music_value_label = get_node_or_null("Panel/VBoxContainer/MusicVolumeRow/HBoxContainer/SliderContainer/SliderRow/MusicValueLabel")
	sfx_value_label = get_node_or_null("Panel/VBoxContainer/SFXVolumeRow/HBoxContainer/SliderContainer/SliderRow/SFXValueLabel")
	music_toggle_checkbox = get_node_or_null("Panel/VBoxContainer/MusicToggleRow/HBoxContainer/MusicToggleCheckbox")
	sfx_toggle_checkbox = get_node_or_null("Panel/VBoxContainer/SFXToggleRow/HBoxContainer/SFXToggleCheckbox")
	test_sound_button = get_node_or_null("Panel/VBoxContainer/TestSoundButton")
	close_button = get_node_or_null("Panel/VBoxContainer/CloseButton")
	
	# Debug: Print if nodes are found
	print("AudioManager found: ", audio_manager != null)
	print("Music slider found: ", music_volume_slider != null)
	print("SFX slider found: ", sfx_volume_slider != null)
	print("Music toggle found: ", music_toggle_checkbox != null)
	print("SFX toggle found: ", sfx_toggle_checkbox != null)
	print("Test sound button found: ", test_sound_button != null)
	print("Close button found: ", close_button != null)
	
	# Setup checkboxes with textures
	if music_toggle_checkbox:
		music_toggle_checkbox.texture_normal = checkbox_unchecked
		music_toggle_checkbox.texture_pressed = checkbox_checked
		music_toggle_checkbox.texture_hover = checkbox_unchecked
	
	if sfx_toggle_checkbox:
		sfx_toggle_checkbox.texture_normal = checkbox_unchecked
		sfx_toggle_checkbox.texture_pressed = checkbox_checked
		sfx_toggle_checkbox.texture_hover = checkbox_unchecked
	
	# Load current settings
	load_current_settings()

func load_current_settings():
	"""Load current audio settings from AudioManager"""
	# Wait for AudioManager to be ready
	if not audio_manager:
		print("AudioManager not available yet")
		return
		
	if music_volume_slider:
		var val = audio_manager.get_music_volume() * 100
		music_volume_slider.value = val
		if music_value_label: music_value_label.text = str(int(val)) + "%"
		print("Set music slider to: ", val)
	
	if sfx_volume_slider:
		var val = audio_manager.get_sfx_volume() * 100
		sfx_volume_slider.value = val
		if sfx_value_label: sfx_value_label.text = str(int(val)) + "%"
		print("Set SFX slider to: ", val)
	
	if music_toggle_checkbox:
		music_toggle_checkbox.button_pressed = audio_manager.is_music_enabled()
		_update_checkbox_texture(music_toggle_checkbox, audio_manager.is_music_enabled())
		print("Set music toggle to: ", audio_manager.is_music_enabled())
	
	if sfx_toggle_checkbox:
		sfx_toggle_checkbox.button_pressed = audio_manager.is_sfx_enabled()
		_update_checkbox_texture(sfx_toggle_checkbox, audio_manager.is_sfx_enabled())
		print("Set SFX toggle to: ", audio_manager.is_sfx_enabled())

func _on_music_volume_changed(value: float):
	"""Handle music volume slider change"""
	print("Music volume changed to: ", value)
	if music_value_label: music_value_label.text = str(int(value)) + "%"
	if audio_manager:
		# Convert 0-100 range to 0-1 for AudioManager
		audio_manager.set_music_volume(value / 100.0)

func _on_sfx_volume_changed(value: float):
	"""Handle SFX volume slider change"""
	print("SFX volume changed to: ", value)
	if sfx_value_label: sfx_value_label.text = str(int(value)) + "%"
	if audio_manager:
		# Convert 0-100 range to 0-1 for AudioManager
		audio_manager.set_sfx_volume(value / 100.0)

func _on_music_toggle_toggled(button_pressed: bool):
	"""Handle music toggle checkbox"""
	print("Music toggle changed to: ", button_pressed)
	if audio_manager:
		audio_manager.toggle_music(button_pressed)
	
	# Play toggle animation
	_animate_checkbox_toggle(music_toggle_checkbox, button_pressed)
	
	# Play UI switch sound
	if audio_manager:
		audio_manager.play_ui_switch()

func _on_sfx_toggle_toggled(button_pressed: bool):
	"""Handle SFX toggle checkbox"""
	print("SFX toggle changed to: ", button_pressed)
	if audio_manager:
		audio_manager.toggle_sfx(button_pressed)
	
	# Play toggle animation
	_animate_checkbox_toggle(sfx_toggle_checkbox, button_pressed)
	
	# Play UI switch sound (only if SFX is being enabled)
	if audio_manager and button_pressed:
		audio_manager.play_ui_switch()

func _on_test_sound_pressed():
	"""Handle test sound button press"""
	print("Test sound button pressed")
	if audio_manager:
		# Play click-a.ogg at current SFX volume
		var test_sound = preload("res://assets/ui_sounds/click-a.ogg")
		audio_manager.play_sfx(test_sound)

func _on_close_pressed():
	"""Handle close button press"""
	print("Close button pressed")
	hide()

func _animate_checkbox_toggle(checkbox: TextureButton, is_checked: bool):
	"""Animate checkbox toggle with fade and scale effect"""
	if not checkbox:
		return
	
	# Kill existing tween if any
	if checkbox_tween and checkbox_tween.is_running():
		checkbox_tween.kill()
	
	# Update texture immediately
	_update_checkbox_texture(checkbox, is_checked)
	
	# Create animation tween
	checkbox_tween = create_tween()
	checkbox_tween.set_parallel(true)
	
	if is_checked:
		# Checkmark appears: fade in with scale
		checkbox.modulate.a = 0.0
		checkbox.scale = Vector2(0.5, 0.5)
		checkbox_tween.tween_property(checkbox, "modulate:a", 1.0, 0.2).set_ease(Tween.EASE_OUT)
		checkbox_tween.tween_property(checkbox, "scale", Vector2(1.0, 1.0), 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	else:
		# Checkmark disappears: fade out with scale
		checkbox.modulate.a = 1.0
		checkbox.scale = Vector2(1.0, 1.0)
		checkbox_tween.tween_property(checkbox, "modulate:a", 1.0, 0.2).set_ease(Tween.EASE_OUT)
		checkbox_tween.tween_property(checkbox, "scale", Vector2(1.0, 1.0), 0.2).set_ease(Tween.EASE_OUT)

func _update_checkbox_texture(checkbox: TextureButton, is_checked: bool):
	"""Update checkbox texture based on state"""
	if not checkbox:
		return
	
	if is_checked:
		checkbox.texture_normal = checkbox_checked
		checkbox.texture_pressed = checkbox_checked
	else:
		checkbox.texture_normal = checkbox_unchecked
		checkbox.texture_pressed = checkbox_unchecked

func show_settings():
	"""Show the settings menu"""
	load_current_settings()
	visible = true

func hide_settings():
	"""Hide the settings menu"""
	visible = false
