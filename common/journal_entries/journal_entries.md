    journal_entry_key = {
        # root = context-based scope. either owning country, a specific country, or no scope
        # scope:journal_entry = this Journal Entry (journalentry scope)
        # scope:target = target value, with which this Journal Entry was added using `add_journal_entry` effect
    
        # optional journal entry group as specified in common/journal_entry_groups
		# context is set in the group
        group = journalentrygroup_mygroup
    
        # optional image that shows in the journal entry widget near the description, default = NDefines::GUI::JOURNAL_ENTRY_ICON_DEFAULT (set in /defines/00_interfaces.txt)
        icon = "gfx/interface/icons/event_icons/event_industry.dds"
    
        # optional trigger which determines if a journal entry can be shown when not active, default = no
        # is ignored when JE is added through `add_journal_entry` effect
		# root = owning country or no scope
        is_shown_when_inactive = {
            c:GBR = root
        }
		
		# whether a country should become involved when a contextless JE activates
		# root = specific country
		should_be_involved = {		
		}
		
		# whether this JE should be visible to a country that is not involved in a contextles JE, also additionally determines who can see it when it's not active
		# root = specific country
		should_show_when_not_involved = {
		}	
    
        # one or more scripted buttons. See common/scripted_buttons/scripted_buttons.md for more info
        scripted_button = scripted_button_key
    
        # optional trigger - when both this and is_shown_when_inactive is true, the JE is Activated, default = yes
        # is ignored when JE is added through `add_journal_entry` effect
        # root = owning country or no scope
        possible = {
            c:USA ?= {
                owns_entire_state_region = scope:target
            }
        }
    
        # effect which happens when a journal entry is activated by having its `is_shown_when_inactive` and `possible` triggers become true or when JE is added through `add_journal_entry` effect
        # root = owning country or no scope
        immediate = {
            c:USA ?= {
                # saved scopes can be used in any events triggered from the Journal Entry, as well as in the loc for the Journal Entry itself
                # To use saved scopes in loc: JournalEntry.GetTopScope.sCountry('saved_scope_name') or SCOPE.sCountry('saved_scope_name')
                save_scope_as = god_bless_america
                set_variable = {
                    name = freedom
                    value = 1
                }
            }
    
            set_variable = test_variable
    
            # all events in these on_actions can refer to scope:god_bless_america
            trigger_event = {
                id = test_event.1
                days = 0
                popup = yes
            }
        }
		
		# as immediate, but fired individually for each involved country in a contextless JE
		# root = specific country
		immediate_all_involved = {
		}
    
        # completion trigger, use is_goal_complete = yes in here if you're testing a tracked goal metric; if left blank, cannot be completed
        # root = owning country or no scope
        complete = {
            scope:god_bless_america = {
                NOT = { owns_entire_state_region = STATE_ALASKA }
            }
    
            custom_tooltip = {
                # Following loc functions can be used:
                # [JournalEntry.GetTotalGoalValue] - goal absolute value (fixed point)
                # [JournalEntry.CalcCurrentGoalValue] - current progress absolute value (fixed point)
                # [JournalEntry.GetGoalAddValue] - goal relative value (fixed point)
                # [JournalEntry.GetGoalProgressValue] - current progress relative value (fixed point)
                # [JournalEntry.GetGoalProgressPercent] = GetGoalProgressValue / GetGoalAddValue (fixed point)
                text = journal_entry_key_goal_text
                scope:journal_entry = { is_goal_complete = yes }
            }
        }
    
        # effect which is executed when 'complete' trigger becomes true
        # root = owning country or no scope
        on_complete = {
            trigger_event = {
                id = test_event.10
                days = 0
            }
        }
		
        # as on_complete, but fired individually for each involved country in a contextless JE
		# root = specific country
	    on_complete_all_involved = {
        }		
    
        # failure trigger, should spawn event explaining what happens when triggered, framed as a failure; if left blank, cannot fail
        # root = owning country or no scope
        fail = {
            NOT = { c:GBR = root }
        }
    
        # effect which is executed when 'fail' trigger becomes true
        # root = owning country or no scope
        on_fail = {
            remove_variable = test_variable
            scope:god_bless_america = {
                remove_variable = freedom
            }
        }
    
     	# as on_fail, but fired individually for each involved country in a contextless JE
		# root = specific country
		on_fail_all_involved = {
        }	
		
        # optional invalidation trigger, should not notify player when it triggers, just clean up and silently disappear due to journal entry no longer being valid; if left blank, cannot be invalidated
        # root = owning country or no scope
        invalid = {
    
        }
    
        # effect which is executed when 'invalid' trigger becomes true
        # root = owning country or no scope
        on_invalid = {
    
        }
		
        # as on_complete, but fired individually for each involved country in a contextless JE
		# root = specific country
	    on_invalid_all_involved = {
		}
		
		# fires when a country becomes involved after activation of a contextless JE, ie not as a result of the should_be_involved trigger
		# root = specific country
		on_become_involved_after_activation = {
		}

		# fires when a country stops being involved in a contextless JE
		# root = specific country
		on_no_longer_involved = {
		}			
		
        # dynamically updated text, which describes the current status of the Journal Entry
        # To use in loc or UI: [JournalEntry.GetStatusDesc]
        # If this is not specified, GetStatusDesc will instead return loc from key <journal_entry_key>_status
        # root = owning country or no scope
        status_desc = {
            first_valid = {
                triggered_desc = {
                    desc = journal_entry_key_status_1
                    trigger = {
                        has_variable = mining_strike
                    }
                }
                triggered_desc = {
                    desc = journal_entry_key_status_2
                    trigger = {
                        has_variable = industrial_strike
                    }
                }
                triggered_desc = {
                    desc = journal_entry_key_status_2
                    trigger = {
                        has_variable = railway_strike
                    }
                }
            }
        }
		
		# dynamically updated text, which describes potential event outcomes when JE is activated
		# multiple such entries can be added to a JE
        # root = owning country or no scope
        event_outcome_activated_desc = {
			first_valid = {
				triggered_desc = {
					desc = holstein_is_annexed
					trigger = {
						exists = c:SCH
					}
				}
			}
		}
		
		# alternative to  event_outcome_activated_desc using the effect system to automatically generate tooltips
		# note that the effects here are only used for description purposes and will not actually happen
		# root = owning country or no scope
        event_outcome_activated_effect_desc = {
			header = option_gain_money
			effect = {
				add_treasury = 1000
			}
		}
		
		# dynamically updated text, which describes potential event outcomes when JE is invalidated
		# multiple such entries can be added to a JE
        # root = owning country or no scope
        event_outcome_invalidated_desc = {
			first_valid = {
				triggered_desc = {
					desc = holstein_is_annexed
					trigger = {
						exists = c:SCH
					}
				}
			}
		}
		
		# alternative to  event_outcome_invalidated_desc using the effect system to automatically generate tooltips
		# note that the effects here are only used for description purposes and will not actually happen
		# root = owning country or no scope
        vent_outcome_invalidated_effect_desc = {
			header = option_gain_money
			effect = {
				add_treasury = 1000
			}
		}	
		
		# dynamically updated text, which describes potential event outcomes when JE is completed
		# multiple such entries can be added to a JE
        # root = owning country or no scope
        event_outcome_completed_desc = {
			first_valid = {
				triggered_desc = {
					desc = holstein_is_annexed
					trigger = {
						exists = c:SCH
					}
				}
			}
		}
		
		# alternative to  event_outcome_completed_desc using the effect system to automatically generate tooltips
		# note that the effects here are only used for description purposes and will not actually happen
		# root = owning country or no scope
        event_outcome_completed_effect_desc = {
			header = option_gain_money
			effect = {
				add_treasury = 1000
			}
		}	

		# dynamically updated text, which describes potential event outcomes when JE is failed
		# multiple such entries can be added to a JE
        # root = owning country or no scope
        event_outcome_failed_desc = {
			first_valid = {
				triggered_desc = {
					desc = holstein_is_annexed
					trigger = {
						exists = c:SCH
					}
				}
			}
		}	

		# alternative to event_outcome_failed_desc using the effect system to automatically generate tooltips
		# note that the effects here are only used for description purposes and will not actually happen
		# root = owning country or no scope
        event_outcome_failed_effect_desc = {
			header = option_gain_money
			effect = {
				add_treasury = 1000
			}
		}			
	
		# dynamically updated text, which describes potential event outcomes when JE timeouts
		# multiple such entries can be added to a JE
        # root = owning country or no scope
        event_outcome_timeout_desc = {
			first_valid = {
				triggered_desc = {
					desc = holstein_is_annexed
					trigger = {
						exists = c:SCH
					}
				}
			}
		}		
		
		# alternative to  event_outcome_timeout_desc using the effect system to automatically generate tooltips
		# note that the effects here are only used for description purposes and will not actually happen
		# root = owning country or no scope
        event_outcome_timeout_effect_desc = {
			header = option_gain_money
			effect = {
				add_treasury = 1000
			}
		}			

        # [optional] loc key to use instead of JOURNAL_ENTRY_COMPLETION_HEADER, for flavor
        custom_completion_header = <loc key>

        # [optional] loc key to use instead of JOURNAL_ENTRY_FAILURE_HEADER, for flavor
        custom_failure_header = <loc key>

        # [optional] loc key to use instead of JOURNAL_ENTRY_ON_COMPLETION, for flavor
        custom_on_completion_header = <loc key>

        # [optional] loc key to use instewad of JOURNAL_ENTRY_ON_FAILURE, for flavor
        custom_on_failure_header = <loc key>

        # the number of days before this journal entry forcibly transitions, can be used to transition silently or into another event, framed either as success, failure, or neutral; if left blank or set to zero, will not time out
        timeout = 720
    
        # effect which is executed when journal entry is timed out
        # root = owning country or no scope
        on_timeout = {
    
        }
		
     	# as on_timeout, but fired individually for each involved country in a contextless JE
		# root = specific country
		on_timeout_all_involved = {
        }		
        
        # zero or more static modifiers that will be applied to the Journal Entry when it activates, where they will propagate to the country
		# for contextless JEs, these propagate to all involved countries
        modifiers_while_active = {
        
        }  
    
        # on_action which is triggered every first day of the week
        # root = owning country or no scope
        on_weekly_pulse = {
            random_events = {
                100 = 0
                10 = test_event.2
                10 = test_event.3
                10 = test_event.4
            }
        }
    
        # on_action which is triggered every first day of the month
        # root = owning country or no scope
        on_monthly_pulse = {
            events = {
                test_event.5
            }
        }
    
        # on_action which is triggered every first day of the year
        # root = owning country or no scope
        on_yearly_pulse = {
            effect = {
                scope:god_bless_america = {
                    change_variable = {
                        name = freedom
                        add = 1
                    }
                }
            }
        }
    
        # a script value computing the goal completion metric
        # root = owning country or no scope
        current_value = {
            value = gdp
        }
    
        # when the journal entry is activated current_value and goal_add_value are evaluated and added together to determine the goal value
        # root = owning country or no scope
        goal_add_value = {
            value = gdp
            multiply = 0.25
        }
    
        # the highest weighted active journal entry appears in the goal tracker on the main screen
        weight = 200
    
        # yes/no, determines if this journal entry should be transfered if the player switches country through a revolution or by releasing a subject. Note that external dependencies such as country variables etc are not automatically inherited
        transferable = no
        
        # yes/no, determines if this journal entry is allowed to be inherited by a victorious revolution. Revolutions also get all variables from the defeated parent country, so most JEs *should* be inherited in this way
        # NOTE: transferable = yes will always mean that revolution inheritance is blocked as these JEs should stay with the player at all times
        can_revolution_inherit = yes
    
        # optional trigger, progress text is shown if this is defined and true
        # root = owning country or no scope
        is_progressing = {
            exists = scope:target
            scope:target = { is_under_construction = yes }
        }
    
        # yes/no, if yes, a progress bar is shown
        progressbar = yes
    
        # scripted progress bars the name and definition of the bar is placed under game/scripted_progress_bars
        scripted_progress_bar = name_of_scripted_bar
    
        # yes/no, if yes, the Journal Entry can return to an inactive state if its possible trigger reverts to false
        # if no or unspecified, an activated Journal Entry cannot return to being inactive even if it is no longer considered possible
        can_deactivate = yes
        
        # dynamically updated text, which is shown over the progress bar of the Journal Entry
        # value can be a localization key or first_valid + triggered_desc script
        # To use in loc or UI: [JournalEntry.GetProgressDesc]
        # If this is not specified, GetProgressDesc will instead return loc from key <journal_entry_key>_progress
        progress_desc = journal_entry_goal_progress_integer
        
        # tutorial lesson explaining HOW to complete the Journal Entry
        how_tutorial = how_tutorial_lesson_key
        
        # tutorial lesson explaining the WHY around the Journal Entry
        why_tutorial = why_tutorial_lesson_key
    
        # whether a Journal Entry should be pinned in its outliner by default. Defaults to 'no'
        should_be_pinned_by_default = yes
    }
