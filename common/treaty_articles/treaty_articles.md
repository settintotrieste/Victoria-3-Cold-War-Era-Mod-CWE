# Notes

## party, not party
Unless otherwise specified, in this document any mention of "party" or
"parties" refers to a party or parties to a treaty, not to political parties.

## First, second, source, target
Depending on the kind of article (mutual or directed), you'll have access to first/second or source/target scopes.
It's important to note that no assumptions can be made about the "role" of the country in a first/second scope
For source/target they are what they say they are, but for first/second it's just a way of getting the two countries involved

## source and target apply to articles, not treaties
Imagine a treaty between party A and B containing 3 articles:
1. party A gives 100 of resource X to party B
2. party B gives 50 of resource Y to party A
3. parties A and B establish an alliance

There is no "source" or "target" party when it comes to the treaty itself.
In article 1, the source party is A and the target party is B.
In article 2, the source party is B and the target party is A.
In article 3, which is a mutual article, there is neither a source nor a target party.

## Directed vs Mutual
Additionally, only directed articles have source/target. Mutual articles have first/second.
Trying to ask for the "wrong" thing will result in errors as they're undefined.

## Target links for treaties / articles
When you have access to a treaty scope you also have access to the following target links:
- `first_country`
- `second_country`
- `enforced_on_country`
- `enforcer_country`
- `amended_treaty`
- `remaining_binding_period`
- `binding_period`

When you have access to an article scope, you also have access to the following target links:
- `source_country` - if directed
- `target_country` - if directed
- `first_country` - if mutual
- `second_country` - if mutual
- `treaty`
- `input_<input>` - depending on which inputs the article has. Do note that an input might not yet be set when you check this if you are trying to access it in say the valid triggers or input filters
- `input_market_goods` - for any articles with a goods input you can also get the market goods if you also give it a country or market scope
- `shipping_lane`

# Reference
```
some_treaty_article = {
    kind = directed | mutual

    cost = 100
    relations_progress_per_day = 1.5
    relations_improvement_max = 200
    relations_improvement_min = 100

    icon = path/to/icon

    maintenance_paid_by = source_country | target_country

    flags = {
        flag_1
        flag_2
    }

    required_inputs = {
        some_input
        some_other_input
    }

    mutual_exclusions = {
        some_article_type
    }

    unlocked_by_technologies = {
        some_technology
        some_other_technology
    }

    automatically_support = {
        diplo_play_type_1
        diplo_play_type_2
    }

    non_fulfillment = {
        consequences = none | withdraw | freeze
        max_consecutive_contraventions = 3
        conditions = {
            weekly = { trigger block }
            monthly = { trigger block }
            yearly = { trigger block }
        }
    }

    source_modifier = { modifier block }
    target_modifier = { modifier block }
    mutual_modifier = { modifier block }

    visible = { trigger block }

    possible = { trigger block }

	requirement_to_maintain = { # Any number of these triggers can be added to set up the requirements to propose and maintain an article
		trigger = {} # If this evaluates to false, the article will automatically break on next update

		show_about_to_break_warning = {} # If this evaluates to true, the player will get an alert that this specific requirement to maintain is in danger of failing
	}

    can_ratify = { trigger block } # When can_ratify is checked, we also automatically check all requirements to maintain so they do not need to be duplicated here

    can_withdraw = { trigger block }

    # Valid trigger blocks depending on your inputs
    goods_valid_trigger = {}
    state_valid_trigger = {}
    strategic_region_valid_trigger = {}
    company_valid_trigger = {}
    building_type_valid_trigger = {}
    law_type_valid_trigger = {}
    country_valid_trigger = {}

    quantity_min_value = { script value block }
    quantity_max_value = { script value block }

    on_entry_into_force = { effect block } # Executes when treaty becomes active
    on_enforced = { effect block } # Executes in ADDITION to on_entry_into_force when treaty is imposed via play etc

    on_withdrawal = { effect block } # Executes when treaty is withdrawn from
    on_break = { effect block } # Executes in ADDITION to on_withdrawal when treaty is withdrawn from within the binding period

    ai = {
        # Categories exist for AI evaluations and are as follows: economy, trade, military, military_defense, ideology, expansion, power_bloc and other
        treaty_categories = {
            trade
        }

        article_ai_usage = {
            request | offer
        }

        evaluation_chance = { script value }

        # AI filter trigger blocks depending on your inputs
        goods_input_filter = {}
        state_input_filter = {}
        strategic_region_input_filter = {}
        company_input_filter = {}
        building_type_input_filter = {}
        law_type_input_filter = {}
        country_input_filter = {}

        # Value AI will pick
        quantity_input_value = { script value }

		combined_acceptance_cap_max = value
		combined_acceptance_cap_min = value

        inherent_accept_score = { script value }
        contextual_accept_score = { script value }
		proposal_weight = { script value } # Multiplier on AI score for including an article in a treaty they are composing, root is composing AI country

        wargoal_score_multiplier = { script value }
    }

    wargoal = {
        execution_priority = 21

        maneuvers = { script value }

        infamy = { script value }

        contestion_type = type
    }
}
```

