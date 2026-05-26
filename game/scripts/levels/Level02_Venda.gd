extends NivelBase

@onready var audio_base:   AudioStreamPlayer = $AudioBase
@onready var audio_tensao: AudioStreamPlayer = $AudioTensao

var _avancando := false


func _ready() -> void:
	AudioManager.registrar(audio_base, audio_tensao)
	TensaoManager.resetar()
	TransicaoManager.aparecer(1.5)

	await get_tree().create_timer(2.0).timeout
	_intro()


func _intro() -> void:
	var parou_na_ponte: bool = \
		SalvamentoManager.pegar_escolha("ponte_resultado", "") == "parou"

	if parou_na_ponte:
		DialogSystem.iniciar([
			{"falante": "Zé", "fala": "A ponte não sai da cabeça."},
			{"falante": "Zé", "fala": "Uma venda adiante. Luz acesa às três da manhã."},
			{"falante": "Zé", "fala": "Quem está acordado a essa hora?"},
		])
	else:
		DialogSystem.iniciar([
			{"falante": "Zé", "fala": "Passou rápido. Bem feito, Zé."},
			{"falante": "Zé", "fala": "Uma venda adiante. Luz acesa às três da manhã."},
			{"falante": "Zé", "fala": "Estranha essa luz."},
		])


# ── Placeholder ──────────────────────────────────────────────────────────────
# Pressione E longe de qualquer objeto para avançar ao próximo capítulo.
# Remova este bloco quando a cena estiver completa com seus próprios gatilhos.

func _unhandled_input(event: InputEvent) -> void:
	if _avancando or DialogSystem.esta_em_dialogo():
		return
	if event.is_action_pressed("interact"):
		_avancando = true
		await avancar()
