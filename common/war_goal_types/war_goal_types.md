# Notes

## Kind, type, settings?
A war goal type is a war goal as defined in script (e.g. the contents of 00_annex_country.txt). The Kind of the war goal defines the code-side predefined package of behavior that war goal will have, primarily defining what effect the war goal has when executed. Settings further customize how the war goal is treated in different checks. A war goal can only have one kind, but multiple settings.

# Reference

```
some_war_goal = {
	icon = "gfx/interface/icons/war_goals/icon.dds"

	kind = war_goal_kind

	settings = {
        setting_1
        setting_2
	}

	execution_priority = 80

	contestion_type = control_type

	target_type = target_type

	possible = {
		# trigger to determine if a goal with its target data is listed when selecting a war goal in the diplo play panel
		# scopes: root = holder, creator_country, diplomatic_play, target_country, target_state, stakeholder, target_region, article_options
	}

	valid = {
		# trigger in addition to some basic validation code-side
		# scopes: root = holder, creator_country, diplomatic_play, target_country, target_state, stakeholder, target_region, article_options
	}

	maneuvers = {
		# script value
		# scopes: root = holder, creator_country, diplomatic_play, target_country, target_state, stakeholder, target_region, article_options
		value = 10
	}
	
	infamy = {
		# script value
		# scopes: root = holder, creator_country, diplomatic_play, target_country, target_state, stakeholder, target_region, article_options
		value = 15
	}

	on_enforced = {
		# script effect on top of the predefined code effect
		# scopes: root = holder, creator_country, diplomatic_play, target_country, target_state, stakeholder, target_region, article_options
	}

	ai = {
		is_significant_demand = yes
	}
}
```

# Instructions

## Icon
The path to the icon the war goal should use. Typically something from `gfx/interface/icons/war_goals/`

## Kind
The primary predefined package of behavior code will associate with this war goal. Primarily this defines the execution effects of the war goal, but it also implies some other checks in different parts of code required for the functioning of the effects.

### List of Kinds
- annex_country
- ban_slavery
	Converted to law commitment treaty article for slavery banned
- colonization_rights
- conquer_state
- contain_threat
- enforce_treaty_article
- force_nationalization
- foreign_investment_rights
	Converted to investment rights article
- humiliation
- increase_autonomy
- independence
- join_power_bloc
- leave_power_bloc
- liberate_country
- liberate_subject
- make_dominion
- make_protectorate
- make_tributary
- open_market
- reduce_autonomy
- regime_change
- return_state
- revoke_all_claims
- revoke_claim
- secession
- take_treaty_port
	Converted to treaty port treaty article
- transfer_subject
- unification
- unification_leadership
- custom
	No predefined effect. In case you only want to execute the on_enforced effect, but nothing else.

## Settings
Settings define smaller behaviors or checks that a war goal might want to have. Some settings are safe to remove (e.g. for modding) from certain war goal kinds, but some are required for them to function properly.

### List of settings
- require_target_be_part_of_war
	Target country has to be in the war, can't target neutral countries
- can_add_for_other_country
	Allows adding the goal for other participating countries
- annexes_entire_state
	Flag for if the goal is expected to always annex the entire target state. This is used to calculate conflicts with other goals
- annexes_entire_country
	Flag for if the goal is expected to always annex the entire target state. This is used to calculate conflicts with other goals
- country_creation
	Flag for if the goal creates a new country
- overlord_is_stakeholder
	Flag for if the stakeholder of the war goal should be the overlord rather than the target country itself
- can_target_decentralized
	If the war goal can target decentralized countries
- has_other_stakeholder
	If the war goal has a different stakeholder than the target itself
- turns_into_subject
	If the war goal turns the target country into a subject. For conflict resolution purposes
- skip_build_list
	If the war goal should be available to be picked in the diplomatic play or not
- targets_enemy_subject
	If the war goal should target an enemy subject specifically rather than all enemies in the war goal
- targets_enemy_claims
	If the war goal should target the claims of a country, rather than the country itself
- requires_interest
	If the war goal requires you to have an interest in the relevant strategic zone
- debug
	No effect, used for code debug purposes.
