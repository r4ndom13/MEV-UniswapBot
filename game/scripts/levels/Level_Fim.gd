extends NivelBase


func _ready() -> void:
	# Tela permanece preta (TransicaoManager não é chamado para aparecer).
	# O diálogo surge diretamente sobre o fundo escuro.
	await get_tree().create_timer(1.5).timeout
	_mostrar_final()


func _mostrar_final() -> void:
	var parou_na_ponte: bool = \
		SalvamentoManager.pegar_escolha("ponte_resultado", "") == "parou"

	var linhas: Array
	if parou_na_ponte:
		linhas = [
			{"falante": "", "fala": "Zé chegou em Pedra Branca com o sol rompendo o horizonte."},
			{"falante": "", "fala": "Nunca mais passou pela ponte do Ribeirão Fundo."},
			{"falante": "", "fala": "Mas às vezes, no silêncio da noite, ele ouve o rio."},
			{"falante": "", "fala": "E sabe que o rio ainda lembra o nome dele."},
		]
	else:
		linhas = [
			{"falante": "", "fala": "Zé chegou em Pedra Branca com o sol rompendo o horizonte."},
			{"falante": "", "fala": "Nunca soube quem era a figura no acostamento."},
			{"falante": "", "fala": "Nunca quis saber."},
			{"falante": "", "fala": "Algumas perguntas ficam melhor sem resposta."},
		]

	linhas.append({
		"falante": "",
		"fala": "— Os Mortos da Estrada Velha —",
		"escolhas": [
			{
				"texto": "Jogar novamente.",
				"proximo": []
			}
		]
	})

	DialogSystem.escolha_feita.connect(_ao_escolher, CONNECT_ONE_SHOT)
	DialogSystem.iniciar(linhas)


func _ao_escolher(_idx: int) -> void:
	GameManager.reiniciar()
