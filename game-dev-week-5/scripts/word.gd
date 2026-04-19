extends Node2D

signal letter_picked(letter: String)

var letter: String = ""
var is_player_near: bool = false
var area_component: Area2D = null
var label_component: Label = null

func _ready() -> void:
	add_to_group("word_nodes")
	
	# Find Label recursively
	label_component = _find_child_by_type(self, "Label") as Label
	if not label_component:
		print("WARNING: 'Label' child node not found in Word node ", name)
	
	# Find Area2D recursively
	area_component = _find_child_by_type(self, "Area2D") as Area2D
	if area_component:
		area_component.body_entered.connect(_on_body_entered)
		area_component.body_exited.connect(_on_body_exited)
	else:
		print("WARNING: No Area2D child found in Word node ", name)

func _find_child_by_type(parent: Node, type_name: String) -> Node:
	for child in parent.get_children():
		if child.is_class(type_name):
			return child
		var result = _find_child_by_type(child, type_name)
		if result:
			return result
	return null

func activate(l: String) -> void:
	letter = l
	if label_component:
		label_component.text = letter
	show()
	if area_component:
		area_component.set_deferred("monitoring", true)

func deactivate() -> void:
	hide()
	if area_component:
		area_component.set_deferred("monitoring", false)

func set_letter(l: String) -> void:
	# Keep for backwards compatibility if needed
	activate(l)

func set_carried(carried: bool) -> void:
	if carried:
		if area_component:
			area_component.set_deferred("monitoring", false)
			area_component.set_deferred("monitorable", false)
	else:
		if area_component:
			area_component.set_deferred("monitoring", true)
			area_component.set_deferred("monitorable", true)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		is_player_near = true
		if body.has_method("add_nearby_word"):
			body.add_nearby_word(self)

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		is_player_near = false
		if body.has_method("remove_nearby_word"):
			body.remove_nearby_word(self)
