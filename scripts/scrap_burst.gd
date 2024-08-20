extends Node2D

const SPACE_PARTS_086 = preload("res://assets/parts_scraps/spaceParts_086.png")
const SPACE_PARTS_087 = preload("res://assets/parts_scraps/spaceParts_087.png")
const SPACE_PARTS_088 = preload("res://assets/parts_scraps/spaceParts_088.png")
const SPACE_PARTS_089 = preload("res://assets/parts_scraps/spaceParts_089.png")
const SPACE_PARTS_090 = preload("res://assets/parts_scraps/spaceParts_090.png")
const SPACE_PARTS_091 = preload("res://assets/parts_scraps/spaceParts_091.png")
const SPACE_PARTS_092 = preload("res://assets/parts_scraps/spaceParts_092.png")
const SPACE_PARTS_093 = preload("res://assets/parts_scraps/spaceParts_093.png")
const SPACE_PARTS_094 = preload("res://assets/parts_scraps/spaceParts_094.png")

const SCRAP = preload("res://scenes/scrap.tscn")

var scrap_parts = []
var scrap_control = []
var bursting = false
var t = 0
var final_position: Vector2

func bounce_scrap_part(scrap_part, angle, spread, delta):
	scrap_part.global_position = scrap_part.global_position.lerp(global_position+Vector2(spread * cos(angle), spread * sin(angle)), delta)

func burst_scrap(burst_position, burst_direction, scrap_count) -> void:
	position = burst_position
	final_position = position + burst_direction.normalized() * 112
	var parts_array = [SPACE_PARTS_086, SPACE_PARTS_087, SPACE_PARTS_088, SPACE_PARTS_089, SPACE_PARTS_090, SPACE_PARTS_091, SPACE_PARTS_092, SPACE_PARTS_093, SPACE_PARTS_094]
	for i in range(scrap_count):
		
		var scrap_part = SCRAP.instantiate()
		# scrap_part.scale *= 1
		scrap_control.append(randi_range(62, 121))
		scrap_part.get_node("Sprite2D").modulate = Color.PLUM
		scrap_part.get_node("Sprite2D").texture = parts_array[randi_range(0, parts_array.size()-1)]
		scrap_part.position = Vector2.ZERO
		scrap_part.rotation = randf_range(0, 2*PI)
		scrap_parts.append(scrap_part)
		scrap_part.player_latched.connect(disconnect_scrap_part)
		scrap_part.tree_exited.connect(scrap_burst_suicide)
		call_deferred("add_child", scrap_part)

func scrap_burst_suicide():
	if get_child_count() <= 0:
		queue_free()

func _process(delta: float) -> void:
	if t > 5:
		return
	t += delta
	position = position.lerp(final_position, delta * 4)
	for i in range(scrap_parts.size()):
		bounce_scrap_part(scrap_parts[i], PI/3+2*PI*i/scrap_parts.size(), scrap_control[i], delta * 5)

func disconnect_scrap_part(part):
	var index = scrap_parts.find(part)
	if index != -1:
		scrap_parts.remove_at(index)
