extends Node

# Advanced Power-Up System for Hop n' Splat
class_name AdvancedPowerUps

signal power_up_activated(type: String)
signal power_up_expired(type: String)

# Power-up types
enum PowerUpType {
	# Time-based
	SLOW_MOTION,
	FREEZE_TIME,
	TIME_REWIND,
	
	# Movement
	DOUBLE_JUMP,
	WALL_JUMP,
	TELEPORT_DASH,
	GRAVITY_FLIP,
	
	# Platform effects
	STICKY_PLATFORMS,
	BOUNCY_PLATFORMS,
	GHOST_PLATFORMS,
	PLATFORM_MAGNET,
	
	# Environmental
	WIND_BOOST,
	LIGHTNING_CHAIN,
	COIN_RAIN,
	PLATFORM_BRIDGE,
	
	# Legendary
	PHOENIX_REVIVAL,
	TIME_MASTER,
	PLATFORM_CREATOR,
	DIMENSION_SHIFT
}

# Active power-ups tracking
var active_power_ups: Dictionary = {}
var power_up_timers: Dictionary = {}

# Power-up configurations
var power_up_configs = {
	PowerUpType.SLOW_MOTION: {
		"name": "Slow Motion",
		"duration": 8.0,
		"rarity": "common",
		"description": "Slows down time for precise jumps",
		"icon": "⏰",
		"color": Color.CYAN
	},
	PowerUpType.FREEZE_TIME: {
		"name": "Time Freeze",
		"duration": 3.0,
		"rarity": "rare",
		"description": "Freezes time completely",
		"icon": "❄️",
		"color": Color.LIGHT_BLUE
	},
	PowerUpType.TIME_REWIND: {
		"name": "Time Rewind",
		"duration": 0.0,  # Instant effect
		"rarity": "epic",
		"description": "Rewinds time by 3 seconds",
		"icon": "⏪",
		"color": Color.PURPLE
	},
	PowerUpType.DOUBLE_JUMP: {
		"name": "Double Jump",
		"duration": 15.0,
		"rarity": "common",
		"description": "Allows jumping in mid-air",
		"icon": "⬆️",
		"color": Color.GREEN
	},
	PowerUpType.WALL_JUMP: {
		"name": "Wall Jump",
		"duration": 12.0,
		"rarity": "uncommon",
		"description": "Jump off walls and platforms",
		"icon": "🧗",
		"color": Color.ORANGE
	},
	PowerUpType.TELEPORT_DASH: {
		"name": "Teleport Dash",
		"duration": 10.0,
		"rarity": "rare",
		"description": "Dash through platforms",
		"icon": "⚡",
		"color": Color.YELLOW
	},
	PowerUpType.GRAVITY_FLIP: {
		"name": "Gravity Flip",
		"duration": 8.0,
		"rarity": "epic",
		"description": "Reverse gravity direction",
		"icon": "🔄",
		"color": Color.MAGENTA
	},
	PowerUpType.STICKY_PLATFORMS: {
		"name": "Sticky Platforms",
		"duration": 20.0,
		"rarity": "common",
		"description": "Platforms grab you on contact",
		"icon": "🍯",
		"color": Color.BROWN
	},
	PowerUpType.BOUNCY_PLATFORMS: {
		"name": "Super Bounce",
		"duration": 15.0,
		"rarity": "uncommon",
		"description": "Platforms launch you higher",
		"icon": "🏀",
		"color": Color.RED
	},
	PowerUpType.GHOST_PLATFORMS: {
		"name": "Ghost Mode",
		"duration": 6.0,
		"rarity": "rare",
		"description": "Phase through platforms",
		"icon": "👻",
		"color": Color.WHITE
	},
	PowerUpType.PLATFORM_MAGNET: {
		"name": "Platform Magnet",
		"duration": 12.0,
		"rarity": "uncommon",
		"description": "Attracts nearby platforms",
		"icon": "🧲",
		"color": Color.STEEL_BLUE
	},
	PowerUpType.WIND_BOOST: {
		"name": "Wind Boost",
		"duration": 10.0,
		"rarity": "common",
		"description": "Wind carries you upward",
		"icon": "💨",
		"color": Color.LIGHT_GRAY
	},
	PowerUpType.LIGHTNING_CHAIN: {
		"name": "Lightning Chain",
		"duration": 8.0,
		"rarity": "epic",
		"description": "Lightning connects platforms",
		"icon": "⚡",
		"color": Color(0.0, 0.8, 1.0)
	},
	PowerUpType.COIN_RAIN: {
		"name": "Coin Rain",
		"duration": 5.0,
		"rarity": "uncommon",
		"description": "Coins fall from the sky",
		"icon": "💰",
		"color": Color.GOLD
	},
	PowerUpType.PLATFORM_BRIDGE: {
		"name": "Platform Bridge",
		"duration": 15.0,
		"rarity": "rare",
		"description": "Creates temporary platforms",
		"icon": "🌉",
		"color": Color.SANDY_BROWN
	},
	PowerUpType.PHOENIX_REVIVAL: {
		"name": "Phoenix Revival",
		"duration": 0.0,  # Passive effect
		"rarity": "legendary",
		"description": "Revive once when falling",
		"icon": "🔥",
		"color": Color(0.7, 0.1, 0.1)
	},
	PowerUpType.TIME_MASTER: {
		"name": "Time Master",
		"duration": 20.0,
		"rarity": "legendary",
		"description": "Control time at will",
		"icon": "⏳",
		"color": Color.DARK_VIOLET
	},
	PowerUpType.PLATFORM_CREATOR: {
		"name": "Platform Creator",
		"duration": 25.0,
		"rarity": "legendary",
		"description": "Create platforms anywhere",
		"icon": "🔨",
		"color": Color.DARK_GREEN
	},
	PowerUpType.DIMENSION_SHIFT: {
		"name": "Dimension Shift",
		"duration": 12.0,
		"rarity": "legendary",
		"description": "Shift between dimensions",
		"icon": "🌀",
		"color": Color.INDIGO
	}
}

