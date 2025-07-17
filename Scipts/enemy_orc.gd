extends Node2D

const SPEED = 25
const GRAVITY = 800

var direction = 1 #Initial Direction
var velocity = Vector2.ZERO #Not too sure
var is_dead = false #Checks whether enemy is alive
var is_attacking = false

@onready var death_sound: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var animated_sprite = $AnimatedSprite2D
@onready var ray_cast_right = $RayCast_Right
@onready var ray_cast_left = $RayCast_Left
@onready var killzone = $Killzone
@onready var collision_shape_2d: CollisionShape2D = $Killzone/CollisionShape2D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if not is_dead and not is_attacking:
		animated_sprite.play("walk")
		
	if ray_cast_right.is_colliding():
		direction = -1
		animated_sprite.flip_h = true
	elif ray_cast_left.is_colliding():
		direction = 1
		animated_sprite.flip_h = false

	# Move enemy
	position.x += direction * SPEED * delta
	#print("orc: " + str(direction))
func die():
	if is_dead:
		return
	death_sound.play()
	is_dead = true
	killzone.monitoring = false
	animated_sprite.play("death")
	Menu.add_log_entry("Sc_enemy: Orc called die().")
	
func _on_animated_sprite_2d_animation_finished():
	if animated_sprite.animation == "death":
		hide()
		collision_shape_2d.set_deferred("disabled",true)
var original_position

func _ready():
	original_position = global_position

func reset():
	if not is_dead:
		return
	is_dead = false
	global_position = original_position
	show()
	killzone.monitoring = true
	collision_shape_2d.disabled = false
	animated_sprite.play("walk")
	print("Sc_Enemy: Reset Called on ", name)

func attack():
	var contact = ray_cast_right.get_collider()
	print(contact)
