extends CanvasLayer

@onready var overlay: Control = $Overlay


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	overlay.visible = false


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_toggle_pause()


func _toggle_pause() -> void:
	if not get_tree().current_scene is Level:
		return
	get_tree().paused = not get_tree().paused
	overlay.visible = get_tree().paused
