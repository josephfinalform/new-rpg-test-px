class_name PlayerHUD extends CanvasLayer

@onready var health_bar: TextureProgressBar = $HealthBar
@onready var health_label: Label = $HealthLabel
@onready var coin_label: Label = $CoinLabel

func _process(_delta: float) -> void:
	var player: Player = get_tree().get_first_node_in_group("player")
	if not player:
		return
	health_bar.max_value = player.max_health
	health_bar.value = player.health
	health_label.text = str(player.health) + "/" + str(player.max_health)
	coin_label.text = "Coins: " + str(player.coins)
