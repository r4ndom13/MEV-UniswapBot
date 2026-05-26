extends Node3D

# Referência ao Viajante para o evento de terror
@onready var viajante: Node = $Viajante


func _ready() -> void:
	# O rádio vai ligar sozinho 20 segundos depois de entrar na cena
	var timer := Timer.new()
	add_child(timer)
	timer.wait_time = 20.0
	timer.one_shot = true
	timer.timeout.connect(_evento_radio_liga)
	timer.start()


func _evento_radio_liga() -> void:
	# Pausa dramática antes do monólogo
	await get_tree().create_timer(1.5).timeout

	var mono := [
		{"falante": "",    "fala": "..."},
		{"falante": "Zé",  "fala": "O rádio."},
		{"falante": "Zé",  "fala": "Eu não toquei nele."},
		{"falante": "Zé",  "fala": "Ninguém tocou."},
	]

	DialogSystem.iniciar(mono)

	# Aguarda o jogador fechar o diálogo
	await DialogSystem.dialogo_encerrado

	# O Viajante some — sem explicação
	if is_instance_valid(viajante):
		viajante.queue_free()
