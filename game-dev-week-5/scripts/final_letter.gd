extends Area2D

@onready var label: Label = get_node_or_null("Label")

func _ready() -> void:
	if EventController.has_signal("word_ready"):
		EventController.word_ready.connect(_on_word_ready)
	else:
		print("WARNING: 'word_ready' signal not found on EventController.")

func _on_word_ready(word: String) -> void:
	if label:
		label.text = word
	else:
		print("WARNING: 'Label' child node not found in final_letter node ", name)
