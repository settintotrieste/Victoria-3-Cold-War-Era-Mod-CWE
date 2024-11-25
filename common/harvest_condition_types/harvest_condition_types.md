harvest_condition_type_key = {
	# under what condition does the state currently being checked possibly get this event
	trigger = { trigger }

	# if the current game time is applicable for this harvest condition, default - yes
	time = { trigger }
	
	# Can be repeated. The current harvest condition cannot spawn in a state region that already has any of the listed other conditions
	incompatible_with = other_harvest_condition_type_key

	# up to what distance from this state does the event also apply. 0 = only epicenter, 1 = direct neighbors, etc
	range = {
		integer_range = {
			min = 0
			max = 2
		}
	}
	
	# how long the event will last in weeks
	duration = {
		fixed_range = {
			min = 5
			max = 10
		}
	}

	# whatever modifiers we want to give the occurrence
	modifier = { modifier }

	# Multiplier to the numerical effects defined in modifier
	intensity = {
		fixed_range = {
			min = 0.5
			max = 4
		}
	}

	# If the event is applicable, what is the chance of it triggering?
	chance = { value }

	color = { R G B }
	icon = <texture>

	# Which graphics to apply to the affected map provinces, default - none
	graphics = none|drought|flood|frost|wildfire 

	# Which terrain types this condition is not graphically applicable
	incompatible_terrain = { terrain_key, ... }

	# Which texture to use as a pattern in the map mode, default - none
	map_texture = <texture>
}
