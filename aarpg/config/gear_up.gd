class_name GearUp
extends Resource

enum Stat { ATTACK, MAX_HEALTH, SPEED, DASH_COOLDOWN, CRIT_CHANCE, LIFESTEAL, XP_BONUS, ARMOR, THORNS, MAGNET, REGEN, FURY, KNOCKBACK, CRIT_DAMAGE }
enum Rarity { COMMON, UNCOMMON, RARE, EPIC, LEGENDARY }

const RARITY_NAMES: Array[String] = ["Common", "Uncommon", "Rare", "Epic", "Legendary"]
const RARITY_COLORS: Array[Color] = [
	Color(0.72, 0.72, 0.72),
	Color(0.35, 0.85, 0.45),
	Color(0.35, 0.6, 1.0),
	Color(0.75, 0.4, 1.0),
	Color(1.0, 0.6, 0.2),
]

@export var display_name: String = "Power Up"
@export var rarity: Rarity = Rarity.COMMON
@export var stat: Stat = Stat.ATTACK
@export_range(1, 100) var amount: int = 1
@export var stat_color: Color = Color(0.5, 0.9, 1.0)
@export_multiline var description: String = ""


func get_rarity_name() -> String:
	return RARITY_NAMES[rarity]


func get_rarity_color() -> Color:
	return RARITY_COLORS[rarity]
