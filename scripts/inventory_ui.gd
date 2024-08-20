extends Control

const KEYBOARD_1 = preload("res://assets/keyboard_mouse_vector_icons/keyboard_1.svg")
const KEYBOARD_1_OUTLINE = preload("res://assets/keyboard_mouse_vector_icons/keyboard_1_outline.svg")
const KEYBOARD_2 = preload("res://assets/keyboard_mouse_vector_icons/keyboard_2.svg")
const KEYBOARD_2_OUTLINE = preload("res://assets/keyboard_mouse_vector_icons/keyboard_2_outline.svg")
const KEYBOARD_3 = preload("res://assets/keyboard_mouse_vector_icons/keyboard_3.svg")
const KEYBOARD_3_OUTLINE = preload("res://assets/keyboard_mouse_vector_icons/keyboard_3_outline.svg")
const KEYBOARD_4 = preload("res://assets/keyboard_mouse_vector_icons/keyboard_4.svg")
const KEYBOARD_4_OUTLINE = preload("res://assets/keyboard_mouse_vector_icons/keyboard_4_outline.svg")

var key_list = []
var currently_selected_index: int

func _ready() -> void:
	key_list = [KEYBOARD_1, KEYBOARD_1_OUTLINE, KEYBOARD_2, KEYBOARD_2_OUTLINE, KEYBOARD_3, KEYBOARD_3_OUTLINE, KEYBOARD_4, KEYBOARD_4_OUTLINE]

func update_selected_item(item_index):
	$VBoxContainer.get_children()[currently_selected_index].get_node("TextureRect").texture = key_list[currently_selected_index*2+1]
	currently_selected_index = item_index
	$VBoxContainer.get_children()[item_index].get_node("TextureRect").texture = key_list[item_index*2]

func update_inventory_ui(_purchased_item):
	$VBoxContainer/Wires/Label.text = "%d" % PlayerStats.inventory["wire"]
	$VBoxContainer/Turrets/Label.text = "%d" % PlayerStats.inventory["turret"]
	$VBoxContainer/Routers/Label.text = "%d" % PlayerStats.inventory["router"]
	$VBoxContainer/PickupRaft/Label.text = "%d" % PlayerStats.inventory["pickup_raft"]
