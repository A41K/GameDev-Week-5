extends Area2D

func _ready() -> void:
	# This automatically connects the signal so you don't have to do it in the Godot Editor
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		GameController.save_coins()
		GameController.clear_respawn_point()
		get_tree().change_scene_to_file("res://scenes/level_2.tscn")
