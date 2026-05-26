extends StaticBody3D
class_name NPC

@export var nome: String = "Desconhecido"


func _ready() -> void:
	add_to_group("interactable")


func interact() -> void:
	pass
