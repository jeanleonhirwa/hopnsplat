extends Node

# AudioManager - Global audio system for Hop n' Splat
# Handles background music, sound effects, and audio settings

signal music_volume_changed(volume: float)
signal sfx_volume_changed(volume: float)

# Audio players
@onready var music_player: AudioStreamPlayer
@onready var sfx_player: AudioStreamPlayer

# Audio settings
var master_volume: float = 1.0
var music_volume: float = 0.7
var sfx_volume: float = 0.8
var music_enabled: bool = true
var sfx_enabled: bool = true

# Current music track
var current_music_track: AudioStream
var is_music_playing: bool = false

# UI sound system (Task 3.1)
var ui_sounds_cache: Dictionary = {}
var ui_sound_pitch_variance: float = 0.05

func _ready():
	"""Initialize the audio manager"""
	# Create audio players
	music_player = AudioStreamPlayer.new()
	sfx_player = AudioStreamPlayer.new()
	
	# Configure music player
	music_player.bus = "Music"
	music_player.autoplay = false
	music_player.stream_paused = false
	
	# Configure SFX player
	sfx_player.bus = "SFX"
	sfx_player.autoplay = false
	
	# Add players to scene tree
	add_child(music_player)
	add_child(sfx_player)
	
	# Load audio settings
	load_audio_settings()
	
	# Apply initial volumes
	update_volumes()
	
	# Pre-cache UI sounds (Task 3.1)
	_cache_ui_sounds()
	
	print("AudioManager initialized - Music: ", music_volume, " SFX: ", sfx_volume)

func play_background_music(music_stream: AudioStream = null, loop: bool = true):
	"""Play background music"""
	if not music_enabled:
		return
	
	# Use default music if none provided
	if music_stream == null:
		music_stream = preload("res://audio/backround-music/1.mp3")
	
	# Don't restart if same track is already playing
	if current_music_track == music_stream and is_music_playing:
		return
	
	# Stop current music
	stop_background_music()
	
	# Set new track
	current_music_track = music_stream
	music_player.stream = music_stream
	
	# Configure looping
	if music_stream is AudioStreamMP3:
		music_stream.loop = loop
	elif music_stream is AudioStreamOggVorbis:
		music_stream.loop = loop
	
	# Play music
	music_player.play()
	is_music_playing = true
	
	print("Background music started: ", music_stream.resource_path if music_stream else "default")

func stop_background_music():
	"""Stop background music"""
	if music_player and is_music_playing:
		music_player.stop()
		is_music_playing = false
		print("Background music stopped")

func pause_background_music():
	"""Pause background music"""
	if music_player and is_music_playing:
		music_player.stream_paused = true
		print("Background music paused")

func resume_background_music():
	"""Resume background music"""
	if music_player and is_music_playing:
		music_player.stream_paused = false
		print("Background music resumed")

func set_master_volume(volume: float):
	"""Set master volume (0.0 to 1.0)"""
	master_volume = clamp(volume, 0.0, 1.0)
	update_volumes()
	save_audio_settings()

func set_music_volume(volume: float):
	"""Set music volume (0.0 to 1.0)"""
	music_volume = clamp(volume, 0.0, 1.0)
	update_volumes()
	emit_signal("music_volume_changed", music_volume)
	save_audio_settings()

func set_sfx_volume(volume: float):
	"""Set SFX volume (0.0 to 1.0)"""
	sfx_volume = clamp(volume, 0.0, 1.0)
	update_volumes()
	emit_signal("sfx_volume_changed", sfx_volume)
	save_audio_settings()

func toggle_music(enabled: bool):
	"""Enable/disable music"""
	music_enabled = enabled
	if enabled:
		if current_music_track and not is_music_playing:
			play_background_music(current_music_track)
	else:
		stop_background_music()
	save_audio_settings()

func toggle_sfx(enabled: bool):
	"""Enable/disable sound effects"""
	sfx_enabled = enabled
	update_volumes()
	save_audio_settings()

func update_volumes():
	"""Update audio bus volumes"""
	# Set music bus volume
	var music_db = linear_to_db(master_volume * music_volume * (1.0 if music_enabled else 0.0))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), music_db)
	
	# Set SFX bus volume
	var sfx_db = linear_to_db(master_volume * sfx_volume * (1.0 if sfx_enabled else 0.0))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), sfx_db)
	
	# Set master bus volume
	var master_db = linear_to_db(master_volume)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), master_db)

