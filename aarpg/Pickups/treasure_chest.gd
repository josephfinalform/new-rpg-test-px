class_name TreasureChest
extends PickupBase

@export var heal_amount: int = 3
@export var xp_amount: int = 15


func _ready() -> void:
	lifetime = 0.0
	sfx_path = "res://assets/audio/sfx/treasure_open.wav"
	super._ready()


func _play_collect_feedback() -> void:
	AudioManager.play_sfx_from_path(sfx_path)
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property($Sprite2D, "scale", Vector2(1.5, 1.5), 0.25).set_trans(Tween.TRANS_BACK)
	tween.tween_property($Sprite2D, "modulate:a", 0.0, 0.4)
	tween.chain().tween_callback(queue_free)


func _apply_effect(player: Player) -> void:
	player.heal(heal_amount)
	player.gain_xp(xp_amount)
