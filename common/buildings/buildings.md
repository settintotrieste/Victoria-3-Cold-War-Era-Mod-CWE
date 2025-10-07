    building_key = {
        building_group = bg_key								# *reference to building group, building groups define some common properties of similar buildings*
        icon = "path/to/texture"							# building icon
    
        buildable = yes/no									# can this building be built? ( can otherwise be created via history or script or autoplace ), default yes
        expandable = yes/no									# can this building be expanded? default yes
        downsizeable = yes/no								# can this building be downsized? default yes
        unique = yes/no										# if yes, only one level of this building type can be built in the world and never by private investors, default no
        has_max_level = yes/no								# if yes, a dynamic country modifier is created to determine max level, default no
        ignore_stateregion_max_level = yes                  # if the building's building group has stateregion_max_level = yes, override it for this building type
        enable_air_connection = yes/no						# if yes the region with that building built is considered for air travel, default no
        port = yes/no 										# if yes the building can connect different market areas, default no
        company_headquarter = yes/no                        # whether if the building is a company headquarter, default no
    
        unlocking_technologies = {							# optional list of required technologies to be able to build this building
            # list of technology keys
        }
    
        # optional custom trigger (state scope) if the state is potential for this building type, i.e. can ever be built there, default yes
        potential = {
            # trigger definition
        }
    
    	# optional custom trigger (state scope) if it's possible to build the building in the state now, default yes
        possible = {
            # trigger definition
        }

        can_build = {										# optional custom trigger (state scope) for building requirements
            # trigger definition
        }
    
        can_have_country_monopoly = {                       # optional custom trigger (country scope) for whether building can be part of a monopoly
            #trigger definition
        }

        construction_points = int32							# number of construction points required for construction
        construction_modifier = {							# (optional) applied to the construction camp at a scale of weekly construction output / construction_points
            # modifier definition							# commonly used to add an additional cost of construction that will be consumed over the duration of construction
        }
    
        owners = pop_type_key								# dividends and investment pool, if not set determined by building group
        economic_contribution = 0.0-1.0						# multiplier for taxes/gdp from this building, 0.0 for no taxes/gdp, default 1.0
        min_raise_to_hire = fixed_point						# minimum required increase in salary for an employee to switch to working at this workplace, default NEconomy.MIN_RAISE_TO_HIRE
    
        naval = yes/no										# navy or army, default no, only applicable to military buildings, which is determined by building group
        canal = canal_type_key								# reference to canal type, if set, marks the building as a canal
    
        # base AI value, default NAI.BUILDING_BASE_VALUE or NAI.GOVERNMENT_BUILDING_BASE_VALUE
        # scope is state the building is located in
        # be careful when using this as applying complex triggers to it may negatively impact performance in a significant way
        ai_value = script value							
        
        # how much the AI wants to nationalize/privatize the building, added to nationalization_desire value in ai_strategies
        # scope is country the building is located in
        ai_privatization_deisre = script value				
    
        slaves_role = pop_type_key                          # defines which pop type should slaves work as. Defaults to DEFAULT_POP_TYPE.
    
        production_methods = {								# a building's behavior can be modified by its production methods
            # list of Production Method Groups
        }
        
        should_auto_expand = trigger						# under which conditions we should auto-expand if auto-expand is toggled on (overrides building group if present)
                                                            # if this trigger has any contents at all, the game will think the building is potentially auto-expandable, so do not write triggers that can never evaluate to true here
    
        category_building_type = other_building_key         # which category should this building be counted as: in average earnings/productivity, in the building registry, etc. Defaults to itself

        city_type = none/city/farm/mine/port/wood			# which type of hub this building will be spawned into, default none
        generates_residences = yes/no						# if the building adds extra residencies to the city, default yes
        terrain_manipulator = terrain_manipulator_key		# terrain manipulator updated by the building
        levels_per_mesh = int32								# how many levels is needed to add 1 extra building on the map, default 1
        residence_points_per_level							# how many total "residence points" this building adds to its hub to determine residential buildings created, default 1
        
        statue = yes										# special building type for power bloc statues
        
        meshes = {											# buildings we supposed to place for dynamic terrain placement
            # list of meshes
        }
        entity_not_constructed = {							# special buildings can show an entity while not constructed
            # list of entities
        }
        entity_under_construction = {						# overload for under construction entity for special buildings
            # list of entities
        }
        entity_constructed = {								# overload to use constructed entity for special buildings
            # list of entities
        }
        locator = locator_type								# locator type for special buildings
        
        lens = infrastructure								# override for which lens the building type should appear in, otherwise specified on building group
        
        ownership_type = no_ownership/self/other			# type of the building ownership, no_ownership - can't own other buildings, dividends if any are payed to the state; self - can own only itself, pays dividends to the owning buildings; other - building can own other buildings, pays dividends only to own pops
        
        background = "gfx/interface/icons/building_icons/backgrounds/building_panel_wheat_farms_bg.dds" # Background texture for building registry items
    }