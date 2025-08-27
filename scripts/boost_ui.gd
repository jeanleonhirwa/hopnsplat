extends Control

# Boost UI elements
var boost_containers := {}
var boost_icons := {
	0: "🚀",  # JUMP_BOOST
	1: "⚡",  # SPEED_BOOST  
	2: "🛡️",  # SHIELD
	3: "🧲",  # COIN_MAGNET
	4: "💰"   # DOUBLE_POINTS
}

var boost_colors := {
	0: Color.CYAN,      # JUMP_BOOST
	1: Color.YELLOW,    # SPEED_BOOST
	2: Color.BLUE,      # SHIELD
	3: Color.MAGENTA,   # COIN_MAGNET
	4: Color.GOLD       # DOUBLE_POINTS
}

func _ready():
	# Set up UI container
	set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	position = Vector2(-120, 10)
	size = Vector2(100, 300)

func show_boost(boost_type: int, duration: float):
	"""Display a boost indicator with timer"""
	if boost_type in boost_containers:
		# Update existing boost
		update_boost_timer(boost_type, duration)
		return
	
	# Create new boost container
	var container = VBoxContainer.new()
	container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	# Create boost icon background
	var background = ColorRect.new()
	background.color = boost_colors.get(boost_type, Color.WHITE)
	background.color.a = 0.8
	background.size = Vector2(80, 60)
	background.custom_minimum_size = Vector2(80, 60)
	
	# Create boost icon label
	var icon_label = Label.new()
	icon_label.text = boost_icons.get(boost_type, "?")
	icon_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	icon_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	icon_label.add_theme_font_size_override("font_size", 24)
	
	# Create timer label
	var timer_label = Label.new()
	timer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	timer_label.add_theme_font_size_override("font_size", 12)
	timer_label.add_theme_color_override("font_color", Color.WHITE)
	
	# Add elements to container
	background.add_child(icon_label)
	container.add_child(background)
	container.add_child(timer_label)
	
	# Store references
	boost_containers[boost_type] = {
		"container": container,
		"timer_label": timer_label,
		"background": background,
		"duration": duration,
		"start_time": Time.get_unix_time_from_system()
	}
	
	# Add to UI
	add_child(container)
	
	# Animate in
	container.modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(container, "modulate:a", 1.0, 0.3)

func update_boost_timer(boost_type: int, new_duration: float):
	"""Update existing boost timer"""
	if boost_type in boost_containers:
		var boost_data = boost_containers[boost_type]
		boost_data.duration = new_duration
		boost_data.start_time = Time.get_unix_time_from_system()

func hide_boost(boost_type: int):
	"""Hide and remove boost indicator"""
	if boost_type in boost_containers:
		var container = boost_containers[boost_type].container
		
		# Animate out
		var tween = create_tween()
		tween.tween_property(container, "modulate:a", 0.0, 0.3)
		tween.tween_callback(container.queue_free)
		
		boost_containers.erase(boost_type)

func _process(_delta):
	"""Update boost timers"""
	var current_time = Time.get_unix_time_from_system()
	
	for boost_type in boost_containers.keys():
		var boost_data = boost_containers[boost_type]
		var elapsed = current_time - boost_data.start_time
		var remaining = boost_data.duration - elapsed
		
		if remaining <= 0:
			hide_boost(boost_type)
		else:
			# Update timer display
			boost_data.timer_label.text = "%.1fs" % remaining
			
			# Flash when almost expired
			if remaining <= 2.0:
				var flash_alpha = 0.5 + 0.5 * sin(current_time * 8.0)
				boost_data.background.modulate.a = flash_alpha

func get_boost_name(boost_type: int) -> String:
	"""Get human readable boost name"""
	match boost_type:
		0: return "Jump Boost"
		1: return "Speed Boost"
		2: return "Shield"
		3: return "Coin Magnet"
		4: return "Double Points"
		_: return "Unknown Boost"
