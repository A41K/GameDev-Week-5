extends Area2D

var docked_letter: Node2D = null

func _ready() -> void:
	add_to_group("build_zone")
	self.body_entered.connect(_on_body_entered)
	self.body_exited.connect(_on_body_exited)
	
	if EventController.has_signal("word_ready"):
		EventController.word_ready.connect(_on_word_ready)

func _on_word_ready(word: String) -> void:
	GameController.target_word = word
	if docked_letter:
		docked_letter.queue_free()
		docked_letter = null

func try_accept_letter(letter_node: Node2D) -> bool:
	if docked_letter != null:
		return false 
		
	var tw = GameController.target_word
	if tw == "":
		return false
		

	docked_letter = letter_node
	letter_node.reparent(self)
	letter_node.global_position = global_position + Vector2(-20, -10) 
	letter_node.z_index = 10 
	
	_check_global_word()
	return true

func can_take_letter() -> bool:
	return docked_letter != null

func take_letter() -> Node2D:
	if docked_letter != null:
		var removed_letter = docked_letter
		docked_letter = null
		_check_global_word()
		return removed_letter
	return null

func _check_global_word() -> void:
	var tw = GameController.target_word
	if tw == "":
		return
		
	var zones = get_tree().get_nodes_in_group("build_zone")
	zones.sort_custom(func(a, b): return a.global_position.x < b.global_position.x)
	
	var current_word = ""
	for z in zones:
		if z.docked_letter:
			current_word += z.docked_letter.letter
		else:
			current_word += " " 
			
	current_word = current_word.strip_edges(false, true) 
	print("Pattern across platforms (Left -> Right): '", current_word, "'")
	
	if current_word.length() == tw.length() and not " " in current_word:
		if current_word == tw:
			print("SUCCESS! The word is correct. WORD COMPLETE! Level Finished!")
			_level_complete()
		else:
			print("WARNING: The word '", current_word, "' is built but does not match '", tw, "'. Try taking letters out!")

func _level_complete() -> void:
	var zones = get_tree().get_nodes_in_group("build_zone")
	for z in zones:
		if z.docked_letter and z.docked_letter.get_node_or_null("Label"):
			z.docked_letter.get_node("Label").modulate = Color(0, 1, 0, 1)
			
	var no_enter_barrier = get_tree().current_scene.find_child("BARS", true, false)
	if no_enter_barrier:
		no_enter_barrier.queue_free()
		print("Removed the BARS barrier!")

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if body.has_method("set_build_zone"):
			body.set_build_zone(self)

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		if body.has_method("clear_build_zone"):
			body.clear_build_zone(self)
