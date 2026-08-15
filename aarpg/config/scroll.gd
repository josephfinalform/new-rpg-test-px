class_name Scroll
extends Resource

enum Kind { XP_PARCHMENT, LEVEL_TOME }

@export var display_name: String = "XP Scroll"
@export var kind: Kind = Kind.XP_PARCHMENT
@export var xp_amount: int = 15
@export var respects_xp_multiplier: bool = true
@export var levels_granted: int = 1
@export var scroll_color: Color = Color(0.85, 0.75, 0.55)
@export_multiline var description: String = ""