# Requirements
- `kind` must be explicitly set to either directed or mutual
- `cost` must be non-negative
- `relations_improvement_min` must be non-negative
- `relations_improvement_max` must be non-negative
- `source_modifier` must be empty for mutual articles
- `target_modifier` must be empty for mutual articles
- non-fulfillment's `conditions` must be empty if `consequences = none`
- non_fulfillment's `max_consecutive_contraventions` must be zero if `consequences = none`
- non_fulfillment's `max_consecutive_contraventions` must be nonnegative
- at least one of the conditions triggers must be non-empty if `consequences` is not `none`

# Properties

## cost (default: 0)
How much is deducted from the influence pool of every party to a treaty
containing an article of this type.

## relations_improvement_min (default: 0)
## relations_improvement_max (default: 0)
How much progress is added to the relations between every party of a treaty
containing an article of this type. Progress is a percentage, when it reaches
100 it resets to 0 and relations increase or decrease by a single point.

## icon (default: empty)
A path to the icon identifying this article type

## maintenance_paid_by (default: empty)
Must be specified for directed article types, must be unspecified for mutual article types.
For directed article types, specified who pays the maintenance cost for an article of this type. Can either by the
source country or the target country.

## flags (default: empty)
A set of flags each of which determine some intrinsic behavior of the article.
The game makes use of these flags in various situations and for a variety of
tasks in code.
The behavior of each flag is hardcoded, but it is not mandatory to define any flags if you don't need them.
Articles are perfectly valid without any flags if all you need is available through the effect or modifiers.

Currently, these are the supported flags:
- `is_alliance`
- `is_defensive_pact`
- `is_gurantee_independence`
- `is_support_independence`
- `is_investment_rights`
- `is_trade_privilege`
- `is_military_access`
- `is_transit_rights`
- `is_non_colonization_agreement`
- `is_goods_transfer`
- `is_money_transfer`
- `is_monopoly_for_company`
- `is_prohibit_goods_trade_with_world_market`
- `is_no_tariffs`
- `is_no_subventions`
- `is_treaty_port`
- `is_law_commitment`
- `can_be_renegotiated`
- `can_be_enforced`
- `causes_state_transfer`

### flag behaviors

#### can_be_renegotiated
When renegotiating a treaty (note: renegotiation is different from standard
negotiation: renegotiation happens for treaties that have entered into force)
any article without this flag will not be able to be changed in any way. It
cannot be removed from the renegotiated treaty, and its inputs (if any) are
locked.

However, the on_entry_into_force effect of the article will be skipped, as this
flag implies that the article has some immediate effects that have alread
happened upon renegotiation.

#### can_be_enforced
This is what determines if an article is enforceable through a war goal or not.

## required_inputs (default: empty)
A set of inputs required by this article type, among the list of valid inputs
that article types can support.

Currently, article types support these possible inputs
- `quantity`: a raw number the meaning of which is determined by the article type
- `goods`
- `state`
- `strategic_region`
- `company`
- `building_type`
- `law_type`
- `country`

### valid_triggers
Triggers for each input that determine which subsection of that category of inputs is actually valid in this situation.
If the trigger returns true, then the specific thing we're looking at is valid

