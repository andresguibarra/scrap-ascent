extends Node2D

# Debug script to check weapon modulation
func _ready():
	print("=== Weapon Modulation Debug ===")
	
	# Check enemies with weapons
	call_deferred("_check_weapon_modulation")

func _check_weapon_modulation():
	var enemies = get_tree().get_nodes_in_group("enemies")
	print("Found enemies: ", enemies.size())
	
	for enemy in enemies:
		if enemy.has_weapon and enemy.weapon_instance:
			var weapon = enemy.weapon_instance
			var sprite = weapon.get_node("Sprite2D")
			print("Enemy T", enemy.tier, " has weapon - Modulation: ", sprite.modulate, " vs Tier Color: ", enemy.get_tier_color())
		else:
			print("Enemy T", enemy.tier, " no weapon")