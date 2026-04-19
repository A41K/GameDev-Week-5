extends Area2D

var player: Node2D = null

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _physics_process(delta: float) -> void:
	if player and player in get_overlapping_bodies():
		if player is Player and player.is_wall_sticking:
			# Keep the player pinned vertically while they are actively sticking.
			player.velocity.y = 0

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		player = body
		body.is_wall_sticking = true

func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		body.is_wall_sticking = false
		if player == body:
			player = null
