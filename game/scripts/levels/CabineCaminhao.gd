extends Node3D

const VELOCIDADE_ESTRADA := 8.0
const DURACAO            := 60.0   # duração da viagem em segundos
const COMPRIMENTO_BLOCO  := 25.0
const N_BLOCOS           := 3
const TOTAL_LOOP         := COMPRIMENTO_BLOCO * N_BLOCOS   # 75 m

@onready var horror:       HorrorEventos     = $HorrorEventos
@onready var farol:        SpotLight3D       = $Luzes/Farol
@onready var audio_base:   AudioStreamPlayer = $AudioBase
@onready var audio_tensao: AudioStreamPlayer = $AudioTensao

var _segmentos: Array[MeshInstance3D] = []
var _arvores:   Array[MeshInstance3D] = []
var _viajando  := true
var _chegou    := false
var _progresso := 0.0
var _rng       := RandomNumberGenerator.new()

var _mat_asfalto: StandardMaterial3D
var _mat_terra:   StandardMaterial3D
var _mat_arvore:  StandardMaterial3D


func _ready() -> void:
	_rng.randomize()
	horror.luz_principal = farol
	AudioManager.registrar(audio_base, audio_tensao)
	TensaoManager.resetar()
	TensaoManager.tensao_mudou.connect(_ao_tensao_mudar)

	_criar_materiais()
	_criar_estrada()
	_criar_arvores()

	TransicaoManager.aparecer(1.5)

	await get_tree().create_timer(2.5).timeout
	DialogSystem.iniciar([
		{"falante": "Zé", "fala": "Três horas da manhã. Motor pegando, graças a Deus."},
		{"falante": "Zé", "fala": "Ainda falta uns trinta km pra chegar em Pedra Branca."},
		{"falante": "Zé", "fala": "Essa estrada não tem fim."},
	])

	_agendar_eventos()


func _process(delta: float) -> void:
	if not _viajando:
		return

	_progresso += delta / DURACAO
	if _progresso >= 1.0 and not _chegou:
		_chegou = true
		_viajando = false
		_chegar()
		return

	_rolar_estrada(delta)


func _rolar_estrada(delta: float) -> void:
	var deslocamento := VELOCIDADE_ESTRADA * delta

	for seg in _segmentos:
		if not is_instance_valid(seg):
			continue
		seg.position.z += deslocamento
		if seg.position.z > COMPRIMENTO_BLOCO:
			seg.position.z -= TOTAL_LOOP

	for arv in _arvores:
		if not is_instance_valid(arv):
			continue
		arv.position.z += deslocamento
		if arv.position.z > COMPRIMENTO_BLOCO * 0.5:
			arv.position.z -= TOTAL_LOOP


# ── Criação de geometria ─────────────────────────────────────────────────────

func _criar_materiais() -> void:
	_mat_asfalto = StandardMaterial3D.new()
	_mat_asfalto.albedo_color = Color(0.08, 0.08, 0.09)

	_mat_terra = StandardMaterial3D.new()
	_mat_terra.albedo_color = Color(0.15, 0.12, 0.09)

	_mat_arvore = StandardMaterial3D.new()
	_mat_arvore.albedo_color = Color(0.06, 0.10, 0.05)
	_mat_arvore.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED


func _criar_estrada() -> void:
	for i in N_BLOCOS:
		var seg := MeshInstance3D.new()
		var mesh := BoxMesh.new()
		mesh.size = Vector3(4.0, 0.2, COMPRIMENTO_BLOCO)
		seg.mesh = mesh
		seg.material_override = _mat_asfalto
		seg.position = Vector3(0, -0.1, -COMPRIMENTO_BLOCO * i)
		add_child(seg)
		_segmentos.append(seg)

		var esq := MeshInstance3D.new()
		var mesh_esq := BoxMesh.new()
		mesh_esq.size = Vector3(3.0, 0.15, COMPRIMENTO_BLOCO)
		esq.mesh = mesh_esq
		esq.material_override = _mat_terra
		esq.position = Vector3(-3.5, -0.125, -COMPRIMENTO_BLOCO * i)
		add_child(esq)
		_segmentos.append(esq)

		var dir := MeshInstance3D.new()
		var mesh_dir := BoxMesh.new()
		mesh_dir.size = Vector3(3.0, 0.15, COMPRIMENTO_BLOCO)
		dir.mesh = mesh_dir
		dir.material_override = _mat_terra
		dir.position = Vector3(3.5, -0.125, -COMPRIMENTO_BLOCO * i)
		add_child(dir)
		_segmentos.append(dir)


func _criar_arvores() -> void:
	for i in 12:
		var arv := MeshInstance3D.new()
		var mesh := BoxMesh.new()
		var alt := _rng.randf_range(5.0, 10.0)
		mesh.size = Vector3(1.5, alt, 1.5)
		arv.mesh = mesh
		arv.material_override = _mat_arvore

		var lado := 1.0 if i % 2 == 0 else -1.0
		var x := lado * _rng.randf_range(4.5, 8.0)
		var z := _rng.randf_range(-TOTAL_LOOP, 0.0)
		arv.position = Vector3(x, alt * 0.5 - 0.1, z)
		add_child(arv)
		_arvores.append(arv)


