extends RigidBody2D

const WIRE = preload("res://scenes/wire.tscn")

@export var speed: float = 600
@export var health: float = 100

@onready var background: Sprite2D = $Background
@onready var camera: Camera2D = $Camera2D

@onready var PROJECTILE = load("res://scenes/projectile.tscn")

const TARGET_A = preload("res://assets/cursor_pack/Outline/target_a.svg")
const LINE_CROSS = preload("res://assets/cursor_pack/Outline/line_cross.svg")

enum Equipment {
	Empty,
	Wire,
	Turret,
	Router,
	PickupRaft
}

var held_wire: Line2D

var equipped: Equipment = Equipment.Empty
var vicinity: Node2D

signal inventory_item_equipped(index)
signal inventory_updated
signal player_dead

func _ready() -> void:
	background.scale = get_viewport().size
	background.material.set_shader_parameter("offset", position)
	Input.set_custom_mouse_cursor(LINE_CROSS)
	PlayerStats.player = self

func _process(delta: float) -> void:
	var mouse_position = get_global_mouse_position()
	var look_direction = (mouse_position-position).normalized()
	rotation = Vector2.UP.angle_to(look_direction)
	
	var x_input: Vector2 = Input.get_axis("left", "right") * Vector2.RIGHT
	var y_input: Vector2 = Input.get_axis("bottom", "top") * Vector2.UP
	var direction: Vector2 = x_input + y_input
	
	var background_position = background.material.get_shader_parameter("offset")
	background.material.set_shader_parameter("offset",\
		background_position.lerp(global_position-background_position, (camera.position_smoothing_speed)*delta))
	position += direction * delta * speed
	
	
	if Input.is_action_just_pressed("fire"):
		var projectile = PROJECTILE.instantiate().set_projectile(self, (look_direction)*1800, 6)
		get_tree().root.add_child(projectile)
	
	if held_wire == null:
		if Input.is_action_just_pressed("focus"):
			match equipped:
				Equipment.Wire:
					if vicinity != null and PlayerStats.inventory["wire"] > 0:
						var wire = WIRE.instantiate()
						get_tree().root.add_child(wire)
						PlayerStats.inventory["wire"] -= 1
						inventory_updated.emit("wire")
						held_wire = wire
						held_wire.update_wire(self, vicinity)
	
	if held_wire:
		held_wire.update_wire()
		if Input.is_action_just_pressed("focus"):
			if vicinity != null and held_wire.reciever != vicinity:
				held_wire.update_wire(vicinity)
				held_wire.resolve_connection_priority()
				equipped = Equipment.Empty
				held_wire = null
			

func place_wire():
	equipped = Equipment.Wire
	inventory_item_equipped.emit(0)
	

func place_turret():
	equipped = Equipment.Turret
	inventory_item_equipped.emit(1)

func place_router():
	equipped = Equipment.Router
	inventory_item_equipped.emit(2)

func place_pickup_raft():
	equipped = Equipment.PickupRaft
	inventory_item_equipped.emit(3)

func _unhandled_input(event):
	var key = event.keycode if event is InputEventKey else null
	if not key or held_wire:
		return
	match key:
		KEY_1:
			place_wire()
		KEY_2:
			place_turret()
		KEY_3:
			place_router()
		KEY_4:
			place_pickup_raft()
		
func take_damage(projectile):
	if projectile.projectile_owner == null:
		return
	if projectile.projectile_owner.is_in_group("enemy"):
		health -= projectile.damage
		projectile.queue_free()
	if health <= 0:
		get_tree().create_timer(4).timeout.connect(get_tree().reload_current_scene)
		player_dead.emit()
