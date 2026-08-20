extends CanvasLayer

signal dialogue_started(dialogue: Dialogue)
signal dialogue_finished

const TYPE_SPEED := 0.03
const SFX_OPEN = preload("res://assets/audio/sfx/lever_01.wav")
const SFX_CLOSE = preload("res://assets/audio/sfx/lever_02.wav")

var active_dialogue: Dialogue = null
var _line_index: int = 0
var _typewriter_chars: int = 0
var _typewriter_timer: float = 0.0
var _resume_after_close: bool = true
var _npcs: Array[NPC] = []

@onready var panel: PanelContainer = $Panel
@onready var speaker_label: Label = $Panel/MarginContainer/VBoxContainer/SpeakerLabel
@onready var text_label: Label = $Panel/MarginContainer/VBoxContainer/TextLabel
@onready var hint_label: Label = $Panel/MarginContainer/VBoxContainer/HintLabel


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	panel.visible = false


func register_npc(npc: NPC) -> void:
	if npc not in _npcs:
		_npcs.append(npc)


func unregister_npc(npc: NPC) -> void:
	_npcs.erase(npc)


func _unhandled_input(event: InputEvent) -> void:
	if active_dialogue != null:
		if event.is_action_pressed("interact") or event.is_action_pressed("ui_cancel"):
			_advance_or_close()
			get_viewport().set_input_as_handled()
		return
	if not event.is_action_pressed("interact"):
		return
	var npc := _find_npc_in_range()
	if npc:
		open_dialogue(npc)
		get_viewport().set_input_as_handled()


func _find_npc_in_range() -> NPC:
	for npc in _npcs:
		if is_instance_valid(npc) and npc.player_in_range:
			return npc
	return null


func open_dialogue(npc: NPC) -> void:
	if active_dialogue != null or npc == null or not npc.has_dialogue():
		return
	active_dialogue = npc.dialogue
	_line_index = 0
	speaker_label.text = active_dialogue.npc_name
	speaker_label.add_theme_color_override("font_color", active_dialogue.npc_color)
	hint_label.text = "[E] continue"
	_resume_after_close = not get_tree().paused
	panel.visible = true
	_start_typewriter()
	get_tree().paused = true
	AudioManager.play_sfx(SFX_OPEN)
	dialogue_started.emit(active_dialogue)


func _process(delta: float) -> void:
	if active_dialogue == null:
		return
	_typewriter_timer += delta
	if _typewriter_chars >= _current_line().length():
		return
	while _typewriter_timer >= TYPE_SPEED and _typewriter_chars < _current_line().length():
		_typewriter_timer -= TYPE_SPEED
		_typewriter_chars += 1
	text_label.text = _current_line().substr(0, _typewriter_chars)


func _current_line() -> String:
	return active_dialogue.lines[_line_index]


func _typewriter_done() -> bool:
	return _typewriter_chars >= _current_line().length()


func _start_typewriter() -> void:
	_typewriter_chars = 0
	_typewriter_timer = 0.0
	text_label.text = ""


func _advance_or_close() -> void:
	if active_dialogue == null:
		return
	if not _typewriter_done():
		_typewriter_chars = _current_line().length()
		text_label.text = _current_line()
		return
	if _line_index < active_dialogue.lines.size() - 1:
		_line_index += 1
		_start_typewriter()
		hint_label.text = "[E] close" if _line_index >= active_dialogue.lines.size() - 1 else "[E] continue"
	else:
		_close_dialogue()


func _close_dialogue() -> void:
	active_dialogue = null
	panel.visible = false
	if _resume_after_close:
		get_tree().paused = false
	AudioManager.play_sfx(SFX_CLOSE)
	dialogue_finished.emit()
