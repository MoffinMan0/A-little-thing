extends Node2D

@onready var sprite_2d: Sprite2D = $Sprite2D

var direction: Vector2 = Vector2.RIGHT
var speed : int

func set_direction(dir: Vector2) -> void:
	direction = dir.normalized()
	sprite_2d.flip_h = direction == Vector2.LEFT

func _ready() -> void:
	$Timer.start()

func _process(delta):
	position += direction * speed * delta
	
func _on_timer_timeout() -> void:
	queue_free()

func _on_killzone_area_entered(area: Area2D) -> void:
	var enemy =  area.get_parent()
	if area.get_parent().is_in_group("Enemies"):
		enemy.die()
		queue_free()
	
	
