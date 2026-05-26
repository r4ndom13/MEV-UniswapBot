extends CharacterBody3D

# Velocidade de caminhada — deliberadamente lenta para criar tensão
const VELOCIDADE := 3.0
const SENSIBILIDADE_MOUSE := 0.003

@onready var camera: Camera3D = $Camera3D

var gravidade: float = ProjectSettings.get_setting("physics/3d/default_gravity")


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	add_to_group("player")


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * SENSIBILIDADE_MOUSE)
		camera.rotate_x(-event.relative.y * SENSIBILIDADE_MOUSE)
		camera.rotation.x = clamp(
			camera.rotation.x,
			deg_to_rad(-80.0),
			deg_to_rad(80.0)
		)

	# Soltar o mouse durante desenvolvimento
	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _physics_process(delta: float) -> void:
	# Aplica gravidade quando no ar
	if not is_on_floor():
		velocity.y -= gravidade * delta

	# Lê input direcional — WASD mapeado em project.godot
	var input_dir := Input.get_vector(
		"move_left", "move_right",
		"move_forward", "move_back"
	)

	# Converte input 2D para direção 3D relativa à orientação do player
	var direcao := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direcao:
		velocity.x = direcao.x * VELOCIDADE
		velocity.z = direcao.z * VELOCIDADE
	else:
		# Desacelera suavemente ao soltar tecla
		velocity.x = move_toward(velocity.x, 0, VELOCIDADE)
		velocity.z = move_toward(velocity.z, 0, VELOCIDADE)

	move_and_slide()
