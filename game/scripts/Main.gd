extends Node

func _ready() -> void:
	# Ponto de entrada do jogo.
	# GameManager._ready() já rodou (autoload) e carregou o save.
	# Aqui só pedimos para ele carregar a cena correta.
	GameManager.iniciar()
