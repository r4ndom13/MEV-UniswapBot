extends StaticBody3D
class_name ObjetoInterativo

@export var nome_objeto: String = "Objeto"
@export_multiline var texto: String = ""

# Sinal para o DialogSystem escutar na próxima etapa
signal interagido(nome: String, conteudo: String)


func _ready() -> void:
	add_to_group("interactable")


func interact() -> void:
	emit_signal("interagido", nome_objeto, texto)
	# Placeholder: imprime no console até o DialogSystem existir
	print("[%s]  %s" % [nome_objeto, texto])
