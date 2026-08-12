extends CharacterBody2D
class_name Player

@export var speed: float = 180.0
@export var max_hp: int = 100
@export var fire_cooldown: float = 0.35
@export var fire_range: float = 260.0
@export var bullet_damage: int = 18

var hp: int
var _fire_timer: float = 0.0
var move_dir: Vector2 = Vector2.ZERO

signal hp_changed(new_hp: int, max_hp: int)
signal died()

func _ready() -> void:
	hp = max_hp
	add_to_group("player")
	collision_layer = 1  # player layer
	collision_mask = 0   # no physical solid collisions in this MVP

	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 14.0
	shape.shape = circle
	add_child(shape)

	var sprite := Sprite2D.new()
	var tex := load("res://assets/sprites/player.png")
	if tex:
		sprite.texture = tex
	sprite.scale = Vector2(2.2, 2.2)
	add_child(sprite)

func _physics_process(delta: float) -> void:
	if Global.game_over:
		return
	velocity = move_dir * speed
	move_and_slide()

	_fire_timer -= delta
	if _fire_timer <= 0.0:
		var target := _find_nearest_zombie()
		if target != null:
			_shoot_at(target)
			_fire_timer = fire_cooldown

func set_move_direction(dir: Vector2) -> void:
	move_dir = dir

func _find_nearest_zombie() -> Node2D:
	var zombies := get_tree().get_nodes_in_group("zombies")
	var nearest: Node2D = null
	var nearest_d := fire_range
	for z in zombies:
		if not (z is Node2D):
			continue
		var d := global_position.distance_to(z.global_position)
		if d <= nearest_d:
			nearest_d = d
			nearest = z
	return nearest

func _shoot_at(target: Node2D) -> void:
	var b := Bullet.new()
	get_parent().add_child(b)
	b.global_position = global_position
	var dir := (target.global_position - global_position).normalized()
	b.setup(dir, bullet_damage)

func take_damage(amount: int) -> void:
	if Global.game_over:
		return
	hp = max(0, hp - amount)
	hp_changed.emit(hp, max_hp)
	if hp <= 0:
		died.emit()
