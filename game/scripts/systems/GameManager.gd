extends Node

# Sequência canônica de capítulos do jogo.
# Para adicionar um capítulo: insira um dicionário antes de "fim".
const CAPITULOS := [
	{ "cena": "res://scenes/levels/CabineCaminhao.tscn", "id": "estrada" },
	{ "cena": "res://scenes/levels/Level01_Ponte.tscn",  "id": "ponte"   },
	{ "cena": "res://scenes/levels/Level02_Venda.tscn",  "id": "venda"   },
	# "mata" e "capela" entram aqui quando prontos
	{ "cena": "res://scenes/levels/Level_Fim.tscn",      "id": "fim"     },
]

var _nivel := 0


func _ready() -> void:
	if SalvamentoManager.tem_save():
		_nivel = SalvamentoManager.carregar_nivel()
		# Save de jogo concluído: recomeça do zero
		if _nivel >= CAPITULOS.size():
			_nivel = 0
			SalvamentoManager.apagar_save()


# Chamado por Main._ready() — abre a cena do capítulo atual
func iniciar() -> void:
	get_tree().change_scene_to_file(CAPITULOS[_nivel]["cena"])


# Chamado pelo nível atual ao terminar — avança e salva checkpoint
func proximo_nivel() -> void:
	_nivel += 1
	SalvamentoManager.salvar(_nivel)
	if _nivel >= CAPITULOS.size():
		_apos_ultimo_capitulo()
		return
	get_tree().change_scene_to_file(CAPITULOS[_nivel]["cena"])


# Vai diretamente a um capítulo pelo id (útil para testes / debug)
func ir_para(id: String) -> void:
	for i in CAPITULOS.size():
		if CAPITULOS[i]["id"] == id:
			_nivel = i
			SalvamentoManager.salvar(i)
			get_tree().change_scene_to_file(CAPITULOS[i]["cena"])
			return
	push_warning("GameManager.ir_para: id '%s' não encontrado." % id)


func nivel_atual() -> int:
	return _nivel


func reiniciar() -> void:
	SalvamentoManager.apagar_save()
	_nivel = 0
	get_tree().change_scene_to_file(CAPITULOS[0]["cena"])


func _apos_ultimo_capitulo() -> void:
	# Segurança: só alcançado se Level_Fim chamar proximo_nivel() por engano
	DialogSystem.iniciar([{"falante": "", "fala": "— Fim —"}])
