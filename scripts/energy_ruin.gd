extends Area2D

@onready var rune: Sprite2D = $GFX/Rune

@export var wire_priority = 1

var wire_send_list = []

var stored_energy = 20

@onready var timer: Timer = $Timer

func generate_energy():
	pass

func supply_energy():
	if wire_send_list.size() == 0:
		return
	if stored_energy > 0:
		wire_send_list.pick_random().send_energy(1)

func _ready() -> void:
	timer.timeout.connect(supply_energy)
	timer.start(1)
	
func _process(delta: float) -> void:
	rune.rotation += delta * 0.1
	
func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		body.vicinity = self

func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		if body.vicinity==self:
			body.vicinity = null
	
