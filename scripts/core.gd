extends Node2D

@onready var station: Sprite2D = $GFX/Station
@onready var core_menu: Control = $CoreMenu

@export var wire_priority = 3

var wire_send_list = []

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	station.rotation += delta * 0.2

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		core_menu.update_scrap_counter()
		core_menu.show_menu()
		body.vicinity = self

func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		core_menu.hide_menu()
		if body.vicinity==self:
			body.vicinity = null
	

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("scrap"):
		var tween = get_tree().create_tween()
		area.player_latched.emit(area)
		tween.tween_property(area, "global_position", global_position, 0.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
		tween.tween_callback(area.queue_free)
		tween.tween_callback(func():PlayerStats.scraps+=1)
		var timer = get_tree().create_timer(0.6)
		timer.timeout.connect(core_menu.update_scrap_counter)

func put_energy(energy):
	PlayerStats.energy += energy.value
	core_menu.update_scrap_counter()
	energy.queue_free()
