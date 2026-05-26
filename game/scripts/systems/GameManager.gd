extends Node

const SEQUENCIA := [
	"res://scenes/levels/CabineCaminhao.tscn",
	"res://scenes/levels/Level01_Ponte.tscn",
]

var _nivel := 0


func proximo_nivel() -> void:
	_nivel += 1
	if _nivel >= SEQUENCIA.size():
		_fim_mvp()
		return
	get_tree().change_scene_to_file(SEQUENCIA[_nivel])


func reiniciar() -> void:
	_nivel = 0
	get_tree().change_scene_to_file(SEQUENCIA[0])


func _fim_mvp() -> void:
	await get_tree().create_timer(1.5).timeout
	DialogSystem.iniciar([
		{"falante": "", "fala": "A estrada some na escuridão."},
		{"falante": "", "fala": "Zé chegou."},
		{"falante": "", "fala": "— Fim do MVP —"},
	])
