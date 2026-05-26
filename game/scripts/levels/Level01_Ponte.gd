extends Node3D

@onready var mulher:    Node          = $MulherDePreto
@onready var horror:    HorrorEventos = $HorrorEventos
@onready var lampiao_c: OmniLight3D   = $Luzes/LampiaoC
@onready var lua_fraca: Light3D       = $Luzes/LuaFraca

@onready var trig_entrada: Area3D = $Gatilhos/TriggerEntrada
@onready var trig_meio:    Area3D = $Gatilhos/TriggerMeio
@onready var trig_fim:     Area3D = $Gatilhos/TriggerFim

# Flags — cada gatilho dispara uma única vez
var _entrada_disparada := false
var _meio_disparado    := false
var _fim_disparado     := false


func _ready() -> void:
	horror.luz_principal = lampiao_c   # lampião central da ponte pisca
	AudioManager.registrar($AudioBase, $AudioTensao)
	TensaoManager.resetar()
	TensaoManager.tensao_mudou.connect(_ao_tensao_mudar)

	trig_entrada.body_entered.connect(_on_entrada)
	trig_meio.body_entered.connect(_on_meio)
	trig_fim.body_entered.connect(_on_fim)

	TransicaoManager.aparecer(1.5)

	# Introdução: orienta o jogador sobre situação e personagem
	await get_tree().create_timer(2.0).timeout
	DialogSystem.iniciar([
		{"falante": "Zé", "fala": "Meia-noite e tanto. Essa estrada vai durar a vida toda."},
		{"falante": "Zé", "fala": "O motor falhou antes da ponte. Desce e vai a pé, Zé."},
		{"falante": "Zé", "fala": "Tem neblina hoje."},
	])


func _ao_tensao_mudar(nivel: int) -> void:
	# Luz da lua some progressivamente (0.04 → 0.01)
	if is_instance_valid(lua_fraca):
		var e := lerpf(0.04, 0.01, nivel / 3.0)
		create_tween().tween_property(lua_fraca, "light_energy", e, 4.0)


# ── Gatilhos narrativos ──────────────────────────────────────────────────────

func _on_entrada(body: Node3D) -> void:
	if _entrada_disparada or not body.is_in_group("player"):
		return
	_entrada_disparada = true
	_sequencia_entrada()


func _sequencia_entrada() -> void:
	TensaoManager.aumentar()
	await get_tree().create_timer(0.6).timeout
	DialogSystem.iniciar([
		{"falante": "Zé", "fala": "A ponte..."},
		{"falante": "Zé", "fala": "Tem alguém lá no meio. Uma mulher."},
		{"falante": "Zé", "fala": "Parada. Olhando pro rio."},
	])


func _on_meio(body: Node3D) -> void:
	if _meio_disparado or not body.is_in_group("player"):
		return
	_meio_disparado = true
	_sequencia_meio()


func _sequencia_meio() -> void:
	# Lampião pisca — a noite avisa
	horror.piscar_luz(3)
	await get_tree().create_timer(1.2).timeout
	if DialogSystem.esta_em_dialogo():
		await DialogSystem.dialogo_encerrado
	DialogSystem.iniciar([
		{"falante": "Zé", "fala": "Ela me viu."},
		{"falante": "Zé", "fala": "Ou... ela sempre soube que eu ia passar."},
	])


func _on_fim(body: Node3D) -> void:
	if _fim_disparado or not body.is_in_group("player"):
		return
	_fim_disparado = true
	_sequencia_fim()


func _sequencia_fim() -> void:
	# Mulher some — sem som, sem aviso
	if is_instance_valid(mulher):
		mulher.queue_free()

	TensaoManager.aumentar()
	await get_tree().create_timer(1.0).timeout

	if DialogSystem.esta_em_dialogo():
		await DialogSystem.dialogo_encerrado

	DialogSystem.iniciar([
		{"falante": "Zé", "fala": "Ela sumiu."},
		{"falante": "Zé", "fala": "Não tem como ter saído andando assim."},
		{"falante": "Zé", "fala": "Não tem."},
		{
			"falante": "Zé",
			"fala": "Continua?",
			"escolhas": [
				{
					"texto": "Atravessa e vai embora.",
					"proximo": [
						{"falante": "Zé", "fala": "Vai. Não olha pra trás."},
						{"falante": "Zé", "fala": "Só não olha."}
					]
				},
				{
					"texto": "Para no meio da ponte.",
					"proximo": [
						{"falante": "Zé",  "fala": "Por que eu parei?"},
						{"falante": "Zé",  "fala": "Devia ir logo."},
						{"falante": "",    "fala": "...o rio faz um barulho diferente aqui."}
					]
				}
			]
		}
	])
	await DialogSystem.dialogo_encerrado
	await get_tree().create_timer(1.0).timeout
	await TransicaoManager.sumir(1.8)
	GameManager.proximo_nivel()
