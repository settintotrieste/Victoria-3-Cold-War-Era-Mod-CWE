Available categories are:

- ui_skin_theme
- papermap_theme
- table_top_theme
- table_asset_1_theme
- table_asset_2_theme
- table_asset_3_theme
- table_asset_4_theme
- table_asset_cloth_theme
- building_sets_themes


	theme_name = {					# requires 'theme_name' and 'theme_name_desc' to be added in 'game/localization/english/themes_l_english.yml'
		category = key				# Each category also defines whether multiple themes can be applied at the same time.

		skin = "name"				# Skins are defined in .skin files in gfx/skins. This field must match the name in a skin file or default for the default skin. Only for ui_skin_theme category.

		map_textures = "gfx/map/textures/maptextures.settings" # Path to a settings file for map textures. Only for category papermap_theme.

		theme_object = {			# Multiple allowed. This is a mesh or entity that will be spawned when this theme is active. Only applicable for categories: papermap_theme, table_top_theme, table_asset_N_theme
			pdxmesh = "mesh_name"	# Name of mesh to spawn, mutually exclusive with entity.
			entity = "entity_name"	# Name of entity to spawn, mutually exclusive with pdxmesh.
			locator = "locator_name" # Locator for the spawned object. Instance id 1 is used.
		}

		dlc = "key"					# Key of the DLC inside game/dlc_metadata/00_dlc_metadata.txt. For example: dlc = "dlc003"
	}
