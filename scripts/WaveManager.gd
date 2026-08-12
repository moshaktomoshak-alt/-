extends Node2D
class_name WaveManager

signal wave_started(wave_number: int)
signal wave_cleared(wave_number: int)
signal intermission_tick(seconds_left: float)

var base_target_pos: Vector2 = Vector2.ZERO
var spawn_radius: float = 560.0

var _alive_zombies: int = 0
var _to_spawn: Array = []
var _spawn_timer: float = 0.0
var _intermission: float = 6.0
var _in_intermission: bool = true
var _wave: int = 0

const TYPES := {
	"basic": {"hp": 40, "speed": 62.0, "damage": 6, "scrap": 2, "texture": "res://assets/sprites/zombie_basic.png", "display_scale": 2.0},
	"fast": {"hp": 26, "speed": 105.0, "damage": 5, "scrap": 3, "texture": "res://assets/sprites/zombie_fast.png", "display_scale": 2.0},
	"jumper": {"hp": 55, "speed": 130.0, "damage": 9, "scrap": 4, "texture": "res://assets/sprites/zombie_jumper.png", "display_scale": 1.4},
	"hazmat": {"hp": 140, "speed": 55.0, "damage": 8, "scrap": 6, "texture": "res://assets/sprites/zombie_hazmat.png", "display_scale": 2.0},
	"spitter": {"hp": 45, "speed": 50.0, "damage": 7, "scrap": 5, "ranged": true, "texture": "res://assets/sprites/zombie_spitter.png", "display_scale": 2.0},
	"bomber": {"hp": 30, "speed": 90.0, "damage": 4, "scrap": 5, "explodes": true, "explosion_damage": 34, "texture": "res://assets/sprites/zombie_bomber.png", "display_scale": 2.0},
	"penetrator": {"hp": 260, "speed": 46.0, "damage": 22, "scrap": 10, "texture": "res://assets/sprites/zombie_penetrator.png", "display_scale": 1.3},
	"clawler": {"hp": 340, "speed": 68.0, "damage": 26, "scrap": 12, "texture": "res://assets/sprites/zombie_clawler.png", "display_scale": 1.3},
	"tanker": {"hp": 900, "speed": 34.0, "damage": 40, "scrap": 30, "texture": "res://assets/sprites/zombie_tanker_body.png", "display_scale": 1.8},
}

func _ready() -> void:
	_in_intermission = true
	_intermission = 5.0

func _process(delta: float) -> void:
	if Global.game_over:
		return

	if _in_intermission:
		_intermission -= delta
		intermission_tick.emit(max(_intermission, 0.0))
		if _intermission <= 0.0:
			_start_next_wave()
		return

	if _to_spawn.size() > 0:
		_spawn_timer -= delta
		if _spawn_timer <= 0.0:
			var type_id: String = _to_spawn.pop_back()
			_spawn_zombie(type_id)
			_spawn_timer = 0.55

	if _to_spawn.is_empty() and _alive_zombies <= 0:
		wave_cleared.emit(_wave)
		Global.add_scrap(10 + _wave * 2)
		_in_intermission = true
		_intermission = 7.0

func _start_next_wave() -> void:
	_wave += 1
	Global.set_wave(_wave)
	_in_intermission = false
	_to_spawn = _build_wave_roster(_wave)
	_to_spawn.shuffle()
	_alive_zombies = _to_spawn.size()
	wave_started.emit(_wave)

func _build_wave_roster(wave: int) -> Array:
	var roster: Array = []
	var basic_count := 4 + wave * 2
	for i in basic_count:
		roster.append("basic")
	if wave >= 2:
		for i in range(2 + wave):
			roster.append("fast")
	if wave >= 3:
		for i in range(1 + int(wave / 2)):
			roster.append("jumper")
	if wave >= 4:
		for i in range(1 + int(wave / 3)):
			roster.append("spitter")
	if wave >= 5:
		for i in range(1 + int(wave / 3)):
			roster.append("bomber")
	if wave >= 6:
		for i in range(1 + int(wave / 4)):
			roster.append("hazmat")
	if wave >= 8:
		for i in range(1 + int(wave / 5)):
			roster.append("penetrator")
	if wave >= 10:
		for i in range(int(wave / 6)):
			roster.append("clawler")
	if wave % 5 == 0:
		roster.append("tanker")
	return roster

func _spawn_zombie(type_id: String) -> void:
	var data: Dictionary = TYPES.get(type_id, TYPES["basic"])
	var angle := randf() * TAU
	var spawn_pos := base_target_pos + Vector2(cos(angle), sin(angle)) * spawn_radius
	var z := Zombie.new()
	add_child(z)
	z.setup(data, spawn_pos, base_target_pos)
	z.died.connect(_on_zombie_died)

func _on_zombie_died(_z: Zombie) -> void:
	_alive_zombies -= 1
