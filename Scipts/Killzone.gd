extends Area2D

@onready var timer = $Timer
#var player = get_tree().get_nodes_in_group("player")
var parent

func _ready():
	parent = get_parent()

func _on_body_entered(body):
	if body.has_method("take_damage"):
		Menu.add_log_entry(str(parent.name) + " groups: " + str(parent.get_groups()))
		print(parent.get_groups())
		#NEEDS REPAIR
		if parent.is_in_group("Traps") or parent.is_in_group("Enemies"):
			body.take_damage(25,self.name)
			print(parent.get_groups())
		elif self.name == "World Bounds":
			Menu.add_log_entry("Fell out of Bounds.")
			body.take_damage(100,self.name)
			
#body.get_node("CollisionShape2D").queue_free()
func _on_area_entered(_area):
	print(_area)
	if _area.name == "Area2D":
		get_parent().queue_free()
		
func _on_timer_timeout():
	#Engine.time_scale = 1
	get_tree().reload_current_scene() # Replace with function body.
