extends Node

const ARQUIVO := "user://save.cfg"

var _cfg     := ConfigFile.new()
var _iniciado := false


func _ready() -> void:
	if FileAccess.file_exists(ARQUIVO):
		if _cfg.load(ARQUIVO) == OK:
			_iniciado = true


# ── Progresso ────────────────────────────────────────────────────────────────

func salvar(nivel: int) -> void:
	_cfg.set_value("progresso", "nivel", nivel)
	_cfg.set_value("progresso", "quando", Time.get_unix_time_from_system())
	_cfg.save(ARQUIVO)
	_iniciado = true


func carregar_nivel() -> int:
	return _cfg.get_value("progresso", "nivel", 0)


func tem_save() -> bool:
	return _iniciado


func apagar_save() -> void:
	_cfg = ConfigFile.new()
	_iniciado = false
	if FileAccess.file_exists(ARQUIVO):
		DirAccess.remove_absolute(ARQUIVO)


# ── Escolhas persistentes ────────────────────────────────────────────────────

func registrar_escolha(chave: String, valor: Variant) -> void:
	_cfg.set_value("escolhas", chave, valor)
	if _iniciado:
		_cfg.save(ARQUIVO)


func pegar_escolha(chave: String, padrao: Variant = null) -> Variant:
	return _cfg.get_value("escolhas", chave, padrao)
