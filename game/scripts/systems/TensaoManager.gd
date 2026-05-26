extends Node

signal tensao_mudou(nivel: int)

# Níveis: 0=calmo  1=inquieto  2=tenso  3=presença
var nivel: int = 0 : set = _set_nivel


func _set_nivel(novo: int) -> void:
	nivel = clamp(novo, 0, 3)
	emit_signal("tensao_mudou", nivel)


func aumentar() -> void:
	_set_nivel(nivel + 1)


func diminuir() -> void:
	_set_nivel(nivel - 1)


func resetar() -> void:
	_set_nivel(0)
