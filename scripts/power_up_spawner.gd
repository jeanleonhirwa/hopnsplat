extends Node2D

# Power-Up Spawner System
class_name PowerUpSpawner

signal power_up_collected(type)

# Spawning configuration
@export var spawn_chance: float = 0.15  # 15% chance per platform
@export var rare_spawn_multiplier: float = 0.3  # Rare power-ups are 30% as likely
@export var legendary_spawn_multiplier: float = 0.1  # Legendary power-ups are 10% as likely

# Power-up scene
@export var power_up_scene: PackedScene = preload("res://scenes/PowerUp.tscn")

# References
var platform_spawner: Node2D
var advanced_power_ups: AdvancedPowerUps
var spawned_power_ups: Array[Node2D] = []

# Spawn tracking
var platforms_since_last_power_up: int = 0
var guaranteed_spawn_threshold: int = 8  # Guarantee spawn after 8 platforms without one

func _ready():
	# Get references
	platform_spawner = get_node("../PlatformSpawner")
	
	# Create advanced power-ups system
	var AdvancedPowerUpsScript = preload("res://scripts/advanced_power_ups.gd")
	advanced_power_ups = AdvancedPowerUpsScript.new()
	add_child(advanced_power_ups)
	
	# Connect to platform spawner if available
	if platform_spawner and platform_spawner.has_signal("platform_spawned"):
		platform_spawner.connect("platform_spawned", _on_platform_spawned)

func _on_platform_spawned(platform: Node2D):
	"""Handle new platform spawn - chance to spawn power-up"""
	platforms_since_last_power_up += 1
	
	# Calculate spawn chance
	var current_spawn_chance = spawn_chance
	
	# Increase chance based on platforms without power-ups
	current_spawn_chance += (platforms_since_last_power_up * 0.02)
	
	# Guarantee spawn after threshold
	if platforms_since_last_power_up >= guaranteed_spawn_threshold:
		current_spawn_chance = 1.0
	
	# Roll for spawn
	if randf() < current_spawn_chance:
		spawn_power_up_near_platform(platform)
		platforms_since_last_power_up = 0

func spawn_power_up_near_platform(platform: Node2D):
	"""Spawn a power-up near the given platform"""
	if not power_up_scene:
		return
	
	# Create power-up instance
	var power_up = power_up_scene.instantiate()
	
	# Determine power-up type based on rarity
	var power_up_type = advanced_power_ups.get_random_power_up_by_rarity()
	
	# Configure power-up
	setup_power_up(power_up, power_up_type)
	
	# Position power-up
	var spawn_position = platform.global_position
	spawn_position.x += randf_range(-100, 100)  # Random horizontal offset
	spawn_position.y -= randf_range(50, 150)    # Above platform
	
	power_up.global_position = spawn_position
	
	# Add to scene
	get_parent().add_child(power_up)
	spawned_power_ups.append(power_up)
	
	# Connect collection signal
	if power_up.has_signal("collected"):
		power_up.connect("collected", _on_power_up_collected.bind(power_up_type))

func setup_power_up(power_up: Node2D, type: AdvancedPowerUps.PowerUpType):
	"""Configure power-up appearance and behavior"""
	var config = advanced_power_ups.power_up_configs[type]
	
	# Set visual properties
	if power_up.has_method("set_power_up_type"):
		power_up.set_power_up_type(type)
	
	# Set icon and color
	if power_up.has_method("set_appearance"):
		power_up.set_appearance(config.icon, config.color)
	
	# Set rarity glow effect
	if power_up.has_method("set_rarity_effect"):
		power_up.set_rarity_effect(config.rarity)

func _on_power_up_collected(type: AdvancedPowerUps.PowerUpType):
	"""Handle power-up collection"""
	# Activate the power-up
	advanced_power_ups.activate_power_up(type)
	
	# Emit signal for UI/audio feedback
	emit_signal("power_up_collected", type)
	
	# Play collection effect
	create_collection_effect(type)

func create_collection_effect(type: AdvancedPowerUps.PowerUpType):
	"""Create visual/audio effect for power-up collection"""
	var config = advanced_power_ups.power_up_configs[type]
	
	# Create particle effect based on rarity
	match config.rarity:
		"common":
			create_common_collection_effect(config.color)
		"uncommon":
			create_uncommon_collection_effect(config.color)
		"rare":
			create_rare_collection_effect(config.color)
		"epic":
			create_epic_collection_effect(config.color)
		"legendary":
			create_legendary_collection_effect(config.color)

func create_common_collection_effect(color: Color):
	"""Create simple collection effect"""
	# Simple particle burst
	pass

func create_uncommon_collection_effect(color: Color):
	"""Create enhanced collection effect"""
	# Particle burst with sparkles
	pass

func create_rare_collection_effect(color: Color):
	"""Create rare collection effect"""
	# Particle burst with ring effect
	pass

func create_epic_collection_effect(color: Color):
	"""Create epic collection effect"""
	# Large particle burst with shockwave
	pass

func create_legendary_collection_effect(color: Color):
	"""Create legendary collection effect"""
	# Massive effect with screen flash
	pass

func spawn_specific_power_up(type: AdvancedPowerUps.PowerUpType, position: Vector2):
	"""Spawn a specific power-up at position (for testing/special events)"""
	if not power_up_scene:
		return
	
	var power_up = power_up_scene.instantiate()
	setup_power_up(power_up, type)
	power_up.global_position = position
	
	get_parent().add_child(power_up)
	spawned_power_ups.append(power_up)
	
	if power_up.has_signal("collected"):
		power_up.connect("collected", _on_power_up_collected.bind(type))

func clear_all_power_ups():
	"""Clear all spawned power-ups (for game reset)"""
	for power_up in spawned_power_ups:
		if is_instance_valid(power_up):
			power_up.queue_free()
	spawned_power_ups.clear()
	platforms_since_last_power_up = 0

func get_active_power_ups() -> Dictionary:
	"""Get currently active power-ups"""
	if advanced_power_ups:
		return advanced_power_ups.active_power_ups
	return {}

func get_power_up_config(type: AdvancedPowerUps.PowerUpType) -> Dictionary:
	"""Get configuration for a power-up type"""
	if advanced_power_ups:
		return advanced_power_ups.power_up_configs[type]
	return {}

# Debug functions
func force_spawn_power_up():
	"""Force spawn a power-up for testing"""
	var platforms = get_tree().get_nodes_in_group("platforms")
	if platforms.size() > 0:
		spawn_power_up_near_platform(platforms[0])

func spawn_legendary_power_up():
	"""Spawn a random legendary power-up for testing"""
	var legendary_types = []
	for type in advanced_power_ups.power_up_configs:
		if advanced_power_ups.power_up_configs[type].rarity == "legendary":
			legendary_types.append(type)
	
	if legendary_types.size() > 0:
		var random_type = legendary_types[randi() % legendary_types.size()]
		var player = get_node("../Player")
		if player:
			spawn_specific_power_up(random_type, player.global_position + Vector2(0, -100))
