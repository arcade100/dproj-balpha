extends Node2D

const ENEMY_A = preload("res://scenes/enemy_a.tscn")

var spawn_rate: float = 1
var spawn_delay: float = 9
var spawn_radius = 6000

@onready var timer: Timer = $Timer

func spawn_enemy():
	for i in range(int(spawn_rate)):
		var enemy_a = ENEMY_A.instantiate()
		var random_angle = randf_range(0, 2*PI)
		enemy_a.position = spawn_radius * Vector2(cos(random_angle), sin(random_angle))
		get_tree().root.add_child(enemy_a)
	timer.start(spawn_delay)

func _ready() -> void:
	timer.timeout.connect(spawn_enemy)
	timer.start(spawn_delay)

func _process(delta: float) -> void:
	if spawn_rate < 4 and spawn_delay > 2:
		spawn_rate += delta * 0.001
		spawn_delay -= delta * 0.001
