extends CanvasLayer
class_name HUD

var hp_label: Label
var scrap_label: Label
var wave_label: Label
var intermission_label: Label
var game_over_panel: Control
var game_over_label: Label
var restart_button: Button
var heal_button: Button
var upgrade_button: Button

signal heal_pressed()
signal upgrade_pressed()
signal restart_pressed()

func _ready() -> void:
	layer = 10
	_build_ui()
	Global.base_health_changed.connect(_on_base_health_changed)
	Global.scrap_changed.connect(_on_scrap_changed)
	Global.wave_changed.connect(_on_wave_changed)
	Global.game_over_triggered.connect(_on_game_over)

func _build_ui() -> void:
	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_TOP_WIDE)
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_top", 20)
	margin.add_theme_constant_override("margin_right", 20)
	add_child(margin)

	var top_row := HBoxContainer.new()
	top_row.add_theme_constant_override("separation", 24)
	margin.add_child(top_row)

	hp_label = Label.new()
	hp_label.text = "Base HP: 100/100"
	hp_label.add_theme_font_size_override("font_size", 22)
	top_row.add_child(hp_label)

	scrap_label = Label.new()
	scrap_label.text = "Scrap: 50"
	scrap_label.add_theme_font_size_override("font_size", 22)
	top_row.add_child(scrap_label)

	wave_label = Label.new()
	wave_label.text = "Wave: 0"
	wave_label.add_theme_font_size_override("font_size", 22)
	top_row.add_child(wave_label)

	intermission_label = Label.new()
	intermission_label.set_anchors_preset(Control.PRESET_CENTER_TOP)
	intermission_label.position = Vector2(-140, 70)
	intermission_label.add_theme_font_size_override("font_size", 26)
	add_child(intermission_label)

	var bmargin := MarginContainer.new()
	bmargin.add_theme_constant_override("margin_right", 20)
	bmargin.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	bmargin.position.y -= 130
	add_child(bmargin)

	var bottom_row := HBoxContainer.new()
	bottom_row.add_theme_constant_override("separation", 16)
	bottom_row.alignment = BoxContainer.ALIGNMENT_END
	bmargin.add_child(bottom_row)

	heal_button = Button.new()
	heal_button.text = "Repair Base (20 scrap)"
	heal_button.pressed.connect(func(): heal_pressed.emit())
	bottom_row.add_child(heal_button)

	upgrade_button = Button.new()
	upgrade_button.text = "Upgrade Fire Rate (35 scrap)"
	upgrade_button.pressed.connect(func(): upgrade_pressed.emit())
	bottom_row.add_child(upgrade_button)

	game_over_panel = ColorRect.new()
	game_over_panel.color = Color(0, 0, 0, 0.75)
	game_over_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	game_over_panel.visible = false
	add_child(game_over_panel)

	var center := VBoxContainer.new()
	center.set_anchors_preset(Control.PRESET_CENTER)
	center.alignment = BoxContainer.ALIGNMENT_CENTER
	game_over_panel.add_child(center)

	game_over_label = Label.new()
	game_over_label.text = "GAME OVER"
	game_over_label.add_theme_font_size_override("font_size", 40)
	game_over_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	center.add_child(game_over_label)

	restart_button = Button.new()
	restart_button.text = "Restart"
	restart_button.custom_minimum_size = Vector2(200, 60)
	restart_button.pressed.connect(func(): restart_pressed.emit())
	center.add_child(restart_button)

func _on_base_health_changed(new_value: int, max_value: int) -> void:
	hp_label.text = "Base HP: %d/%d" % [new_value, max_value]

func _on_scrap_changed(new_value: int) -> void:
	scrap_label.text = "Scrap: %d" % new_value

func _on_wave_changed(n: int) -> void:
	wave_label.text = "Wave: %d" % n

func set_intermission_text(seconds_left: float, in_intermission: bool) -> void:
	if in_intermission:
		intermission_label.text = "Next wave in %d..." % int(ceil(seconds_left))
	else:
		intermission_label.text = ""

func _on_game_over(won_run: bool) -> void:
	game_over_panel.visible = true
	game_over_label.text = "BASE DESTROYED\nKills: %d  |  Wave reached: %d" % [Global.kills, Global.wave_number]
