extends Control
class_name TouchJoystick

signal direction_changed(dir: Vector2)

@export var base_radius: float = 90.0
@export var knob_radius: float = 42.0

var _touch_index: int = -1
var _origin: Vector2 = Vector2.ZERO
var _knob_pos: Vector2 = Vector2.ZERO
var _active: bool = false

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_process_input(true)

func _draw() -> void:
	if not _active:
		return
	draw_circle(_origin, base_radius, Color(1, 1, 1, 0.12))
	draw_circle(_origin, base_radius, Color(1, 1, 1, 0.35), false, 3.0)
	draw_circle(_knob_pos, knob_radius, Color(1, 1, 1, 0.30))

func _input(event: InputEvent) -> void:
	if Global.game_over:
		return
	if event is InputEventScreenTouch:
		if event.pressed and _touch_index == -1 and event.position.y > get_viewport_rect().size.y * 0.35:
			_touch_index = event.index
			_origin = event.position
			_knob_pos = event.position
			_active = true
			queue_redraw()
		elif not event.pressed and event.index == _touch_index:
			_end_touch()
	elif event is InputEventScreenDrag:
		if event.index == _touch_index:
			_update_knob(event.position)
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed and _touch_index == -1:
				_touch_index = 0
				_origin = event.position
				_knob_pos = event.position
				_active = true
				queue_redraw()
			elif not event.pressed and _touch_index == 0:
				_end_touch()
	elif event is InputEventMouseMotion:
		if _touch_index == 0 and _active:
			_update_knob(event.position)

func _update_knob(pos: Vector2) -> void:
	var offset := pos - _origin
	if offset.length() > base_radius:
		offset = offset.normalized() * base_radius
	_knob_pos = _origin + offset
	var dir := offset / base_radius
	direction_changed.emit(dir)
	queue_redraw()

func _end_touch() -> void:
	_touch_index = -1
	_active = false
	direction_changed.emit(Vector2.ZERO)
	queue_redraw()
