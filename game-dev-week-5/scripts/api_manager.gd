extends Node

signal word_fetched(word: String)

var current_word: String = ""

var current_level: int = 1

func _ready() -> void:
	await get_tree().create_timer(0.5).timeout
	fetch_word_for_level(current_level)

func fetch_word_for_level(level: int) -> void:
	var word_length = level + 2 # level 1 -> 3, level 2 -> 4
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(self._on_word_request_completed.bind(word_length, http_request))
	var error = http_request.request("https://random-words-api.kushcreates.com/api?length=" + str(word_length) + "&words=1&language=en")
	if error != OK:
		print("An error occurred in the HTTP request.")
		_handle_fallback_word(word_length)
		http_request.queue_free()

func _on_word_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray, word_length: int, http_request: HTTPRequest) -> void:
	if response_code == 200:
		var response_string = body.get_string_from_utf8()
		var json = JSON.new()
		var error = json.parse(response_string)
		if error == OK:
			var data = json.get_data()
			var word_str = ""
			
			if typeof(data) == TYPE_ARRAY and data.size() > 0 and typeof(data[0]) == TYPE_DICTIONARY and data[0].has("word"):
				word_str = String(data[0]["word"])
			elif typeof(data) == TYPE_DICTIONARY and data.has("word"):
				word_str = String(data["word"])
				
			if word_str != "":
				current_word = word_str.to_upper()
				print("Fetched word: ", current_word)
				EventController.emit_signal("word_ready", current_word)
				word_fetched.emit(current_word)
				assign_letters_to_nodes(current_word)
				http_request.queue_free()
				return
				
	print("Word fetch failed, response code: ", response_code)
	_handle_fallback_word(word_length)
	http_request.queue_free()

func _handle_fallback_word(word_length: int) -> void:
	print("Using fallback words for length: ", word_length)
	
	var fallback_words = {
		3: ["CAT", "DOG", "SUN", "HAT", "BAT", "TOY"],
		4: ["BIRD", "TREE", "FROG", "MOON", "STAR", "GAME"],
		5: ["APPLE", "SMILE", "CLOUD", "GRAIN", "TRAIN", "HOUSE"],
		6: ["PLANET", "FOREST", "RABBIT", "LIZARD", "CASTLE", "DRAGON"]
	}
	
	var fallback_list = fallback_words.get(word_length, ["WORD"])
	var fallback = fallback_list[randi() % fallback_list.size()]
	
	current_word = fallback
	print("Fallback word ready: ", current_word)
	EventController.emit_signal("word_ready", current_word)
	word_fetched.emit(current_word)
	assign_letters_to_nodes(current_word)

func assign_letters_to_nodes(word: String) -> void:
	var word_nodes = get_tree().get_nodes_in_group("word_nodes")
	print("Found ", word_nodes.size(), " word nodes in the scene.")
	
	if word_nodes.size() < word.length():
		print("Warning: Not enough word_nodes (", word_nodes.size(), ") for the word length (", word.length(), "). Retrying in 1 second...")
		await get_tree().create_timer(1.0).timeout
		assign_letters_to_nodes(word)
		return

	var shuffled_nodes = word_nodes.duplicate()
	shuffled_nodes.shuffle()

	for i in range(shuffled_nodes.size()):
		var node = shuffled_nodes[i]
		if i < word.length():
			if node.has_method("activate"):
				node.activate(word[i])
			else:
				node.set_letter(word[i])
				node.show()
				node.set_deferred("monitoring", true)
		else:
			if node.has_method("deactivate"):
				node.deactivate()
			else:
				node.hide()
				node.set_deferred("monitoring", false)
