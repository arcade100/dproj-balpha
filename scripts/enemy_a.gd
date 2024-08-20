extends RigidBody2D

var primary_target: Node2D

@onready var PROJECTILE = load("res://scenes/projectile.tscn")
const SCRAP_BURST = preload("res://scenes/scrap_burst.tscn")

@onready var debug_line: Line2D = $DebugLine
@onready var sprite: Sprite2D = $Sprite2D
@onready var timer: Timer = $Timer

@export var health: float = 10
@export var strafing_radius: float = 300
@export var attack_radius: float = 600
@export var chase_speed: float = 14
@export var steer: float = 1
@export var lookaround_radius: float = 250
@export var direction_count: int = 16

var lookaround: PackedVector2Array = []
var pursue_vector = []

var pursuit_direction: Vector2
var velocity: Vector2

enum States {
	WANDERING,
	CHASING,
	STRAFING,
	ATTACKING,
	DEAD
}

var state: States

func _ready() -> void:
	state = States.CHASING
	primary_target = PlayerStats.player
	velocity = target_direction()
	var init_direction = Vector2.UP
	for i in range(direction_count):
		lookaround.append(init_direction)
		init_direction = init_direction.rotated(2*PI/direction_count)
		pursue_vector.append(0)
		

func target_direction():
	if primary_target == null:
		primary_target = self
	return (primary_target.position - position).normalized()
	
func random_vector():
	return Vector2(randf_range(-1000, 1000), randf_range(-1000, 1000))


func calculate_context_vectors():
	calculate_pursuit()
	calculate_avoidance()
	pursuit_direction = lookaround[pursue_vector.find(pursue_vector.max())]

	
func calculate_pursuit():
	var direction = target_direction()
	for i in range(direction_count):
		match state:
			States.STRAFING:
				pursue_vector[i] = lookaround[i].dot(direction) + lookaround[i].dot(direction.rotated(PI/2))
			States.CHASING:
				pursue_vector[i] = lookaround[i].dot(direction)
			States.ATTACKING:
				pursue_vector[i] = lookaround[i].dot(Vector2.ZERO) - lookaround[i].dot(direction.rotated(PI/6))
			States.DEAD:
				pursue_vector[i] = 0

func calculate_avoidance():
	var space_state = get_world_2d().direct_space_state
	for i in range(direction_count):
		var query = PhysicsRayQueryParameters2D.create(global_position, global_position+(lookaround[i]*lookaround_radius))
		query.exclude = [self]
		var result = space_state.intersect_ray(query)
		if(result):
			pursue_vector[i] = 0

func take_damage(projectile):
	if projectile.projectile_owner.name == "Player":
		var particles = load("res://assets/vfx/particles/short_white_pits.tscn").instantiate()
		particles.global_position = global_position
		get_tree().root.add_child(particles)
		particles.emitting = true
		health -= projectile.damage
		projectile.queue_free()
		velocity -= target_direction()
		var old_color = sprite.material.get_shader_parameter("tint_color")
		sprite.material.set_shader_parameter("tint_color", Color.LAVENDER)
		timer.timeout.connect(func():sprite.material.set_shader_parameter("tint_color", old_color))
		timer.start(0.2)
		
		if health <= 0:
			set_deferred("$CollisionPolygon2D.disabled", true)
			var scrap_burst = SCRAP_BURST.instantiate()
			get_tree().root.add_child(scrap_burst)
			scrap_burst.burst_scrap(position, velocity, randi_range(2, 6))
			state = States.DEAD
			get_tree().create_timer(0.2).timeout.connect(queue_free)
			# timer.start(0.2)

func shoot_projectile():
	if timer.is_stopped():
		var projectile = PROJECTILE.instantiate().set_projectile(self, (target_direction())*1800, 6)
		get_tree().root.add_child(projectile)
		timer.timeout.connect(func():state=States.CHASING)
		timer.start(2.6)

func _physics_process(delta):
	if state == States.DEAD:
		return
	calculate_context_vectors()
	var steering_velocity = (pursuit_direction - velocity) * steer
	velocity += (steering_velocity * delta)
	position += (velocity) * chase_speed
	sprite.rotation = Vector2.UP.angle_to(target_direction())
	
	if state == States.ATTACKING:
		shoot_projectile()
	
	var target_distance_squared = global_position.distance_squared_to(primary_target.position)
	if target_distance_squared < strafing_radius * strafing_radius:
		state = States.STRAFING
	elif target_distance_squared < attack_radius * attack_radius:
		state = States.ATTACKING
	else:
		state = States.CHASING