#### valid_triggers scope
The valid triggers have the following scopes available:
- `root`: Source country for the article (or potentially first otherwise)
- `scope:article`: the article in question. Do note that not all inputs have been set at this point.
- `scope:input`: the specific input we're looking at right now. E.g. if this is `state_valid_trigger` then `input` might be say `STATE_SVEALAND`
- `scope:other_country`: the other country that isn't the root

Specifically for the goods valid trigger:
- `scope:goods`: the goods input we're looking at
- `scope:market_goods`: the same goods, but as a market goods for the source country market

### Min/Max Quantity triggers
What the min or max quantity input is allowed to be for an article with that input

#### Quantity scopes
- `root`: the source country (or first if relevant)
- `scope:other_country`: the other country that isn't the root
- `scope:article`: the article in question. Do note that not all inputs have been set at this point.

ONLY for mutual articles:
- `scope:first_country` is one of the parties that would be bound by the treaty if it entered into force
- `scope:second_country` is the other party that would be bound by the treaty if it entered into force

ONLY for directed articles:
- `scope:source_country` is the specific party that would be bound as the source party of the article if the treaty entered into force
- `scope:target_country` is the specific party that would be bound as the target party of the article if the treaty entered into force

## mutual_exclusions (default: empty)
A set of article types that can't be part of a treaty at the same time.
An empty set means there are no restrictions.

## unlocked_by_technologies (default: empty)
A set of technologies that unlock this article type to be usable as part of
a treaty by a negotiating party. If a country has researched _any_ of the
technologies that are part of this set, the article type is unlocked for that
country.
An empty set means no requirements and the article type is always unlocked.

## automatically_support (default: empty)
A set of diplomatic play types that will cause one party to a treaty with this
article type to automatically support the other party.

## non_fulfillment (default: none / 0 / empty)
Data that describes what should happen when the source country of an article is not fulfilling
their end of the agreement.

### consequences (default: none)
- `none`: nothing happens
- `withdraw`: the contravening party automatically unilaterally withdraws from the
  treaty, becoming subject to any penalty that might apply
- `freeze`: causes the contravening party to have to keep up their end of the
  agreement, while the other party sees their obligations lifted, de facto
  turning the treaty into a one-sided deal until the contravening party is able
  to fulfill their end of the agreement again

### max_consecutive_contraventions (default: 0)
A party of a treaty is allowed to fail to fulfill their end of the agreement
up to and including this amount of times consecutively. If they exceed this
value, the contravening party is considered to have failed to fulfill their
end of the agreement and the consequences will apply.

This value must be nonnegative.

### conditions (default: empty)
Conditions are checked at specific time intervals:
- `weekly`: checked the first day of every week
- `monthly`: checked the first day of every month
- `yearly`: checked the first day of every year

The conditions are triggers; if the trigger succeeds, it means the source country is
contravening to the agreement. If the source country is contravening to the agreement,
their current number of contraventions increases by one, potentially causing
it to exceed `max_consecutive_contraventions` and causing the non-fulfillment
consequences to apply.

More than one condition can be specified, e.g. it's ok to have both a weekly
and a monthly condition, the weekly one will be checked every week while the
monthly one will be checked every month. Both will contribute 1 to the amount
of contraventions if the trigger for either succeeds when they are checked.
The start of a new month also corresponds with the start of a new week, so if
both weekly and monthly are specified, both triggers will be checked at the
start of every month, rather than just the monthly one.

An empty trigger is equivalent to `always = no` (meaning "never contravenes")
but due to implementation details evaluating the empty trigger is faster.

#### conditions scopes
- `root`: The source country of the article
- `scope:article`

## source_modifier (default: empty)
For directed articles, this modifier applies to the source party of the
article (in other words: it applies to the "giving" party).

## target_modifier (default: empty)
For directed articles, this modifier applies to the target party of the
article (in other words: it applies to the "receiving" party).

## mutual_modifier (default: empty)
This modifier applies to every party of the article.

## visible (default: empty)
This trigger controls the article type should be visible to the country at all.
This is the first "layer" of validation on articles

