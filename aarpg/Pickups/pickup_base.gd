class_name PickupBase
extends Area2D

const XP_POPUP = preload("res://aarpg/Effects/floating_text.tscn")
const DEFAULT_SFX = preload("res://assets/audio/sfx/item_pickup.wav")

@export var lifetime: float = 12.0
@export var bob_speed: float = 4.0
@export var bob_amplitude: float = 2.0
@export var bob_base_y: float = -4.0
@export var rotation_speed: float = 0.0

var collected: bool = false
var _bob_time: float = 0.0


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	if lifetime > 0.0:
		create_tween().tween_interval(lifetime).tween_callback(queue_free)


func _process(delta: float) -> void:
	_bob_time += delta
	position.y = bob_base_y + sin(_bob_time * bob_speed) * bob_amplitude
	if rotation_speed != 0.0:
		rotation += delta * rotation_speed


func _on_body_entered(body: Node2D) -> void:
	if collected or not body is Player:
		return
	var player := body as Player
	if player.is_dead:
		return
	collected = true
	set_deferred("monitoring", false)
	_apply_effect(player)
	_play_collect_feedback()


func _apply_effect(_player: Player) -> void:
	pass


func _play_collect_feedback() -> void:
	AudioManager.play_sfx(DEFAULT_SFX)
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.chain().tween_callback(queue_free)


func _spawn_popup(text: String, color: Color, offset: Vector2 = Vector2(0, -10)) -> void:
	var popup := XP_POPUP.instantiate() as Label
	get_parent().add_child(popup)
	popup.text = text
	popup.modulate = color
	popup.global_position = global_position + offset
