extends Area2D
class_name Zombie

var max_hp: int = 40
var hp: int = 40
var speed: float = 60.0
var contact_damage: int = 6
var scrap_value: int = 2
var is_ranged: bool = false
var explodes_on_death: bool = false
var explosion_radius: float = 70.0
var explosion_damage: int = 30
var attack_cooldown: float = 0.6
var texture_path: String = "res://assets/sprites/zombie_basic.png"
var display_scale: float = 2.0

var _attack_timer: float = 0.0
var _ranged_timer: float = 0.0
var _target_player: Node2D = null
var _touching_player: Player = null
var base_target_pos: Vector2 = Vector2.ZERO
const CHASE_RADIUS := 420.0
const BASE_ATTACK_RADIUS := 42.0

signal died(zombie: Zombie)

func _ready() -> void:
	add_to_group("zombies")
	hp = max_hp
	monitoring = true
	monitorable = true
	collision_layer = 4 # zombies layer (bit 3 / value 4)
	collision_mask = 1  # detect player layer (bit 1 / value 1)

	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 9.0 * (display_scale / 2.0)
	shape.shape = circle
	add_child(shape)

	var sprite := Sprite2D.new()
	sprite.name = "Sprite"
	var tex := load(texture_path)
	if tex:
		sprite.texture = tex
	sprite.scale = Vector2(display_scale, display_scale)
	add_child(sprite)

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func setup(type_data: Dictionary, spawn_pos: Vector2, target_base_pos: Vector2) -> void:
	max_hp = type_data.get("hp", 40)
	hp = max_hp
	speed = type_data.get("speed", 60.0)
	contact_damage = type_data.get("damage", 6)
	scrap_value = type_data.get("scrap", 2)
	is_ranged = type_data.get("ranged", false)
	explodes_on_death = type_data.get("explodes", false)
	explosion_damage = type_data.get("explosion_damage", 30)
	texture_path = type_data.get("texture", texture_path)
	display_scale = type_data.get("display_scale", 2.0)
	global_position = spawn_pos
	base_target_pos = target_base_pos

func _physics_process(delta: float) -> void:
	if Global.game_over:
		return

	_attack_timer -= delta
	_ranged_timer -= delta

	var players := get_tree().get_nodes_in_group("player")
	_target_player = players[0] if players.size() > 0 else null

	var goal_pos: Vector2 = base_target_pos
	var chasing_player := false
	if _target_player != null:
		var d_player := global_position.distance_to(_target_player.global_position)
		if d_player <= CHASE_RADIUS:
			goal_pos = _target_player.global_position
			chasing_player = true

	if is_ranged and _target_player != null and chasing_player:
		var d := global_position.distance_to(_target_player.global_position)
		if d < 260.0:
			if _ranged_timer <= 0.0:
				_fire_spit(_target_player.global_position)
				_ranged_timer = 1.4
			if d > 140.0:
				_move_toward(goal_pos, delta)
			return

	if _touching_player != null:
		if _attack_timer <= 0.0:
			_touching_player.take_damage(contact_damage)
			_attack_timer = attack_cooldown
			if explodes_on_death:
				_explode()
		return

	var d_base := global_position.distance_to(base_target_pos)
	if d_base <= BASE_ATTACK_RADIUS and not chasing_player:
		if _attack_timer <= 0.0:
			Global.damage_base(contact_damage)
			_attack_timer = attack_cooldown
			if explodes_on_death:
				_explode()
		return

	_move_toward(goal_pos, delta)

func _move_toward(target: Vector2, delta: float) -> void:
	var dir := (target - global_position).normalized()
	global_position += dir * speed * delta

func _on_body_entered(body: Node) -> void:
	if body is Player:
		_touching_player = body
		_attack_timer = 0.0

func _on_body_exited(body: Node) -> void:
	if body is Player and _touching_player == body:
		_touching_player = null

func _fire_spit(target_pos: Vector2) -> void:
	var b := Bullet.new()
	get_parent().add_child(b)
	b.global_position = global_position
	b.speed = 320.0
	b.collision_mask = 0
	var dir := (target_pos - global_position).normalized()
	b.setup(dir, contact_damage)
	b.set_meta("hostile", true)
	for child in b.get_children():
		if child is ColorRect:
			child.color = Color(0.4, 1.0, 0.3)
	b.set_collision_mask_value(1, true) # hit player layer

func take_damage(amount: int) -> void:
	hp -= amount
	if hp <= 0:
		_die()

func _die() -> void:
	Global.add_scrap(scrap_value)
	Global.add_kill()
	if explodes_on_death:
		_explode()
	died.emit(self)
	queue_free()

func _explode() -> void:
	if _target_player != null and global_position.distance_to(_target_player.global_position) <= explosion_radius:
		_target_player.take_damage(explosion_damage)
	if global_position.distance_to(base_target_pos) <= explosion_radius + BASE_ATTACK_RADIUS:
		Global.damage_base(explosion_damage)
