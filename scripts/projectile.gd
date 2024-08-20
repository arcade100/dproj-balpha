extends Area2D

var projectile_owner: Node2D
var velocity: Vector2
var damage: float

func _ready() -> void:
	var timer: Timer = $Timer
	timer.timeout.connect(queue_free)
	timer.start(5)

func set_projectile(_projectile_owner, _velocity, _damage):
	projectile_owner = _projectile_owner
	velocity = _velocity
	damage = _damage
	position = projectile_owner.position
	return self


func _process(delta: float) -> void:
	position += velocity * delta


func _on_body_entered(body: Node2D) -> void:
	if body != projectile_owner and body.has_method("take_damage"):
		body.take_damage(self)
