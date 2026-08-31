class_name Armor
extends Resource

enum Rarity { COMMON, UNCOMMON, RARE, EPIC, LEGENDARY }

const RARITY_NAMES: Array[String] = ["Common", "Uncommon", "Rare", "Epic", "Legendary"]
const RARITY_COLORS: Array[Color] = [
	Color(0.72, 0.72, 0.72),
	Color(0.35, 0.85, 0.45),
	Color(0.35, 0.6, 1.0),
	Color(0.75, 0.4, 1.0),
	Color(1.0, 0.6, 0.2),
]

@export var display_name: String = "Cloth Armor"
@export var rarity: Rarity = Rarity.COMMON
@export_range(0, 100) var damage_reduction: int = 0
@export_range(0.0, 1.0) var damage_reduction_ratio: float = 0.0
@export_range(0.5, 2.0) var speed_multiplier: float = 1.0
@export var armor_color: Color = Color(0.4, 0.8, 1.0)
@export_multiline var description: String = ""

@export_group("Advanced Stats")
@export_range(1, 10) var armor_tier: int = 1
@export_range(0.5, 3.0) var xp_multiplier: float = 1.0
@export_range(0.5, 2.0) var dash_cooldown_multiplier: float = 1.0
@export_range(0.5, 2.0) var move_speed_multiplier: float = 1.0


func get_rarity_name() -> String:
	return RARITY_NAMES[rarity]


func get_rarity_color() -> Color:
	return RARITY_COLORS[rarity]
