# Scopes:

		root = action initiator
		scope:target = action target

# Syntax:
		diplomatic_action = {
			groups = { # diplomatic action groups. Example: subject means a subject is taking an action.
				general # Currently available: general, subject, overlord and power_bloc; for sorting these in different datamodels, general break actions supersede all other categories, while subject supersedes overlord supersedes power_bloc actions
			}

			requires_approval = bool # Whether this action requires the approval of the target, default no
			uses_random_approval = bool # If this is true, then positive acceptance becomes a % chance to accept rather than always being accepted (+50 acceptance = 50% chance etc)
	
			state_selection = setting # If set, this allows or requires one or two states to be selected for this action, see below for all settings
			# first_required - Must select a state for initiator
			# first_optional - May select a state for initiator
			# second_required - Must select a state for target
			# second_optional - May select a state for target
			# both_required - Must select a state for initiator AND target
			# both_optional - May select a state for initiator OR target OR both
			# any_required - Must select a state for initiator OR target OR both

			first_state_list = setting # Defaults to all
			# first_country - If there is a first_state_trigger, then evaluate it for each state in first_country (aka scope:country).
			# second_country - If there is a first_state_trigger, then evaluate it for each state in second_country (aka scope:target_country).
			# all - If there is a first_state_trigger, then evaluate it for each state in the world. This is performance intensive and should be avoided.

			second_state_list = setting # Defaults to all
			# first_country - If there is a second_state_trigger, then evaluate it for each state in first_country (aka scope:country in first/second_state_trigger)
			# second_country - If there is a second_state_trigger, then evaluate it for each state in second_country (aka scope:target_country in first/second_state_trigger)
			# all - If there is a second_state_trigger, then evaluate it for each state in the world. This is performance intensive and should be avoided.

			show_confirmation_box = bool # Whether player should be prompted with a confirmation box when taking this action, default yes
	
			selectable = {} # Trigger for whether action is visible/selectable with *any* target country, only evaluates proposing country, default evaluates to true
	
			potential = {} # Trigger for whether action is potential, default evaluates to true. NOTE this also requires all requirement_to_maintain to be true
	
			possible = {} # Trigger for whether action is possible, default evaluates to true. NOTE this also requires all requirement_to_maintain to be true
	
			first_state_trigger = {} # Trigger for whether a state is selectable for initiator. scope:country is the initiator, scope:target_country is the target
			second_state_trigger = {} # Trigger for whether a state is selectable for target. scope:country is the initiator, scope:target_country is the target

			effect = {} # Effect of action on execution

			is_hostile = bool # is this a hostile action, default no
	
			confirmation_sound = "event:/SFX/UI/Global/alternate_confirmation"	# If set, overrides the sound path set in defines/00_audio.txt for this particular action
			request_sound = "event:/SFX/UI/MapInteraction/alternate_request"	# If set, overrides the sound path set in defines/00_audio.txt for this particular action
			hostile_sound = "event:/SFX/UI/MapInteraction/alternate_hostile"	# If set, overrides the sound path set in defines/00_audio.txt for this particular action
			benign_sound = "event:/SFX/UI/MapInteraction/alternate_benign"		# If set, overrides the sound path set in defines/00_audio.txt for this particular action

			pact = { # If no pact block is defined, the action will not create a diplomatic pact on execution
				cost = x # Cost in diplo capital to maintain the pact
				counts_for_tech_spread = x # Whether or not tech spreads through this pact
				forced_duration = x # How many months after being established is it not possible to break this pact, overriden by OBLIGATION_FORCED_PACT_MONTHS if obligation is used, cannot be lower than PACT_REQUIRES_APPROVAL_MIN_FORCED_MONTHS for pacts that require approval
	
				second_country_gets_income_transfer = yes/no # If yes, actor pays money to recipient, if no recipient pays to actor
				income_transfer_based_on_second_country = yes/no # If yes, the amount of money transferred to the other part is based on a fraction of recipient's tax income, if no it's based on a fraction of actor's income.
				income_transfer_to_pops = { # If defined, the transfered income will go to appro pops of the target country instead of the treasury
					allow_discriminated = yes/no # Do discriminated pops also get a share of the transfered money?
		
					# Script values for fraction of the money that will go to different strata pops in target
					# Values are relative to each other, so if upper_strata_pops evaluates to 100 and the total value is 1000, upper strata pops will get 10% of the money
					upper_strata_pops = {
						value = x  
					}
					middle_strata_pops = {
						value = x
					}
					lower_strata_pops = {
						value = x
					}
				}
				income_transfer = x # The base income transfer amount (as a fraction of income)
				max_paying_country_income_to_transfer = x # Income transfer cannot exceed this fraction of the sender's income, for pacts with income transfer based on second country
					
				propose_string = string # Loc string used when proposing pact, default PROPOSE
				break_string = string # Loc string used when breaking pact, default BREAK
				ask_to_end_string = string # Loc string used when proposing to break a pact, default ASK_TO_END
	
				military_access = yes/no # Whether this pact provides military access between both parties, i.e. formations can travel on the other country territory
				actor_requires_approval_to_break = bool # Whether this pact requires the approval of the other part for original initiator to break it off, default no
				target_requires_approval_to_break = bool # Whether this pact requires the approval of the other part for original target to break it off, default no

				is_breaking_hostile = yes/no # is breaking this pact by actor considered hostile, default no
				is_target_breaking_hostile = yes/no # is breaking this pact by target considered hostile, default no
	
				actor_can_break = {} # Trigger for whether the original initiator of a pact can break it off, default evaluates to true
				target_can_break = {} # Trigger for whether the original target of a pact can break it off, default evaluates to true
		
				requirement_to_maintain = { # Any number of these triggers can be added to a pact to set up the requirements to propose and maintain it
					trigger = {} # If this evaluates to false, the pact will automatically break the next tick UNLESS it is a forced duration pact, and also will not be able to be proposed (so you don't need to also check the condition in possible)
			
					show_about_to_break_warning = {} # If this evaluates to true, the player will get an alert that this specific requirement to maintain is in danger of failing
				}
	
				daily_effect = {} # Effect of pact each day while active
				weekly_effect = {} # Effect of pact each week while active
				monthly_effect = {} # Effect of pact each month while active
	
				manual_break_effect = {} # Effect of pact on being manually broken by either part
				auto_break_effect = {} # Effect of pact on being automatically broken due to requirement invalidating
		
				subject_relation = { # If a subject relation block is defined, this pact acts as a overlord/subject relationship
					annex_on_country_formation = bool # If yes, appropriate-culture subjects of this type will be annexed when overlord forms a new country, default no
				}
		
				# pact forces the initator to automatically join the targets side in diplomatic plays of specified type'
				# this is a list, so you can have multiple entries
				auto_support_type = dp_example_play
			}
	
			# IMPORTANT: In the AI block, the AI country is always root and the other country always scope:target, regardless of who proposed the diplomatic action
			ai = {
				# The chance (0 - 100%) that the AI is going to evaluate this action against other countries each update
				# Unlike the other AI values, this *only* looks at the proposing AI country and has no data about targets
				evaluation_chance = {}

				# Selection triggers that exist only to pre-filter which state combinations the AI looks at
				# This is done for performance reasons - the more open ended these triggers are, the more it will impact performance in actions where both sides can select states
				# These only contain the state as root in the scope and no other data
				will_select_as_first_state = {}		
				will_select_as_second_state = {}
		
				will_propose_with_states = {} # Checked before will_propose = {} to further cut down on state combinations the AI will do a full evaluation for
	
				will_propose = {} # Trigger for if AI will consider proposing this action (their acceptance if asked still has to be positive if action requires acceptance), default evaluates to true
				will_break = {} # Trigger for if AI will consider breaking off an existing pact of this action (their acceptance as if asked still has to be significantly negative if action requires acceptance), default evaluates to true
		
				will_propose_even_if_not_accepted = {} # Trigger for if AI will propose an action even if they think it's going to be declined, checked after will_propose
		
				accept_score = {} # If this value evaluates to above zero, AI will accept this action if proposed
				accept_break_score = {} # If this value evaluates to above zero, AI will accept breaking this pact if proposed

				propose_score = {} # This determines how much the AI will prioritize proposing this particular deal
				propose_break_score = {} # This determines how much the AI will prioritize proposing breaking this particular pact
		
				use_favor_chance = {} # The chance (0 - 100%) that AI is willing to call in a favor to force this through
				owe_favor_chance = {} # The chance (0 - 100%) that AI is willing to owe a favor to get this accepted	
			}
		}