extends Node

# --- Persistent-ish run state (resets each new game) ---
var scrap: int = 50
var wave_number: int = 0
var base_health: int = 100
var base_max_health: int = 100
var game_over: bool = false
var kills: int = 0

signal scrap_changed(new_value: int)
signal base_health_changed(new_value: int, max_value: int)
signal wave_changed(new_wave: int)
signal game_over_triggered(won_run: bool)

func reset_run() -> void:
	scrap = 50
	wave_number = 0
	base_health = 100
	base_max_health = 100
	game_over = false
	kills = 0

func add_scrap(amount: int) -> void:
	scrap += amount
	scrap_changed.emit(scrap)

func try_spend_scrap(amount: int) -> bool:
	if scrap >= amount:
		scrap -= amount
		scrap_changed.emit(scrap)
		return true
	return false

func damage_base(amount: int) -> void:
	if game_over:
		return
	base_health = max(0, base_health - amount)
	base_health_changed.emit(base_health, base_max_health)
	if base_health <= 0:
		trigger_game_over(false)

func heal_base(amount: int) -> void:
	base_health = min(base_max_health, base_health + amount)
	base_health_changed.emit(base_health, base_max_health)

func set_wave(n: int) -> void:
	wave_number = n
	wave_changed.emit(n)

func add_kill() -> void:
	kills += 1

func trigger_game_over(won_run: bool) -> void:
	game_over = true
	game_over_triggered.emit(won_run)