- validate_subject_relation
	Validation behavior that checks if the resulting subject relation of this war goal is valid
- validate_formation_candidate_self
	Validation check to make sure the goal holder is a formation candidate
- validate_formation_candidate_target
	Validation check to make sure the goal target is a formation candidate
- validate_sole_formation_candidate
	Validation check to make sure the goal holder is the only formation candidate
- validate_target_not_treaty_port
	Validation check to make sure the target state is not a treaty port
- validate_join_power_bloc
	Special validation for join power bloc war goal kind
- validate_colonization_rights
	Special validation for colonization rights war goal kind
- validate_force_nationalization
	Special validation for force nationalization war goal kind
- validate_foreign_investment_rights
	Special validation for investment rights war goal kind
- validate_regime_change
	Special validation for regime change war goal kind
- validate_contain_threat
	Special validation for contain threat war goal kind
- validate_revoke_claims
	Special validation for revoke claims war goal kind
- validate_increase_autonomy
	Special validation for increase autonomy war goal kind
- validate_take_treaty_port
	Special validation for take treaty port war goal kind
- validate_independence
	Special validation for independence war goal kind
- validate_conflicts_war_goals_holder
	Validate conflicts with war goals of the same type from holder
- validate_conflicts_war_goals_all
	Validate conflicts with war goals of the same type from all participating countries
- validate_conflicts_conquer_state
	Validate conflicts with war goals that conquer states (i.e. that have the conflicts_with_annex_state)
- validate_conflicts_annex_country
	Validate conflicts with war goals that annex countries (i.e. that have the conflicts_with_annex_country)
- validate_conflicts_make_subject
	Validate conflicts with war goals that make new subjects (i.e. that have the conflicts_with_make_subject)
- validate_conflicts_existing_subject
	Validate conflicts with war goals that make new subjects (i.e. that have the conflicts_with_make_subject)
- conflicts_with_make_subject
	Marks the war goal as potentially conflicting with make subject war goals
- conflicts_with_country_creation
	Marks the war goal as potentially conflicting with country creation war goals
- conflicts_with_annex_country
	Marks the war goal as potentially conflicting with annex country war goals
- conflicts_with_annex_state
	Marks the war goal as potentially conflicting with annex state war goals
- conflicts_with_existing_subject
	Marks the war goal as potentially conflicting with existing subject war goals

## Execution Priority
Determines in what order war goals are executed in a peace deal. Higher value gets executed first. Changing this can make certain war goals not execute properly.

## Contestion Type
Determines what the war goal holder needs to do for the war goal to be considered controlled.

### List of Contestion Types
- control_target_state
- control_target_country_capital
- control_any_target_country_state
- control_any_target_incorporated_state
- control_own_state
- control_own_capital
- control_all_own_states
- control_all_target_country_claims
- control_any_releasable_state

## Target Type
What kind of entity the war goal primarily "targets". This primarily defines how the game generates potential alternatives for each war goal type when selecting one from the diplomatic play panel. Most war goal kinds will require a specific target type to work well and can't be changed (i.e. Conquer State can't have a Treaty Article target type). This field primarily allows you to have custom war goals target different entities.

### List of Target Types
- Country
	Loops over enemy countries to generate war goal alternatives
- State
	Loops over states belonging to enemy countries
- Treaty Article
	Loops over article types and then enemy countries

## Triggers and Effect

### Scope
For all of the following the same scopes are available:
- root (holder country)
- creator_country
- diplomatic_play
- target_country
- target_state
- stakeholder
- target_region
- article_options

### Possible trigger
This determines if and when the war goal is listed when selecting war goals in a diplomatic play.

### Valid trigger
This determines if the war goal is valid from a script perspective. Additional validation is done in code base on the war goal kind and settings.

### Maneuvers
How many maneuvers it costs to select this war goal

### Infamy
How much infamy it costs to claim this war goal

### On enforced
Additional script effects that you might want the war goal to execute. Do note that validation will not automatically take this into account and you will need to add validation settings as appropriate to avoid conflicts with other war goals.

## AI / Is Significant Demand
AI flag that determines how important AI considers this war goal to be.