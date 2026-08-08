class_name GearUp
extends Resource

enum Stat { ATTACK, MAX_HEALTH, SPEED, DASH_COOLDOWN }

@export var display_name: String = "Power Up"
@export var stat: Stat = Stat.ATTACK
@export var amount: int = 1
@export var stat_color: Color = Color(0.5, 0.9, 1.0)
@export_multiline var description: String = ""
