extends Control

@onready var log_console = $CanvasLayer/Log_Console
@onready var v_box_container = $CanvasLayer/VBoxContainer
@onready var score_count: Label = $"CanvasLayer/CenterContainer/Score Count"

func _ready():
	log_console.visible = false

func _physics_process(_delta: float) -> void:
	score_count.text = "Score: %d" % get_player_score()

func _on_reset_button_pressed():
	get_tree().reload_current_scene()

func _unhandled_input(event):
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == 96:
			log_console.visible = not log_console.visible
			if log_console.visible:
				log_console.grab_focus()
			else:
				log_console.release_focus()
	if event is InputEventKey and event.pressed and not event.echo:
		if event.is_action_pressed("ui_cancel"):
			v_box_container.visible = not v_box_container.visible

func _on_respawn_enemies_pressed():
	#Gets "Enemies" node from root "game" scene
	var enemies_node = get_tree().get_root().get_node("Game/Enemies")
	if enemies_node:
		for child in enemies_node.get_children():
			if child.has_method("reset"):
				child.reset()
	else:
		print("Enemies node not found.")

func add_log_entry(entry: String) -> void:
	var game_log = log_console
	var current_lines = game_log.text.split("\n")
	
	current_lines.append(entry)
	
# Ensure only the last 50 entries are kept
	if current_lines.size() > 50:
		current_lines = current_lines.slice(current_lines.size() - 50, current_lines.size())

	game_log.text += entry + "\n"
	# Scroll to the bottom to show latest entries
	log_console.scroll_vertical = log_console.get_line_count()

func _on_quit_pressed():
	get_tree().quit()

func _on_respawn_player_pressed():
	var player_node = get_tree().get_root().get_node("Game/Player")
	if player_node:
		if player_node.has_method("reset_health"):
			player_node.reset_health()

func get_player_score()-> int:
	var players= get_tree().get_nodes_in_group("Player")
	if players.size() > 0:
		return players[0].score
	return 0
	
