extends Area2D
class_name Bullet

var speed: float = 520.0
var damage: int = 10
var _dir: Vector2 = Vector2.RIGHT
var _life: float = 1.5

func _ready() -> void:
	collision_layer = 0
	collision_mask = 0
	monitoring = true
	monitorable = false

	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 4.0
	shape.shape = circle
	add_child(shape)

	var vis := ColorRect.new()
	vis.color = Color(1.0, 0.85, 0.2)
	vis.size = Vector2(8, 8)
	vis.position = Vector2(-4, -4)
	add_child(vis)

	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)
	set_collision_mask_value(3, true) # zombies layer (layer index 3 = bit value 4)

func setup(direction: Vector2, dmg: int) -> void:
	_dir = direction.normalized()
	damage = dmg
	rotation = _dir.angle()

func _physics_process(delta: float) -> void:
	position += _dir * speed * delta
	_life -= delta
	if _life <= 0.0:
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area.has_method("take_damage"):
		area.take_damage(damage)
	queue_free()

func _on_body_entered(body: Node) -> void:
	if body.has_method("take_damage"):
		body.take_damage(damage)
	queue_free()
