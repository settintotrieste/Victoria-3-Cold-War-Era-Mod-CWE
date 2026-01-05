	sg_key = {
		category = key 	# The subgoal category of this subgoal
	
		# The four entries below check against already completed subgoals - they must all be passed for subgoal to have a chance to trigger (empty = automatic pass)
		unlocking_subgoals_all = {} # all of these other subgoals must be completed (or failed/timed-out and non-repeatable) for subgoal to be able to trigger
		unlocking_subgoals_any = {} # one of these other subgoals must be completed (or failed/timed-out and non-repeatable) for subgoal to be able to trigger 
		blocking_subgoals_none_of = {} # none of these other subgoals must be completed (or failed/timed-out and non-repeatable) for subgoal to be able to trigger
		blocking_subgoals_not_all = {} # at least one of these other subgoals must NOT be completed (or failed/timed-out and non-repeatable) for subgoal to be able to trigger

		trigger = {} # scripted trigger evaluation for whether this subgoal is able to trigger
	
		chance = { value = X } # scripted value for the daily chance to trigger this subgoal ( unset = 1 = 100% )
	
		on_start = {} # effect executed when this subgoal is triggered
	
		is_repeatable = yes/no    # Whether this subgoal can be repeated after being completed (overrides the default set in subgoal category), if no then failure is treated as unlocking/blocking for other goals
	}
