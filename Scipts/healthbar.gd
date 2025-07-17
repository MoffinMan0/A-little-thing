extends Control

@onready var healthbar = $CanvasLayer/HSplitContainer/Healthbar

var is_dead: bool
var death_tracker: bool = is_dead
var player_node: Node
var displayed_health : float

func _ready():
	player_node = get_node("/root/Game/Player")  # or relative path depending on your scene
	is_dead = player_node.is_dead
	displayed_health = player_node.max_health
	#Menu.add_log_entry("Player status:" + str( is_dead))

func _process(delta):
	var current_health :float= player_node.current_health
	var health_update_speed := 250.0  # units per second, adjust for smoothness
	
	if death_tracker != is_dead:
		death_tracker = is_dead
		Menu.add_log_entry("Player status:" + str(is_dead))
	
	if displayed_health != current_health:
		displayed_health = lerp(displayed_health, current_health, health_update_speed * delta / player_node.max_health)
	# Update your health bar UI here with displayed_health
		healthbar.value = displayed_health
		
func update_health(current_health: int, max_health: int):
	if is_dead == true:
		healthbar.value = 0
		return
	healthbar.max_value = max_health
	healthbar.value = current_health
	
