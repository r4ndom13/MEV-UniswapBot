extends CanvasLayer

var _overlay: ColorRect


func _ready() -> void:
	layer = 5   # acima do 3D, abaixo do DialogSystem (layer 10)

	_overlay = ColorRect.new()
	_overlay.color = Color.BLACK
	_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_overlay)

	# Começa opaco — cada cena faz seu próprio aparecer()
	_overlay.modulate.a = 1.0


# Fade de preto → transparente (chame no _ready() de cada cena)
func aparecer(duracao: float = 1.2) -> void:
	_overlay.modulate.a = 1.0
	var tween := create_tween()
	tween.tween_property(_overlay, "modulate:a", 0.0, duracao)


# Fade de transparente → preto (aguarda o fade completar antes de retornar)
func sumir(duracao: float = 1.2) -> void:
	var tween := create_tween()
	tween.tween_property(_overlay, "modulate:a", 1.0, duracao)
	await tween.finished