# References
var player: CharacterBody2D
var main_game: Node2D
var camera: Camera2D

func _ready():
	# Get references
	player = get_node("../Player")
	main_game = get_parent()
	camera = get_node("../Camera2D")

func activate_power_up(type: PowerUpType):
	"""Activate a power-up with its effects"""
	var config = power_up_configs[type]
	
	# Check if already active (some can stack, others replace)
	if active_power_ups.has(type):
		if can_stack_power_up(type):
			extend_power_up_duration(type, config.duration)
		else:
			refresh_power_up(type, config.duration)
		return
	
	# Add to active power-ups
	active_power_ups[type] = true
	
	# Apply power-up effects
	apply_power_up_effects(type)
	
	# Set up timer if duration-based
	if config.duration > 0:
		var timer = Timer.new()
		timer.wait_time = config.duration
		timer.one_shot = true
		timer.timeout.connect(_on_power_up_expired.bind(type))
		add_child(timer)
		timer.start()
		power_up_timers[type] = timer
	
	# Emit signal and show notification
	emit_signal("power_up_activated", config.name)
	show_power_up_notification(config)

func apply_power_up_effects(type: PowerUpType):
	"""Apply the specific effects of each power-up"""
	match type:
		PowerUpType.SLOW_MOTION:
			apply_slow_motion()
		PowerUpType.FREEZE_TIME:
			apply_time_freeze()
		PowerUpType.TIME_REWIND:
			apply_time_rewind()
		PowerUpType.DOUBLE_JUMP:
			apply_double_jump()
		PowerUpType.WALL_JUMP:
			apply_wall_jump()
		PowerUpType.TELEPORT_DASH:
			apply_teleport_dash()
		PowerUpType.GRAVITY_FLIP:
			apply_gravity_flip()
		PowerUpType.STICKY_PLATFORMS:
			apply_sticky_platforms()
		PowerUpType.BOUNCY_PLATFORMS:
			apply_bouncy_platforms()
		PowerUpType.GHOST_PLATFORMS:
			apply_ghost_platforms()
		PowerUpType.PLATFORM_MAGNET:
			apply_platform_magnet()
		PowerUpType.WIND_BOOST:
			apply_wind_boost()
		PowerUpType.LIGHTNING_CHAIN:
			apply_lightning_chain()
		PowerUpType.COIN_RAIN:
			apply_coin_rain()
		PowerUpType.PLATFORM_BRIDGE:
			apply_platform_bridge()
		PowerUpType.PHOENIX_REVIVAL:
			apply_phoenix_revival()
		PowerUpType.TIME_MASTER:
			apply_time_master()
		PowerUpType.PLATFORM_CREATOR:
			apply_platform_creator()
		PowerUpType.DIMENSION_SHIFT:
			apply_dimension_shift()

# Time-based power-ups
func apply_slow_motion():
	"""Slow down game time"""
	Engine.time_scale = 0.5
	create_time_effect_particles()

