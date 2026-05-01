ship_type_key = {
	modifier = { modifier }

	# Which group the ship type belongs to
	ship_group = <ship group key>

	# Goods cost for a ship when built
	construction_goods = { modifier }

	# Goods cost for a ship when consuming materiel
	materiel_goods = { modifier }

	# The modifiers that are applied when a ship exceeds its maximum distance to a port
	distance_to_port_modifier = { modifier }

	# [Optional] Required technologies to construct the ship type. If multiple entries are specified, either one of them is required
	unlocking_technologies = { <technology_key> ... }

	# [Optional] If set to no, disables ship modifications for this ship type. Defaults to yes.
	use_modifications = yes|no

	# The base cost to construct this ship type, not affected by modification levels.
	base_construction_cost = fixed_point

	# [Optional] The variable cost to construct a ship of this type based is multiplied by the total number of modification levels.
	modification_construction_cost = fixed_point
	
	# Optional multiplier on the perceived combat power of a ship, primarily used by the AI to evaluate the combat prowess of one ship vs another, default 1.0
	combat_power_multiplier = x

	icon = <texture>

	# [Default = 1] How important is this ship type to build for AI
	# root - country
	ai_weight = fixed_point

	# The modification slots and their configurations, each slot should have atleast one modification and all slots marked as required should be present
	modifications = {
		<ship_modification_slot_key> = {
			<ship_modification_key>
			<ship_modification_key>
			...
		}
		...
	}

	# [Optional] Default modification per slot. If not specified SHIP_TEMPLATE_DEFAULT_MODIFICATION_LEVEL will be used instead
	default_modifications = {
		<ship_modification_slot_key> = <ship_modification_key>
		...
	}
}
