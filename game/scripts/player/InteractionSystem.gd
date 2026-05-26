extends Node

# Alcance máximo do raycast em metros
const ALCANCE := 2.5

@onready var raycast: RayCast3D = $"../Camera3D/RayCast3D"
@onready var prompt: Label = $"../HUD/PromptLabel"


func _process(_delta: float) -> void:
	var alvo := _pegar_interagivel()
	prompt.visible = alvo != null


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		var alvo := _pegar_interagivel()
		if alvo and alvo.has_method("interact"):
			alvo.interact()


func _pegar_interagivel() -> Node:
	if raycast.is_colliding():
		var corpo := raycast.get_collider()
		if corpo != null and corpo.is_in_group("interactable"):
			return corpo
	return null
