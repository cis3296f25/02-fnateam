extends Control

const CHARACTER_NAMES := [
	"Phanatic",
	"Gritty",
	"Franklin",
	"Hooters"
]

const CHARACTER_NODES := [
	"Phanatic",
	"Gritty",
	"Franklin",
	"Hooters"
]

func _ready() -> void:
	_set_character_names()

	for i in range(4):
		_update_character(i)

	$MarginContainer/VBoxContainer/RangeLabel.text = \
		"(0–4) → Night 1    (5–8) → Night 2    (9–12) → Night 3    (13–16) → Night 4    (17–20) → Night 5"

	$MarginContainer/VBoxContainer/TitleLabel.text = "Customize Night"


func _set_character_names() -> void:
	var row: HBoxContainer = $MarginContainer/VBoxContainer/CharactersRow

	for i in range(4):
		var node_name: String = CHARACTER_NODES[i]
		var char_node: Control = row.get_node(node_name)
		var name_label: Label = char_node.get_node("NameLabel%d" % i)
		name_label.text = CHARACTER_NAMES[i]


func _update_character(index: int) -> void:
	var level: int = GameManager.get_ai_level(index)

	var row: HBoxContainer = $MarginContainer/VBoxContainer/CharactersRow
	var node_name: String = CHARACTER_NODES[index]
	var char_node: Control = row.get_node(node_name)

	var value_label: Label = char_node.get_node("HBoxContainer/ValueLabel%d" % index)
	value_label.text = str(level)


func _change_level(index: int, delta: int) -> void:
	var new_level: int = GameManager.get_ai_level(index) + delta
	GameManager.set_ai_level(index, new_level)
	_update_character(index)


func _on_left_button_0_pressed() -> void:
	_change_level(0, -1)

func _on_right_button_0_pressed() -> void:
	_change_level(0, +1)

func _on_left_button_1_pressed() -> void:
	_change_level(1, -1)

func _on_right_button_1_pressed() -> void:
	_change_level(1, +1)

func _on_left_button_2_pressed() -> void:
	_change_level(2, -1)

func _on_right_button_2_pressed() -> void:
	_change_level(2, +1)

func _on_left_button_3_pressed() -> void:
	_change_level(3, -1)

func _on_right_button_3_pressed() -> void:
	_change_level(3, +1)


func _on_BackButton_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")


func _on_ReadyButton_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")