# ── Tensão → farol escurece ──────────────────────────────────────────────────

func _ao_tensao_mudar(nivel: int) -> void:
	if is_instance_valid(farol):
		var e := lerpf(3.0, 0.8, nivel / 3.0)
		create_tween().tween_property(farol, "light_energy", e, 3.0)


# ── Eventos narrativos ───────────────────────────────────────────────────────

func _agendar_eventos() -> void:
	# Cinco eventos distribuídos em 60s, com variação aleatória de ~6s cada
	_timer(_rng.randf_range(8.0,  13.0), _evt_radio)
	_timer(_rng.randf_range(18.0, 24.0), _evt_luz_distante)
	_timer(_rng.randf_range(30.0, 36.0), _evt_batida)
	_timer(_rng.randf_range(42.0, 48.0), _evt_vulto_estrada)
	_timer(_rng.randf_range(52.0, 57.0), _evt_figura_acostamento)


func _timer(segundos: float, callback: Callable) -> void:
	await get_tree().create_timer(segundos).timeout
	if not _chegou:
		callback.call()


func _evt_radio() -> void:
	TensaoManager.aumentar()
	if DialogSystem.esta_em_dialogo():
		await DialogSystem.dialogo_encerrado
	DialogSystem.iniciar([
		{"falante": "Zé", "fala": "O rádio chiou. Ninguém transmite a essa hora."},
		{"falante": "Zé", "fala": "Voz de mulher, talvez. Não deu pra entender."},
	])


func _evt_luz_distante() -> void:
	if DialogSystem.esta_em_dialogo():
		await DialogSystem.dialogo_encerrado
	DialogSystem.iniciar([
		{"falante": "Zé", "fala": "Tem uma luz lá na frente. Na beira da estrada."},
		{"falante": "Zé", "fala": "Sumiu."},
	])
	TensaoManager.aumentar()


func _evt_batida() -> void:
	_viajando = false
	horror.piscar_luz(2)
	await get_tree().create_timer(1.2).timeout

	if DialogSystem.esta_em_dialogo():
		await DialogSystem.dialogo_encerrado

	DialogSystem.iniciar([
		{"falante": "Zé", "fala": "Que foi isso? Alguma coisa bateu no teto."},
		{"falante": "Zé", "fala": "Galho, deve ter sido galho."},
		{"falante": "Zé", "fala": "Tem galho aqui no meio da estrada?"},
	])
	await DialogSystem.dialogo_encerrado
	_viajando = true


func _evt_vulto_estrada() -> void:
	if DialogSystem.esta_em_dialogo():
		await DialogSystem.dialogo_encerrado
	TensaoManager.aumentar()
	DialogSystem.iniciar([
		{"falante": "Zé", "fala": "Tem alguém na estrada."},
		{"falante": "Zé", "fala": "..."},
		{"falante": "Zé", "fala": "Não tinha ninguém. O farol iluminou o vazio."},
	])


func _evt_figura_acostamento() -> void:
	_viajando = false
	await get_tree().create_timer(0.5).timeout

	if DialogSystem.esta_em_dialogo():
		await DialogSystem.dialogo_encerrado

	TensaoManager.aumentar()
	DialogSystem.iniciar([
		{"falante": "Zé", "fala": "Tem uma pessoa no acostamento. Parada."},
		{
			"falante": "Zé",
			"fala": "Para ou passa?",
			"escolhas": [
				{
					"texto": "Para o caminhão.",
					"proximo": [
						{"falante": "Zé", "fala": "Desacelerou. Olhou pelo espelho."},
						{"falante": "Zé", "fala": "Não tinha mais ninguém lá."},
						{"falante": "Zé", "fala": "Acelerou de novo. O coração tá na garganta."},
					]
				},
				{
					"texto": "Passa direto.",
					"proximo": [
						{"falante": "Zé", "fala": "Não olhou. Pisou fundo."},
						{"falante": "Zé", "fala": "O que você não vê não te assusta."},
						{"falante": "Zé", "fala": "É o que Zé queria acreditar."},
					]
				}
			]
		}
	])
	await DialogSystem.dialogo_encerrado
	_viajando = true


# ── Chegada na ponte ─────────────────────────────────────────────────────────

func _chegar() -> void:
	if DialogSystem.esta_em_dialogo():
		await DialogSystem.dialogo_encerrado

	DialogSystem.iniciar([
		{"falante": "Zé", "fala": "A ponte do Ribeirão Fundo."},
		{"falante": "Zé", "fala": "Motor falhou de novo. Vai a pé daqui."},
	])
	await DialogSystem.dialogo_encerrado
	await get_tree().create_timer(0.8).timeout
	await TransicaoManager.sumir(1.5)
	GameManager.proximo_nivel()
