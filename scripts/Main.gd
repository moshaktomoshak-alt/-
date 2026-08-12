extends Node2D

var player: Player
var wave_manager: WaveManager
var hud: HUD
var joystick: TouchJoystick
var base_sprite: Sprite2D
var world: Node2D

const BASE_POS := Vector2(0, 0)

func _ready() -> void:
	Global.reset_run()
	_build_world()
	_build_base()
	_build_player()
	_build_wave_manager()
	_build_hud()
	_build_joystick()
	_center_camera()

func _build_world() -> void:
	world = Node2D.new()
	world.name = "World"
	add_child(world)

	var bg := ColorRect.new()
	bg.color = Color(0.09, 0.11, 0.08)
	bg.size = Vector2(4000, 4000)
	bg.position = Vector2(-2000, -2000)
	bg.z_index = -10
	world.add_child(bg)

func _build_base() -> void:
	var base_node := StaticBody2D.new()
	base_node.name = "Base"
	base_node.position = BASE_POS
	world.add_child(base_node)

	base_sprite = Sprite2D.new()
	var tex := load("res://assets/sprites/warehouse.png")
	if tex:
		base_sprite.texture = tex
	base_sprite.scale = Vector2(2.6, 2.6)
	base_node.add_child(base_sprite)

	var ring := Node2D.new()
	ring.name = "DefenseRing"
	for i in 8:
		var s := Sprite2D.new()
		var wtex := load("res://assets/sprites/sandbag.png")
		if wtex:
			s.texture = wtex
		var angle := (TAU / 8) * i
		s.position = Vector2(cos(angle), sin(angle)) * 90.0
		s.rotation = angle
		s.scale = Vector2(1.8, 1.8)
		ring.add_child(s)
	base_node.add_child(ring)

func _build_player() -> void:
	player = Player.new()
	player.name = "Player"
	player.global_position = BASE_POS + Vector2(0, -130)
	world.add_child(player)
	player.died.connect(_on_player_died)

func _build_wave_manager() -> void:
	wave_manager = WaveManager.new()
	wave_manager.base_target_pos = BASE_POS
	world.add_child(wave_manager)
	wave_manager.intermission_tick.connect(_on_intermission_tick)
	wave_manager.wave_started.connect(_on_wave_started)

func _build_hud() -> void:
	hud = HUD.new()
	add_child(hud)
	hud.heal_pressed.connect(_on_heal_pressed)
	hud.upgrade_pressed.connect(_on_upgrade_pressed)
	hud.restart_pressed.connect(_on_restart_pressed)

func _build_joystick() -> void:
	joystick = TouchJoystick.new()
	joystick.set_anchors_preset(Control.PRESET_FULL_RECT)
	joystick.direction_changed.connect(func(dir): player.set_move_direction(dir))
	add_child(joystick)

func _center_camera() -> void:
	var cam := Camera2D.new()
	cam.position = BASE_POS
	cam.zoom = Vector2(1.0, 1.0)
	cam.enabled = true
	world.add_child(cam)
	cam.make_current()

func _on_intermission_tick(seconds_left: float) -> void:
	hud.set_intermission_text(seconds_left, true)

func _on_wave_started(_n: int) -> void:
	hud.set_intermission_text(0.0, false)

func _on_heal_pressed() -> void:
	if Global.try_spend_scrap(20):
		Global.heal_base(20)

func _on_upgrade_pressed() -> void:
	if Global.try_spend_scrap(35):
		player.fire_cooldown = max(0.12, player.fire_cooldown * 0.85)
		player.bullet_damage += 4

func _on_player_died() -> void:
	# Player respawns after a short delay instead of ending the run outright;
	# the base itself is the true lose condition.
	await get_tree().create_timer(2.0).timeout
	if not Global.game_over:
		player.hp = player.max_hp
		player.hp_changed.emit(player.hp, player.max_hp)
		player.global_position = BASE_POS + Vector2(0, -130)

func _on_restart_pressed() -> void:
	get_tree().reload_current_scene()
