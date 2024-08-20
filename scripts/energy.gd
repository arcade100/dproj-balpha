extends Area2D

var value: int
var start: Vector2
var receiver: Node2D
var t = 0

func _process(delta: float) -> void:
	if receiver == null:
		return
	t += delta
	position = start.lerp(receiver.position, t)


func _on_area_entered(area: Area2D) -> void:
	if area == receiver:
		area.put_energy(self)
