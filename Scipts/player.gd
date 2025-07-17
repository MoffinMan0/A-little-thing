extends CharacterBody2D
@export var max_health := 100
@export var arrow_speed: int = 50

signal health_changed(current: int, max: int)

const SPEED := 100.0
const JUMP_VELOCITY := -300.0
const GRAVITY := 750
const ARROW = preload("res://Scenes/arrow.tscn")

@onready var death_audio: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var collision_shape = $CollisionShape2D
@onready var animated_sprite = $AnimatedSprite2D
@onready var attack_area = $Attack_Area
@onready var area_right = $Attack_Area/Area_Right
@onready var area_left = $Attack_Area/Area_Left
@onready var platform_raycast = $CollisionShape2D/platform_raycast
@onready var marker_2d: Marker2D = $Marker2D

var score := 0
var current_health := max_health
var is_attacking := false
var is_dead := false
var can_attack := true
var last_damage_source

# Get the gravity from the project settings to be synced with RigidBody nodes.
func _ready():
	floor_snap_length = 8  # Snap length for 16px tiles
	var health_bar = get_node("Camera2D/Healthbar")  # Adjust to your path
	health_changed.connect(health_bar.update_health)
	emit_signal("health_changed", current_health, max_health)  # Initialize bar
	
	for coin in get_tree().get_nodes_in_group("Coins"):
		coin.collected.connect(coin_collected)

func _physics_process(delta):
	var accel = 0.0
		#Momentum
	var input_dir = Input.get_action_strength("Right") - Input.get_action_strength("Left")
	
	#Moves Left and right
	if not is_dead:
		var target_speed = input_dir * SPEED
	
		if is_on_floor():
			accel = SPEED * 10
		else:
			accel = SPEED * 2.5
		velocity.x = move_toward(velocity.x, target_speed, accel * delta)
		move_and_slide()
		
	if is_dead:
		velocity.x = 0  # Prevent horizontal movement
		if not is_on_floor():
			velocity.y += GRAVITY * delta  # Allow gravity to pull sprite down
		else:
			velocity.y = 0
		move_and_slide()
		return
	# Apply gravity
	if not is_on_floor():
		velocity.y += GRAVITY * delta
			
	else:
		velocity.y = 0  # Reset vertical velocity when grounded

	# Jumping
	if Input.is_action_just_pressed("Jump"):
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
		elif score > 0:
			velocity.y = JUMP_VELOCITY
			score -= 1 
	
	if Input.is_action_just_pressed("Down") and is_on_floor():
		if platform_raycast.is_colliding():
			var collider = platform_raycast.get_collider()
			if collider is AnimatableBody2D: # or any node type you use for platforms
				collider.call("drop_through")
				print("Sc_Player: drop called")
	
	#Calls die() function on 0 HP
	if is_dead == false:
		if current_health <= 0:
			die()
		
	#Animation Flip
	if is_dead == false:
		if not is_attacking:
			if is_on_floor():
				if input_dir==0 :
					animated_sprite.play("Idle")
				else:
					animated_sprite.play("Run")
			else:
				animated_sprite.play("Jump")
	#Changes Character direction animation
	#looking right
	if input_dir > 0:
		animated_sprite.flip_h = false
		attack_area.position.x = abs(attack_area.position.x)  # Ensure it's on the right
	elif input_dir < 0:
	#looking left
		animated_sprite.flip_h = true
		attack_area.position.x = -abs(attack_area.position.x)  # Ensure it's on the right
		
	#Detects if player is attacking, plays animation and enables hitbox to delete enemy
	if not is_dead:
		#Checks if melee attack has been pressed, makes sure you're not currently attacking and checks if you can attack
		if Input.is_action_just_pressed("Melee_Attack") and not is_attacking and can_attack == true:
			#Sets Attacking to true so you can only fire once an animation cycle is completed
			is_attacking = true
			animated_sprite.play("Attack")
			#Allows the hitbox on the right to enable if facing there, else::
			if not animated_sprite.flip_h:
				area_right.disabled = false
				area_left.disabled = true
			else:
				area_left.disabled = false
				area_right.disabled = true
				
			attack_area.monitoring = true
	if Input.is_action_just_pressed("Shoot"):
		shoot_arrow()

#Shoot Arrow Method
func shoot_arrow():
	if can_attack and not is_attacking:
		is_attacking = true
		animated_sprite.play("Shoot")
		
func spawn_arrow():
	var arrow = ARROW.instantiate()
	get_tree().current_scene.add_child(arrow)
	arrow.global_position = marker_2d.global_position
	
	var dir = Vector2.RIGHT
	if animated_sprite.flip_h:
		dir = Vector2.LEFT

	arrow.set_direction(dir)
	arrow.speed = arrow_speed

func _on_animated_sprite_2d_animation_finished():
		is_attacking = false
		attack_area.monitoring = false
		if animated_sprite.animation == "Shoot":
			spawn_arrow()
		#Detects if Enemy is in attack's AOE
func _on_attack_area_area_entered(area):
	if area.get_parent().is_in_group("Traps"):
		return
		
	Menu.add_log_entry("Sc_Player: Player Attacked Enemy.")
	print("Sc_Player: Hit area:", area.name)
	
	var enemy = area.get_parent()  # Get the enemy node owning the killzone
	if enemy and enemy.has_method("die"):
		enemy.die()

func take_damage(damage_dealt:int,source_name = ""):
	if not is_dead:
		if current_health > 0:
			current_health = max(current_health - damage_dealt, 0)
			if source_name:
				last_damage_source = source_name
			emit_signal("health_changed", current_health, max_health)
			Menu.add_log_entry("Sc_Player: Took damage, Health:" + str(current_health))
func reset_health():
	can_attack = true
	is_dead = false
	current_health = max_health
	emit_signal("health_changed", current_health, max_health)
	
func die():
	if is_dead == true:
		if not is_on_floor():
			velocity.y = 0
		return
	death_audio.play()
	can_attack = false
	is_dead = true
	animated_sprite.play("Death")
	Menu.add_log_entry("Sc_Player: die() called on "+ str(name) +" by "+str(last_damage_source))

func coin_collected():
		score += 1
		Menu.add_log_entry("Coin collected! Total: " + str(score))
