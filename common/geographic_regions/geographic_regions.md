geographic_region_key = {
	# All state/strategic regions are added together to form a geographic region

	# the key to access this in script lists i.e <any/..>_<state/...>_in_europe
	short_key = "europe"

	# The Strategic Regions this geographic region encompasses
	strategic_regions = { sr:<key> sr:<key> sr:<key> }

	# The State Regions this geographic region encompasses
	state_regions = { <STATE_REGION> <STATE_REGION> }
}

# Add a "<geographic_region_key>_desc" localization key to include fluff/lore description of your geographic region
