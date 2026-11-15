ai_ship_category_key = {
	# Country scope. When false, the AI does not build this category and leaves it out of the mix it plans
	# its navy around, but still knows how many of these ships it would want, e.g. when offered one
	can_build = { <triggers> }
}

# AI-only categorisation of ship types, used by the AI to organise its navy into fleets and to decide
# what to build. Membership is declared per ship type with ai_ship_category in common/ship_types.
# Every ship type must belong to exactly one of these.
#
# Referenced by ai_ship_category_weights in common/ai_strategies, both at the top level (the mix of
# ships the AI wants to own) and inside fleet_compositions (how those ships are split into fleets).
#
# These are deliberately separate from the ship_group in common/ship_groups, which drives
# construction modifiers, laws, technologies and how ships are presented to the player.
