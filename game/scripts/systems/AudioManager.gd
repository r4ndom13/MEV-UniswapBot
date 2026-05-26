extends Node

# Players registrados pelo nível ativo ao carregar
var _camada_base: AudioStreamPlayer = null
var _camada_tensao: AudioStreamPlayer = null


func _ready() -> void:
	TensaoManager.tensao_mudou.connect(_ao_tensao_mudar)


# Chamado pelo level script em _ready()
func registrar(base: AudioStreamPlayer, tensao: AudioStreamPlayer) -> void:
	_camada_base = base
	_camada_tensao = tensao
	_ao_tensao_mudar(TensaoManager.nivel)


func _ao_tensao_mudar(nivel: int) -> void:
	# Volumes em dB: grilos somem, camada de tensão cresce
	match nivel:
		0: _fade(0.0,   -80.0)
		1: _fade(-3.0,  -20.0)
		2: _fade(-8.0,  -10.0)
		3: _fade(-14.0,  -3.0)


func _fade(base_db: float, tensao_db: float) -> void:
	var tween := create_tween()
	if is_instance_valid(_camada_base):
		tween.tween_property(_camada_base,  "volume_db", base_db,   2.0)
	if is_instance_valid(_camada_tensao):
		tween.parallel().tween_property(_camada_tensao, "volume_db", tensao_db, 2.0)
