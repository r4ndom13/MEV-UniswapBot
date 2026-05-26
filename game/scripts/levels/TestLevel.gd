extends Node3D

@onready var viajante:     Node                 = $Viajante
@onready var horror:       HorrorEventos        = $HorrorEventos
@onready var luz:          DirectionalLight3D   = $DirectionalLight3D
@onready var audio_base:   AudioStreamPlayer    = $AudioBase
@onready var audio_tensao: AudioStreamPlayer    = $AudioTensao
@onready var audio_sfx:    AudioStreamPlayer    = $AudioSFX


func _ready() -> void:
	# Conecta o sistema de eventos aos nós desta cena
	horror.luz_principal = luz
	horror.audio_sfx     = audio_sfx
	horror.audio_passos  = audio_base

	# Registra camadas de áudio no AudioManager global
	AudioManager.registrar(audio_base, audio_tensao)

	# Reage a mudanças de tensão (escuridão progressiva)
	TensaoManager.tensao_mudou.connect(_ao_tensao_mudar)

	_agendar_sequencia()


func _agendar_sequencia() -> void:
	# Cada evento dispara num intervalo aleatório dentro de um range
	# Tempos curtos aqui são para TESTE — na fase real serão 2-5 minutos
	_timer(randf_range(8,  14), _evt_passos)
	_timer(randf_range(20, 28), _evt_radio_chia)
	_timer(randf_range(35, 48), _evt_luz_pisca)
	_timer(randf_range(55, 68), _evt_radio_liga)
	_timer(randf_range(80, 95), _evt_vulto)


func _timer(segundos: float, callback: Callable) -> void:
	var t := Timer.new()
	add_child(t)
	t.wait_time = segundos
	t.one_shot = true
	t.timeout.connect(callback)
	t.start()


func _ao_tensao_mudar(nivel: int) -> void:
	# Cena escurece gradualmente conforme tensão sobe (0.15 → 0.02)
	if is_instance_valid(luz):
		var energia_alvo := lerpf(0.15, 0.02, nivel / 3.0)
		var tween := create_tween()
		tween.tween_property(luz, "light_energy", energia_alvo, 4.0)


# ── Eventos de horror ────────────────────────────────────────────────────────

func _evt_passos() -> void:
	horror.passos_distantes()
	await get_tree().create_timer(0.8).timeout
	DialogSystem.iniciar([
		{"falante": "", "fala": "...o que foi isso?"}
	])


func _evt_radio_chia() -> void:
	horror.radio_estatica()


func _evt_luz_pisca() -> void:
	horror.piscar_luz(4)


func _evt_radio_liga() -> void:
	# Aguarda se outro diálogo já estiver aberto
	if DialogSystem.esta_em_dialogo():
		await DialogSystem.dialogo_encerrado

	await get_tree().create_timer(1.5).timeout

	DialogSystem.iniciar([
		{"falante": "",    "fala": "..."},
		{"falante": "Zé",  "fala": "O rádio."},
		{"falante": "Zé",  "fala": "Eu não toquei nele."},
		{"falante": "Zé",  "fala": "Ninguém tocou."},
	])

	await DialogSystem.dialogo_encerrado

	if is_instance_valid(viajante):
		viajante.queue_free()


func _evt_vulto() -> void:
	var jogador := get_node_or_null("Player")
	if not jogador:
		return

	# Spawna atrás e lateral do jogador — basis.z aponta para trás em Godot (-Z = frente)
	var lateral := Vector3(randf_range(-3.0, 3.0), 0.0, 0.0)
	var atras   := jogador.transform.basis.z * 5.0
	var pos     := jogador.global_position + atras + lateral
	pos.y = 0.88

	horror.vulto_aparecer(pos)

	await get_tree().create_timer(2.5).timeout

	if not DialogSystem.esta_em_dialogo():
		DialogSystem.iniciar([
			{"falante": "Zé", "fala": "...alguma coisa passou atrás de mim."},
			{"falante": "Zé", "fala": "Não. Não olha de volta."}
		])