func apply_time_freeze():
	"""Freeze time completely"""
	Engine.time_scale = 0.1
	create_freeze_effect()

func apply_time_rewind():
	"""Rewind player position and game state"""
	if player and player.has_method("rewind_position"):
		player.rewind_position(3.0)
	create_rewind_effect()

# Movement power-ups
func apply_double_jump():
	"""Enable double jump ability"""
	if player and player.has_method("enable_double_jump"):
		player.enable_double_jump()
	create_jump_boost_effect()

func apply_wall_jump():
	"""Enable wall jumping"""
	if player and player.has_method("enable_wall_jump"):
		player.enable_wall_jump()
	create_wall_jump_effect()

func apply_teleport_dash():
	"""Enable teleport dash ability"""
	if player and player.has_method("enable_teleport_dash"):
		player.enable_teleport_dash()
	create_teleport_effect()

func apply_gravity_flip():
	"""Flip gravity direction"""
	if player:
		player.gravity = -abs(player.gravity)
	create_gravity_flip_effect()

# Platform power-ups
func apply_sticky_platforms():
	"""Make platforms sticky"""
	var platforms = get_tree().get_nodes_in_group("platforms")
	for platform in platforms:
		if platform.has_method("set_sticky"):
			platform.set_sticky(true)
	create_sticky_effect()

func apply_bouncy_platforms():
	"""Make platforms super bouncy"""
	var platforms = get_tree().get_nodes_in_group("platforms")
	for platform in platforms:
		if platform.has_method("set_bounce_multiplier"):
			platform.set_bounce_multiplier(2.5)
	create_bounce_effect()

func apply_ghost_platforms():
	"""Allow phasing through platforms"""
	if player and player.has_method("enable_ghost_mode"):
		player.enable_ghost_mode()
	create_ghost_effect()

func apply_platform_magnet():
	"""Attract nearby platforms"""
	if player and player.has_method("enable_platform_magnet"):
		player.enable_platform_magnet()
	create_magnet_effect()

# Environmental power-ups
func apply_wind_boost():
	"""Apply upward wind force"""
	if player and player.has_method("apply_wind_force"):
		player.apply_wind_force(Vector2(0, -200))
	create_wind_effect()

func apply_lightning_chain():
	"""Create lightning between platforms"""
	create_lightning_chain_effect()

func apply_coin_rain():
	"""Spawn falling coins"""
	spawn_coin_rain()

func apply_platform_bridge():
	"""Create temporary platforms"""
	if player and player.has_method("enable_platform_creation"):
		player.enable_platform_creation()
	create_bridge_effect()

# Legendary power-ups
func apply_phoenix_revival():
	"""Grant one revival on death"""
	if player and player.has_method("grant_revival"):
		player.grant_revival()
	create_phoenix_effect()

func apply_time_master():
	"""Grant time control abilities"""
	if player and player.has_method("enable_time_control"):
		player.enable_time_control()
	create_time_master_effect()

func apply_platform_creator():
	"""Grant platform creation ability"""
	if player and player.has_method("enable_advanced_platform_creation"):
		player.enable_advanced_platform_creation()
	create_creator_effect()

func apply_dimension_shift():
	"""Enable dimension shifting"""
	if player and player.has_method("enable_dimension_shift"):
		player.enable_dimension_shift()
	create_dimension_effect()

func _on_power_up_expired(type: PowerUpType):
	"""Handle power-up expiration"""
	remove_power_up_effects(type)
	active_power_ups.erase(type)
	
	if power_up_timers.has(type):
		power_up_timers[type].queue_free()
		power_up_timers.erase(type)
	
	var config = power_up_configs[type]
	emit_signal("power_up_expired", config.name)

