extends Area2D

signal collected

@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _on_body_entered(body: Node2D) -> void:
	Menu.add_log_entry("Coin detects :" + str(body.name))
	if body.name != "Player":
		return
	collected.emit()
	play_audio()		
	Menu.add_log_entry("Coin detects :" + str(body.name))
	animated_sprite_2d.hide()

func play_audio() -> void:
	audio_stream_player_2d.play()

func _on_audio_stream_player_2d_finished() -> void:
	queue_free()
