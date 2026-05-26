extends Node
class_name HorrorEventos

# Preenchidos pelo level script em _ready()
var luz_principal: DirectionalLight3D = null
var audio_sfx: AudioStreamPlayer = null
var audio_passos: AudioStreamPlayer = null

var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	_rng.randomize()


# ── Eventos disponíveis ──────────────────────────────────────────────────────

func passos_distantes() -> void:
	if audio_passos and audio_passos.stream:
		audio_passos.play()
	TensaoManager.aumentar()


func radio_estatica() -> void:
	if audio_sfx and audio_sfx.stream:
		audio_sfx.play()
	# Evento leve — não aumenta tensão ainda, só instiga


func piscar_luz(vezes: int = 3) -> void:
	if not is_instance_valid(luz_principal):
		return
	var energia_original := luz_principal.light_energy
	for _i in vezes:
		if not is_instance_valid(luz_principal):
			return
		luz_principal.light_energy = 0.0
		await get_tree().create_timer(_rng.randf_range(0.05, 0.15)).timeout
		if not is_instance_valid(luz_principal):
			return
		luz_principal.light_energy = energia_original
		await get_tree().create_timer(_rng.randf_range(0.08, 0.25)).timeout
	# Fica levemente mais fraca — a noite cobrou um preço
	if is_instance_valid(luz_principal):
		luz_principal.light_energy = energia_original * 0.7
	TensaoManager.aumentar()


func vulto_aparecer(posicao: Vector3) -> void:
	# Figura escura que surge e some em ~1.5s
	var vulto := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = Vector3(0.45, 1.75, 0.2)
	vulto.mesh = mesh

	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.04, 0.04, 0.06)
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	vulto.material_override = mat

	get_parent().add_child(vulto)
	vulto.global_position = posicao

	TensaoManager.aumentar()

	await get_tree().create_timer(1.5).timeout
	if is_instance_valid(vulto):
		vulto.queue_free()
