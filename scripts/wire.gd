extends Line2D

var sender: Node2D
var reciever: Node2D
var is_sending = false

@onready var ENERGY = load("res://scenes/energy.tscn")

func _ready() -> void:
	add_point(Vector2.ZERO)
	add_point(Vector2.ZERO)

func update_wire(s = sender, r = reciever):
	sender = s
	reciever = r
	set_point_position(0, s.position)
	set_point_position(1, r.position)

func resolve_connection_priority():
	if not sender.get("wire_priority") or not reciever.get("wire_priority"):
		return
	if sender.wire_priority > reciever.wire_priority:
		var temp = sender
		reciever = sender
		sender = temp
	sender.wire_send_list.append(self)
	print(reciever.name)
	
func send_energy(energy_value):
	var energy = ENERGY.instantiate()
	energy.position = sender.position
	energy.value = energy_value
	energy.start = sender.position
	energy.receiver = reciever
	get_tree().root.add_child(energy)