func remove_power_up_effects(type: PowerUpType):
	"""Remove power-up effects when expired"""
	match type:
		PowerUpType.SLOW_MOTION, PowerUpType.FREEZE_TIME:
			Engine.time_scale = 1.0
		PowerUpType.DOUBLE_JUMP:
			if player and player.has_method("disable_double_jump"):
				player.disable_double_jump()
		PowerUpType.WALL_JUMP:
			if player and player.has_method("disable_wall_jump"):
				player.disable_wall_jump()
		PowerUpType.TELEPORT_DASH:
			if player and player.has_method("disable_teleport_dash"):
				player.disable_teleport_dash()
		PowerUpType.GRAVITY_FLIP:
			if player:
				player.gravity = abs(player.gravity)
		PowerUpType.STICKY_PLATFORMS:
			var platforms = get_tree().get_nodes_in_group("platforms")
			for platform in platforms:
				if platform.has_method("set_sticky"):
					platform.set_sticky(false)
		PowerUpType.BOUNCY_PLATFORMS:
			var platforms = get_tree().get_nodes_in_group("platforms")
			for platform in platforms:
				if platform.has_method("set_bounce_multiplier"):
					platform.set_bounce_multiplier(1.0)
		PowerUpType.GHOST_PLATFORMS:
			if player and player.has_method("disable_ghost_mode"):
				player.disable_ghost_mode()
		PowerUpType.PLATFORM_MAGNET:
			if player and player.has_method("disable_platform_magnet"):
				player.disable_platform_magnet()
		PowerUpType.WIND_BOOST:
			if player and player.has_method("remove_wind_force"):
				player.remove_wind_force()

func can_stack_power_up(type: PowerUpType) -> bool:
	"""Check if power-up can stack with itself"""
	match type:
		PowerUpType.COIN_RAIN, PowerUpType.WIND_BOOST:
			return true
		_:
			return false

func extend_power_up_duration(type: PowerUpType, additional_time: float):
	"""Extend existing power-up duration"""
	if power_up_timers.has(type):
		var timer = power_up_timers[type]
		timer.wait_time += additional_time

func refresh_power_up(type: PowerUpType, new_duration: float):
	"""Refresh power-up with new duration"""
	if power_up_timers.has(type):
		var timer = power_up_timers[type]
		timer.wait_time = new_duration
		timer.start()

func show_power_up_notification(config: Dictionary):
	"""Show power-up activation notification"""
	if main_game and main_game.has_method("show_power_up_notification"):
		main_game.show_power_up_notification(config.name, config.icon, config.color)

# Visual effect creation methods
func create_time_effect_particles():
	"""Create time distortion particles"""
	pass  # Implement particle effects

func create_freeze_effect():
	"""Create freeze visual effect"""
	pass

func create_rewind_effect():
	"""Create rewind visual effect"""
	pass

func create_jump_boost_effect():
	"""Create jump boost visual effect"""
	pass

func create_wall_jump_effect():
	"""Create wall jump visual effect"""
	pass

func create_teleport_effect():
	"""Create teleport visual effect"""
	pass

func create_gravity_flip_effect():
	"""Create gravity flip visual effect"""
	pass

func create_sticky_effect():
	"""Create sticky platform visual effect"""
	pass

func create_bounce_effect():
	"""Create bounce platform visual effect"""
	pass

func create_ghost_effect():
	"""Create ghost mode visual effect"""
	pass

func create_magnet_effect():
	"""Create magnet visual effect"""
	pass

func create_wind_effect():
	"""Create wind visual effect"""
	pass

func create_lightning_chain_effect():
	"""Create lightning chain between platforms"""
	pass

func spawn_coin_rain():
	"""Spawn coins falling from sky"""
	pass

func create_bridge_effect():
	"""Create platform bridge visual effect"""
	pass

func create_phoenix_effect():
	"""Create phoenix revival visual effect"""
	pass

func create_time_master_effect():
	"""Create time master visual effect"""
	pass

func create_creator_effect():
	"""Create platform creator visual effect"""
	pass

func create_dimension_effect():
	"""Create dimension shift visual effect"""
	pass

func get_random_power_up_by_rarity() -> PowerUpType:
	"""Get random power-up based on rarity weights"""
	var rarity_weights = {
		"common": 50,
		"uncommon": 25,
		"rare": 15,
		"epic": 8,
		"legendary": 2
	}
	
	var total_weight = 0
	for weight in rarity_weights.values():
		total_weight += weight
	
	var random_value = randi() % total_weight
	var current_weight = 0
	
	for rarity in rarity_weights:
		current_weight += rarity_weights[rarity]
		if random_value < current_weight:
			return get_random_power_up_of_rarity(rarity)
	
	return PowerUpType.SLOW_MOTION  # Fallback

func get_random_power_up_of_rarity(rarity: String) -> PowerUpType:
	"""Get random power-up of specific rarity"""
	var power_ups_of_rarity = []
	
	for type in power_up_configs:
		if power_up_configs[type].rarity == rarity:
			power_ups_of_rarity.append(type)
	
	if power_ups_of_rarity.size() > 0:
		return power_ups_of_rarity[randi() % power_ups_of_rarity.size()]
	
	return PowerUpType.SLOW_MOTION  # Fallback
