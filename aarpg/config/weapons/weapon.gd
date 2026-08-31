class_name Weapon
extends Resource

enum Effect { NONE, FIRE, FROST, SHOCK }
enum Rarity { COMMON, UNCOMMON, RARE, EPIC, LEGENDARY }

const RARITY_NAMES: Array[String] = ["Common", "Uncommon", "Rare", "Epic", "Legendary"]
const RARITY_COLORS: Array[Color] = [
	Color(0.72, 0.72, 0.72),
	Color(0.35, 0.85, 0.45),
	Color(0.35, 0.6, 1.0),
	Color(0.75, 0.4, 1.0),
	Color(1.0, 0.6, 0.2),
]

@export var display_name: String = "Iron Sword"
@export var rarity: Rarity = Rarity.COMMON
@export_range(0, 100) var damage_bonus: int = 0
@export_range(0.1, 5.0) var cooldown_multiplier: float = 1.0
@export var effect: Effect = Effect.NONE
@export var trail_color: Color = Color(0.85, 0.85, 0.9)
@export_multiline var description: String = ""


func get_rarity_name() -> String:
	return RARITY_NAMES[rarity]


func get_rarity_color() -> Color:
	return RARITY_COLORS[rarity]
