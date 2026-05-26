extends NPC

var _ja_falou: bool = false


func _ready() -> void:
	super._ready()
	nome = "Viajante"


func interact() -> void:
	if DialogSystem.esta_em_dialogo():
		return

	# Segunda interação — o Viajante já está inquieto
	if _ja_falou:
		DialogSystem.iniciar([
			{"falante": "Viajante", "fala": "...vai embora, moço."},
			{"falante": "Viajante", "fala": "Você não devia ter parado aqui."}
		])
		return

	_ja_falou = true

	var dialogo := [
		{"falante": "Viajante", "fala": "Boa noite... que susto você me deu."},
		{"falante": "Viajante", "fala": "Você tá sozinho nessa estrada a essa hora?"},
		{
			"falante": "Viajante",
			"fala": "Posso te dizer uma coisa?",
			"escolhas": [
				{
					"texto": "Tem perigo nessa estrada?",
					"proximo": [
						{"falante": "Viajante", "fala": "Perigo?"},
						{"falante": "Viajante", "fala": "Rapaz, aqui não é lugar pra ficar depois das dez. Nunca foi."},
						{"falante": "Viajante", "fala": "Tem coisa nessa estrada que nem padre resolve."}
					]
				},
				{
					"texto": "O que você tá fazendo aqui?",
					"proximo": [
						{"falante": "Viajante", "fala": "Eu?"},
						{"falante": "Viajante", "fala": "Tô indo embora. Já devia ter ido faz muito tempo."},
						{"falante": "Viajante", "fala": "...Não pergunta mais nada. Pelo amor de Deus."}
					]
				}
			]
		}
	]

	DialogSystem.iniciar(dialogo)
