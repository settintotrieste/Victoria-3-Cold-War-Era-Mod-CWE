company_charter_type = {
	type = <investment/monopoly/new_industry/trade/colonization>
	
	icon = "texture.dds"

	cooldown = { months = 24 } # Cooldown, in case it is not defined the charter will have no cooldown
	
	ai_possible = {} # If this charter is possible to be picked up by AI
	ai_weight = {} # Check score for AI to pickup charter, will be scaled by company relative size to other companies
}
