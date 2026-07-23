class_name DeathState
extends State

func enter() -> void:
	player.velocity = Vector2.ZERO
	player.hitbox_area.monitoring = false
	player.attack_pivot.visible = false
	player.hit_flash_timer.stop()
	player.sprite.modulate = Color.WHITE

func process(_delta: float) -> State:
	return null

func physics(_delta: float) -> State:
	return null
