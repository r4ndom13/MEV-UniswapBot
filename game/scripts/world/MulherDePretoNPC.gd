extends NPC

var _falou: bool = false


func _ready() -> void:
	super._ready()
	nome = "Mulher de Preto"
	# Aparência escura — sobrescreve o cinza padrão do placeholder
	var mesh_node := get_node_or_null("MeshInstance3D")
	if mesh_node:
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color(0.06, 0.05, 0.08)
		mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		mesh_node.material_override = mat


func interact() -> void:
	if DialogSystem.esta_em_dialogo():
		return

	if _falou:
		DialogSystem.iniciar([
			{"falante": "Mulher de Preto", "fala": "..."},
			{"falante": "Mulher de Preto", "fala": "Já falei o que tinha que falar."}
		])
		return

	_falou = true

	var dialogo := [
		{"falante": "Mulher de Preto", "fala": "..."},
		{"falante": "Mulher de Preto", "fala": "Você não devia ter parado."},
		{
			"falante": "Zé",
			"fala": "O que é isso?",
			"escolhas": [
				{
					"texto": "A senhora está bem?",
					"proximo": [
						{"falante": "Mulher de Preto", "fala": "Bem."},
						{"falante": "Mulher de Preto", "fala": "Eu fui embora faz tempo."},
						{"falante": "Mulher de Preto", "fala": "Mas a ponte lembra de mim."}
					]
				},
				{
					"texto": "Preciso passar.",
					"proximo": [
						{"falante": "Mulher de Preto", "fala": "Pode passar."},
						{"falante": "Mulher de Preto", "fala": "Mas não olha pro rio."},
						{"falante": "Mulher de Preto", "fala": "O rio te conhece de nome."}
					]
				}
			]
		}
	]

	DialogSystem.iniciar(dialogo)
