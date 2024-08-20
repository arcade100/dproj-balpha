extends Area2D

var attract_target: Node2D
var attraction_speed: float = 3

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

signal player_latched

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if attract_target != null:
		global_position = global_position.lerp(attract_target.global_position, delta * 8)
		

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player" or body.name == "Core":
		attract_target = body
		player_latched.emit(self)
