﻿# Route graphics type is used for generating entity caravans along the spline

example_route_graphics_type = {		# Route graphics type key
	valid_spline_styles = "dirtroad"# Style specifies on which spline styles those caravans can traverse should refer to ../gfx/map/spline_styles key
	
	speed = 0.5						# Speed is how fast the caravan of this type is moving
	min_caravan_distance = 0.5		# Min distance between caravans on the spline system
	routes_to_caravans_ratio = 1    # by default one, max limit in comparison to stripes of given type
	max_count = 20					# Max count is max amount of those caravans shown on the map
	max_path_length = 5				# Max amount of sequential splines entity can traverse
	path_generation_mode = <land/naval> # Type of path generation for entities <land> by default

	# [Default = always yes] Trigger to determine if the route graphics type is possible at all for country scope and 'state' flag
	possible = {}

	# [Optional] List of possible tags that entities can have
	tags = {
		<tag_name> = {
			# [Default = always yes] Trigger to determine if entities with this tag can spawn
			trigger = {}
		}
	}
	
	route_entities = {				# Route entities are entities that could be ussed to compose caravan
		example_entity_1 = {		# Each entity corresponds to a number of entities that could be placed in specified position of the caravan
			# [Optional] Tags that must be active for this entity to spawn. If empty, entity can always spawn
			tags = { <tag_name_1> <tag_name_2> ... }
			entity = "entity_1"		# Entity key that is specified in .asset files
			position = 0			# Position defines the order in which entities will be position, if positions are the same random entity would be picked
			entity_length = 3.0		# Entity length is the length used for placing entities on the route
			count = {}				# [Default = 1] Count is scripted value to determine amount of entities placed one by other for country scope and 'state' flag
		}
		example_entity_2 = {	
			entity = "entity_2"	
			position = 1		
			entity_length = 2.0	
			count = {}			
		}
	}
}