### visible scopes
Within the visible trigger, the following scope objects are accessible:
- `root`: the country this trigger is evaluated on
- This trigger is checked for both countries

## possible (default: empty)
This trigger controls whether the article type is at all possible to consider between two parties
This is the second "layer" of validation on articles.
It also automatically runs the visible trigger, so you don't need to include anything from there here

### possible scopes
Within the possible trigger, the following scope objects are accessible:
- `root`: the country this trigger is evaluated on
- `scope:other_country` refers to the opposite party in the treaty

## can_ratify (default: empty)
This trigger controls whether the parties are allowed to ratify a treaty that
contains this article type.
An empty trigger is equivalent to `always = yes`, but note that due to
implementation details evaluating the empty trigger is faster.
This is the third and last "layer" of validation for articles.
It automatically also runs both the visible and possible triggers,
so you don't need to include those here.

### can_ratify scopes
Within the can_ratify trigger, the following scope objects are accessible:
- `root`: the country this trigger is evaluated on
- `scope:article` the article in question
- `scope:treaty` refers to the treaty that is being negotiated

ONLY for mutual articles:
- `scope:first_country` is one of the parties that would be bound by the treaty if it entered into force
- `scope:second_country` is the other party that would be bound by the treaty if it entered into force

ONLY for directed articles:
- `scope:source_country` is the specific party that would be bound as the source party of the article if the treaty entered into force
- `scope:target_country` is the specific party that would be bound as the target party of the article if the treaty entered into force

## on_entry_into_force (default: empty)
A treaty enters into force once all parties have ratified it. This effect is
executed when that happens.

### on_entry_into_force scopes
Within the `on_entry_into_force` effect, the following scope objects are accessible:
- `scope:treaty_options` are the parameters (settings) that made up the treaty
- `scope:article_options` are the parameters (settings) that made up the treaty article

## can_withdraw (default: empty)
Determines if a country is allowed to withdraw from a treaty. Defaults to true.

### can_withdraw scope
- `scope:withdrawing_country`
- `scope:non_withdrawing_country`

ONLY for mutual articles:
- `scope:first_country` is one of the parties that would be bound by the treaty if it entered into force
- `scope:second_country` is the other party that would be bound by the treaty if it entered into force

ONLY for directed articles:
- `scope:source_country` is the specific party that would be bound as the source party of the article if the treaty entered into force
- `scope:target_country` is the specific party that would be bound as the target party of the article if the treaty entered into force

## on_withdrawal (default: empty)
A treaty can only be withdrawn from unilaterally, because a treaty that every
party agrees to no longer honor is said to be dissolved.
This effect applies when a party withdraws from a treaty, immediately before
the withdrawal takes effect.
Do not take actions that can lead to the addition / removal of treaties or
addition / removal of articles from treaties during this effect.

### on_withdrawal scopes
Within the on_withdrawal effect, the following scope objects are accessible:
- `scope:treaty_options` are the parameters (settings) that made up the treaty which `scope:withdrawing_country` is withdrawing from
- `scope:article` refers to the article in question
- `scope:withdrawing_country` is the party that is withdrawing from the treaty
- `scope:non_withdrawing_country` is the party that is not withdrawing from the treaty

## AI block (default: empty / 0 / 0)
This data controls the ai willingness to entertain treaties containing this
article type, and how much they value it

### evaluation_chance (default: 0)
Determines how likely the AI is to add this article to a treaty when trying to build a proposal.
Gets evaluated before anything else, if 0 the AI will never use it.
Only has root scope for the country we're looking at.

### input_filters
Filters for each input that determine which subsection of that category of inputs the AI would actually be ok with picking in this situation.
If the trigger returns true, then the specific thing we're looking at is included for consideration

#### input_filters scope
The input filters have the following scopes available:
- `root`: Source country for the article (or potentially first otherwise)
- `scope:article`: the article in question. Do note that not all inputs have been set at this point.
- `scope:input`: the specific input we're looking at right now. E.g. if this is `state_input_filter` then `input` might be say `STATE_SVEALAND`
- `scope:other_country`: the other country that isn't the root

Specifically for the goods input filter:
- `scope:goods`: the goods input we're looking at
- `scope:market_goods`: the same goods, but as a market goods for the source country market