func play_sfx(sfx_stream: AudioStream, volume_scale: float = 1.0):
	"""Play a sound effect"""
	if not sfx_enabled or not sfx_stream:
		return
	
	# Create temporary player for this SFX
	var temp_player = AudioStreamPlayer.new()
	temp_player.bus = "SFX"
	temp_player.stream = sfx_stream
	temp_player.volume_db = linear_to_db(volume_scale)
	
	add_child(temp_player)
	temp_player.play()
	
	# Remove player when finished
	temp_player.finished.connect(func(): temp_player.queue_free())

func save_audio_settings():
	"""Save audio settings to file"""
	var save_file = FileAccess.open("user://audio_settings.dat", FileAccess.WRITE)
	if save_file:
		var settings = {
			"master_volume": master_volume,
			"music_volume": music_volume,
			"sfx_volume": sfx_volume,
			"music_enabled": music_enabled,
			"sfx_enabled": sfx_enabled
		}
		save_file.store_string(JSON.stringify(settings))
		save_file.close()

func load_audio_settings():
	"""Load audio settings from file"""
	var save_file = FileAccess.open("user://audio_settings.dat", FileAccess.READ)
	if save_file:
		var settings_text = save_file.get_as_text()
		save_file.close()
		
		var json = JSON.new()
		var parse_result = json.parse(settings_text)
		if parse_result == OK:
			var settings = json.data
			master_volume = settings.get("master_volume", 1.0)
			music_volume = settings.get("music_volume", 0.7)
			sfx_volume = settings.get("sfx_volume", 0.8)
			music_enabled = settings.get("music_enabled", true)
			sfx_enabled = settings.get("sfx_enabled", true)
			print("Audio settings loaded")

func get_music_volume() -> float:
	"""Get current music volume"""
	return music_volume

func get_sfx_volume() -> float:
	"""Get current SFX volume"""
	return sfx_volume

func is_music_enabled() -> bool:
	"""Check if music is enabled"""
	return music_enabled

func is_sfx_enabled() -> bool:
	"""Check if SFX is enabled"""
	return sfx_enabled


# UI Sound System Methods (Task 3.1)

func _cache_ui_sounds() -> void:
	"""Pre-cache all UI sounds for instant playback."""
	ui_sounds_cache = {
		"tap_a": preload("res://assets/ui_sounds/tap-a.ogg"),
		"tap_b": preload("res://assets/ui_sounds/tap-b.ogg"),
		"click_a": preload("res://assets/ui_sounds/click-a.ogg"),
		"click_b": preload("res://assets/ui_sounds/click-b.ogg"),
		"switch_a": preload("res://assets/ui_sounds/switch-a.ogg"),
		"switch_b": preload("res://assets/ui_sounds/switch-b.ogg")
	}
	print("UI sounds cached: ", ui_sounds_cache.size(), " sounds loaded")


# UI Sound Playback Methods (Task 3.2)

func play_ui_hover() -> void:
	"""Play a random hover sound (tap-a or tap-b)."""
	var sound_key = "tap_a" if randf() > 0.5 else "tap_b"
	if ui_sounds_cache.has(sound_key):
		_play_ui_sound(ui_sounds_cache[sound_key])


func play_ui_click() -> void:
	"""Play a random click sound (click-a or click-b)."""
	var sound_key = "click_a" if randf() > 0.5 else "click_b"
	if ui_sounds_cache.has(sound_key):
		_play_ui_sound(ui_sounds_cache[sound_key])


func play_ui_switch() -> void:
	"""Play a random switch sound (switch-a or switch-b)."""
	var sound_key = "switch_a" if randf() > 0.5 else "switch_b"
	if ui_sounds_cache.has(sound_key):
		_play_ui_sound(ui_sounds_cache[sound_key])


func _play_ui_sound(sound: AudioStream, pitch_variance: bool = true) -> void:
	"""Play a UI sound with optional pitch variation."""
	if not sfx_enabled or not sound:
		return
	
	# Create temporary player for this UI sound
	var temp_player = AudioStreamPlayer.new()
	temp_player.bus = "SFX"
	temp_player.stream = sound
	
	# Apply pitch variation if enabled
	if pitch_variance:
		temp_player.pitch_scale = _get_random_pitch()
	
	add_child(temp_player)
	temp_player.play()
	
	# Remove player when finished
	temp_player.finished.connect(func(): temp_player.queue_free())


func _get_random_pitch() -> float:
	"""Return a random pitch value between 0.95 and 1.05."""
	return randf_range(0.95, 1.05)
