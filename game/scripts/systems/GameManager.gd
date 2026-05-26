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
	# Tela preta (TransicaoManager layer 5) fica visível.
	# O diálogo (DialogSystem layer 10) aparece por cima dela.
	await get_tree().create_timer(1.2).timeout
	DialogSystem.iniciar([
		{"falante": "", "fala": "A estrada some na escuridão."},
		{"falante": "", "fala": "Zé chegou em Pedra Branca. Antes do amanhecer."},
		{"falante": "", "fala": "Mas a ponte ficou com ele. Ficou com a memória do rio."},
		{"falante": "", "fala": "— Fim do Vertical Slice —"},
	])