### Quantity script value
What quantity input the AI will pick in this situation

#### Quantity scopes
- `root`: the source country (or first if relevant)
- `scope:other_country`: the other country that isn't the root
- `scope:article`: the article in question. Do note that not all inputs have been set at this point.

### Article Usage
If AI will offer or request an article. Can pick multiple
- `none`
- `will_offer`
- `will_request`

### Treaty Categories
Broad groups of types of treaties that the AI will prioritize when trying to propose treaties.
The weights for which one the AI prefers are set in AI strategies
The available options are:
- `economy`
- `trade`
- `military`
- `military_defense`
- `ideology`
- `expansion`
- `power_bloc`
- `other`
- `none`

###	combined_acceptance_cap_max (default: empty)
Integer. Limits the maximum acceptance gained from articles of this type being added to a treaty

### combined_acceptance_cap_min (default: empty)
Integer. Establishes the minimum acceptance gained from articles of this type being added to a treaty

### inherent_accept_score (default: 0)
A script value determining the reasons for the AI to accept or reject a treaty.
Does not get reevaluated every time the AI tries to add an article, so it's more performant to put as much as possible here.

#### inherent_accept_score scopes
- `root`: The country we're looking to check the acceptance on.
- `scope:article`: The article in question with whatever inputs it might have

ONLY for mutual articles:
- `scope:first_country` is one of the parties that would be bound by the treaty if it entered into force
- `scope:second_country` is the other party that would be bound by the treaty if it entered into force

ONLY for directed articles:
- `scope:source_country` is the specific party that would be bound as the source party of the article if the treaty entered into force
- `scope:target_country` is the specific party that would be bound as the target party of the article if the treaty entered into force

### contextual_accept_score (default: 0)
A script value determining the reasons for the AI to accept or reject a treaty but with access to the treaty itself
Gets reevaluated every time the AI adds something to its own proposals, so should be avoided if you don't need the treaty scope.

#### contextual_accept_score scopes
- `root`: The country we're looking to check the acceptance on
- `scope:article`: The article in question with whatever inputs it might have
- `scope:treaty`: The current treaty with any articles that might have been added to it

ONLY for mutual articles:
- `scope:first_country` is one of the parties that would be bound by the treaty if it entered into force
- `scope:second_country` is the other party that would be bound by the treaty if it entered into force

ONLY for directed articles:
- `scope:source_country` is the specific party that would be bound as the source party of the article if the treaty entered into force
- `scope:target_country` is the specific party that would be bound as the target party of the article if the treaty entered into force

#### NOTE:
`inherent_accept_score` and `contextual_accept_score` are added together to create the final acceptance value but maths conducted in one script value does not apply to the other and vice versa

### wargoal_score_multiplier (default: 0)
Script value. A multiplier added to the AI acceptance determining how likely it is to pursue this article as a wargoal

#### wargoal_score_multipler scopes:
- `root` - the country we're looking at
- `scope:article` refers to the article that is being enforced

ONLY for mutual articles:
- `scope:first_country` is one of the parties that would be bound by the treaty if it entered into force
- `scope:second_country` is the other party that would be bound by the treaty if it entered into force

ONLY for directed articles:
- `scope:source_country` is the specific party that would be bound as the source party of the article if the treaty entered into force
- `scope:target_country` is the specific party that would be bound as the target party of the article if the treaty entered into force

### Wargoal data
#### Execution Priority
An integer. Higher priority wargoals are executed later.

#### Constestion Type
One of the following:
- `control_target_state`
- `control_target_country_capital`
- `control_any_target_country_state`
- `control_own_state`
- `control_own_capital`
- `control_all_own_states`
- `control_all_target_country_claims`

#### Scopes
The scopes available for the maneuvers and infamy script values are the following always:
- `root`: War goal holder country
- `scope:target_country`

And the following depending on relevant inputs:
- `scope:quantity`
- `scope:country`
- `scope:company`
- `scope:state`
- `scope:region`
- `scope:building`
- `scope:law`
- `scope:goods`
- `scope:market_goods`

#### Maneuvers
Script value

#### Infamy
Script value
