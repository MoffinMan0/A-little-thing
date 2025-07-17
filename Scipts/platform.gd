extends AnimatableBody2D

@onready var shape = $CollisionShape2D

func drop_through():
	shape.set_deferred("disabled", true)
	await get_tree().create_timer(0.3).timeout
	shape.disabled = false
