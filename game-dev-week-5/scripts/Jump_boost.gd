extends Area2D

@export var boosted_jump_height: float = -600.0
var normal_jump_height: float = -400.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		normal_jump_height = body.jump_height
		body.jump_height = boosted_jump_height

func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		body.jump_height = normal_jump_height
