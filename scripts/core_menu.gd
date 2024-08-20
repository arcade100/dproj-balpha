extends Control

@export var anim_delay = 0.8

var active = false
var button_positions: PackedVector2Array = []
var buttons
var button_count: float

@onready var scrap_text: Button = $ScrapText
@onready var scrap_cost_label: Label = $ScrapText/CostLabel
@onready var energy_text: Button = $EnergyText
@onready var energy_cost_label: Label = $EnergyText/CostLabel

signal purchased_item(item_name)

func can_purchase(button) -> bool:
	if PlayerStats.scraps < button.get_meta("scrap_cost"):
		scrap_text.add_theme_color_override("font_color", Color.INDIAN_RED)
		return false
	scrap_text.add_theme_color_override("font_color", Color.MEDIUM_SEA_GREEN)
	if PlayerStats.energy < button.get_meta("energy_cost"):
		energy_text.add_theme_color_override("font_color", Color.INDIAN_RED)
		return false
	energy_text.add_theme_color_override("font_color", Color.MEDIUM_SEA_GREEN)
	return true

func on_button_hover(button):
	scrap_cost_label.show()
	scrap_cost_label.text = "-%d" % button.get_meta("scrap_cost")
	energy_cost_label.show()
	energy_cost_label.text = "-%d" % button.get_meta("energy_cost")
	can_purchase(button)
	
func on_button_buy(button):
	if not can_purchase(button):
		return
	PlayerStats.scraps -= button.get_meta("scrap_cost")
	PlayerStats.energy -= button.get_meta("energy_cost")
	PlayerStats.inventory[button.get_meta("item_name")] += 1
	purchased_item.emit(button.get_meta("item_name"))
	update_scrap_counter()
	can_purchase(button)

func on_button_hover_away(button):
	scrap_text.remove_theme_color_override("font_color")
	scrap_cost_label.hide()
	energy_text.remove_theme_color_override("font_color")
	energy_cost_label.hide()

func _ready():
	buttons = get_children()
	button_count = get_child_count()
	for button in buttons:
		button_positions.append(button.position)
		button.position = position
		if button.get_meta("scrap_cost", -1) != -1:
			button.mouse_entered.connect(on_button_hover.bind(button))
			button.mouse_exited.connect(on_button_hover_away.bind(button))
			button.button_up.connect(on_button_buy.bind(button))
		button.hide()
	
	scrap_cost_label.hide()
	energy_cost_label.hide()

func show_menu():
	for i in range(buttons.size()):
		var tween = get_tree().create_tween()
		tween.tween_property(buttons[i], "position", button_positions[i], anim_delay).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
		buttons[i].show()

func hide_menu():
	for i in range(buttons.size()):
		var tween = get_tree().create_tween()
		tween.tween_property(buttons[i], "position", position, anim_delay/4).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
		tween.tween_callback(buttons[i].hide)

func update_scrap_counter():
	$ScrapText.text = "scraps: %d" % PlayerStats.scraps
	$EnergyText.text = "energy: %d" % PlayerStats.energy
