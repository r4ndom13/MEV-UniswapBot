extends CanvasLayer

signal dialogo_encerrado
signal escolha_feita(indice: int)

const MAX_ESCOLHAS := 3

var _em_dialogo: bool = false
var _linhas: Array = []
var _indice: int = 0
var _aguardando_escolha: bool = false

var _panel: Panel
var _falante: Label
var _texto: Label
var _avanca: Label
var _escolhas_box: VBoxContainer
var _botoes: Array[Button] = []


func _ready() -> void:
	layer = 10
	visible = false
	_construir_ui()


func _construir_ui() -> void:
	# Painel no terço inferior da tela
	_panel = Panel.new()
	_panel.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_panel.offset_top = -220.0
	_panel.offset_left = 20.0
	_panel.offset_right = -20.0
	_panel.offset_bottom = -15.0
	add_child(_panel)

	# Margens internas
	var margem := MarginContainer.new()
	margem.set_anchors_preset(Control.PRESET_FULL_RECT)
	margem.add_theme_constant_override("margin_left", 16)
	margem.add_theme_constant_override("margin_right", 16)
	margem.add_theme_constant_override("margin_top", 12)
	margem.add_theme_constant_override("margin_bottom", 12)
	_panel.add_child(margem)

	# Coluna vertical: nome → separador → texto → escolhas → continuar
	var vbox := VBoxContainer.new()
	margem.add_child(vbox)

	_falante = Label.new()
	_falante.name = "FalanteLabel"
	vbox.add_child(_falante)

	vbox.add_child(HSeparator.new())

	_texto = Label.new()
	_texto.name = "TextoLabel"
	_texto.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_texto.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(_texto)

	_escolhas_box = VBoxContainer.new()
	_escolhas_box.name = "EscolhasContainer"
	_escolhas_box.visible = false
	_escolhas_box.add_theme_constant_override("separation", 4)
	vbox.add_child(_escolhas_box)

	for i in MAX_ESCOLHAS:
		var btn := Button.new()
		btn.name = "Escolha%d" % i
		btn.visible = false
		var idx := i
		btn.pressed.connect(func(): _ao_escolher(idx))
		_escolhas_box.add_child(btn)
		_botoes.append(btn)

	_avanca = Label.new()
	_avanca.name = "AvancaLabel"
	_avanca.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_avanca.text = "[ ENTER ]  continuar"
	vbox.add_child(_avanca)


# ── API pública ──────────────────────────────────────────────────────────────

func iniciar(linhas: Array) -> void:
	if _em_dialogo:
		return
	_linhas = linhas
	_indice = 0
	_em_dialogo = true
	visible = true
	_mostrar_linha()


func esta_em_dialogo() -> bool:
	return _em_dialogo


# ── Lógica interna ───────────────────────────────────────────────────────────

func _mostrar_linha() -> void:
	if _indice >= _linhas.size():
		_encerrar()
		return

	var linha: Dictionary = _linhas[_indice]
	_falante.text = linha.get("falante", "")
	_texto.text = linha.get("fala", "")

	var escolhas: Array = linha.get("escolhas", [])
	_aguardando_escolha = escolhas.size() > 0

	if _aguardando_escolha:
		_exibir_escolhas(escolhas)
		_avanca.visible = false
	else:
		_escolhas_box.visible = false
		_avanca.visible = true


func _exibir_escolhas(escolhas: Array) -> void:
	_escolhas_box.visible = true
	for i in MAX_ESCOLHAS:
		var btn: Button = _botoes[i]
		if i < escolhas.size():
			btn.text = escolhas[i].get("texto", "")
			btn.visible = true
		else:
			btn.visible = false


func _ao_escolher(indice: int) -> void:
	if not _aguardando_escolha:
		return
	_aguardando_escolha = false

	emit_signal("escolha_feita", indice)

	var escolhas: Array = _linhas[_indice].get("escolhas", [])
	var proximo: Array = []
	if indice < escolhas.size():
		proximo = escolhas[indice].get("proximo", [])

	if proximo.size() > 0:
		_linhas = proximo
		_indice = 0
		_mostrar_linha()
	else:
		_encerrar()


func _encerrar() -> void:
	_em_dialogo = false
	visible = false
	_linhas = []
	_indice = 0
	emit_signal("dialogo_encerrado")


func _unhandled_input(event: InputEvent) -> void:
	if not _em_dialogo or _aguardando_escolha:
		return
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("interact"):
		get_viewport().set_input_as_handled()
		_indice += 1
		_mostrar_linha()
