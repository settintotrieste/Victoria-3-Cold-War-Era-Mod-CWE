movement_example = {
	# The movement's category, which determines factors such as whether it has a cultural/religious identity
	# Movement categories are defined in their own database
	category = x
	
	# The core ideology of the movement - this will determine which laws they inherently support/oppose
	ideology = x
	
	# A list of character ideologies that this movement can potentially assign to leaders of IGs they are pressuring 
	character_ideologies = {}
	
	# Trigger that must evaluate true for this movement type to be created 
	# Root = country
	creation_trigger = {}
	
	# The weight for this movement type to be picked for creation over other movement types that are valid at the same instance
	# Root = country
	creation_weight = {
		value = 100
	}
	
	# Effect that is executed when a movement of this type is created
	# Root = political movement
	on_created = {}
	
	# Trigger that must evaluate true for a culture to be picked as the cultural identity for this movement type, selected among cultures present in the country
	# root = culture
	# scope:country = the country the movement would be created in
	culture_selection_trigger = {}		
	
	# Weight for a culture to be picked as the cultural identity for this movement type, compared to other cultures present in the country that are valid for the movement type
	# root = culture
	# scope:country = the country the movement would be created in
	culture_selection_weight = {}		
	
	# Trigger that must evaluate true for a religion to be picked as the religious identity for this movement type, selected among religions present in the country
	# root = religion
	# scope:country = the country the movement would be created in
	religion_selection_trigger = {}		
	
	# Weight for a religion to be picked as the religious identity for this movement type, compared to other religions present in the country that are valid for the movement type
	# root = religion
	# scope:country = the country the movement would be created in
	religion_selection_weight = {}		
	
	# Trigger that must evaluate true for an agitator to be able to support movements of this type
	# Root = character
	# scope:culture = The cultural identity of the movement, if any
	# scope:religion = The religious identity of the movement, if any
	character_support_trigger = {}
	
	# The weight for an agitator to support movements of this type, compared to other movements that are valid for them to support
	# Root = character
	# scope:culture = The cultural identity of the movement, if any
	# scope:religion = The religious identity of the movement, if any
	character_support_weight = {}
	
	# Trigger that must evaluate true for a movement to be able to pressure an Interest Group (this is in addition to the required supporting clout)
	# Root = interest group
	can_pressure_interest_group = {}
	
	# Trigger that must evaluate true for individuals in a pop to be able to support movements of this type
	# Root = pop
	# scope:culture = The cultural identity of the movement, if any
	# scope:religion = The religious identity of the movement, if any
	pop_support_trigger = {
		culture = {
			is_primary_culture_of = root.owner
		}
	}

	# These are the pop support factors that will be displayed in the UI for this movement - does not actually have any gameplay impact
	# Pop support factors are defined in their own database
	pop_support_factors = {}

	# The weight for individuals in a pop to support movements of this type, compared to other movements that are valid for them to support
	# Root = pop
	# scope:culture = The cultural identity of the movement, if any
	# scope:religion = The religious identity of the movement, if any
	pop_support_weight = {}	
	
	# Data for which types of civil wars this movement type can start
	# If a type isn't explicitly scripted here, it won't be valid for the movement type
	revolution/secession = {
		# Trigger for whether this civil war type is possible for this movement type
		# Root = political movement
		# scope:clout = combined clout of IGs that would become insurrectionary
		possible = {}
		
		# Weight for whether this civil war type should be selected over others
		# Root = political movement
		# scope:clout = combined clout of IGs that would become insurrectionary
		weight = {}

		# Optional, can be used to force a movement of this type to adopt a specific tag when rebelling
		forced_tags = {
			TAG = { # The country definition/tag that should be used
				# Trigger for whether this tag is valid to used
				# root = political movement
				trigger = {
					owner ?= { has_journal_entry = je_acw_countdown }
				}
				# The weight for this tag to be picked over other valid option
				weight = x
			}
		}
	
		# Weight for which states should tend to join the civil war side - if this is 0, the state will always be loyalist
		# Note that there are more factors that will affect this, especially for movements with cultural/religious identities
		state_weight = {
			value = 1

			if = {
				limit = {
					is_homeland_of_country_cultures = owner
				}
				add = 50
			}
		}

		# The target fraction of states in the country that should join on the civil war side
		# If not set, default defines will decide this
		target_fraction_of_states = {}		
	}
	
	# Multiplies the impact law enactment has on the activism of this movement type
	law_enactment_radicalism_multiplier = x
	
	# Bespoke factors for increasing/decreasing the activism of movements of this type
	additional_radicalism_factors = {}	
}	
