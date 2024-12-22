# Reference
```
your_hierarchy_key = {
    is_default = yes / no
    pop_criteria = {
        <trigger conditions>
    }
}
```

# Requirements
At least one valid social hierarchy needs to be scripted for the game to
function.

Exactly one social hierarchy must be marked as default. If no hierarchy is
explicitly marked as default, the game will consider the first one (in top to
bottom scripted order) as default (an error will be generated).

If multiple hierarchies are marked as default, the first one (in top to bottom
scripted order) that is marked as default will be the one that the game
considers as the default hierarchy (an error will be generated).

Social hierarchies work in combination with social classes, check the
documentation for those too to have a better picture.

# Example
```
some_hierarchy = {
    is_default = yes
    pop_criteria = {
        always = yes
    }
}

other_hierarchy = {
    pop_criteria = {
        has_pop_religion = hindu
        culture = {
            has_discrimination_trait = south_asian_heritage
        }
    }
}
```

In this example, `some_hierarchy` is the default one, and acts as both the
default hierarchy for countries that don't have an explicit hierarchy scripted,
or as a fallback hierarchy to use for pops that don't meet the criteria to be
subject to the country's de-jure hierarchy (more on this later).

# List of scriptable keys
## is_default
Determines whether this is the default hierarchy. Countries that don't have
a different hierarchy scripted usee this hierarchy implicitly.

It is also used as a fallback when a pop cannot be subject to the de-jure
hierarchy of the country they live in. See the pop_criteria section for
additional information.

## pop_criteria
This is a trigger that determines whether a pop can be subject to the
hierarchy.

For example, the `other_hierarchy` in the example section has a `pop_criteria`
trigger that sanctions that only pops following the hindu faith and that are of
south asian heritage can be subject to said hierarchy.

When a pop lives in a country with a social hierarchy that cannot apply to
the pop, the pop will instead be subject to the default hierarchy, which acts
as a fallback.

For example, if a british catholic pop was living in a country that uses the
`other_hierachy` hierarchy, they couldn't be subject to it. Therefore, this
pop would instead be subject to `some_hierarchy`, as it is set as default and
acts as a fallback in this case.

Note that, because of this, the default hierarchy's `pop_criteria` trigger is
not really checked. It is suggested to just script it as `always = yes`,
as that is de facto what happens and avoid confusion.

To reiterate: even scripting `always = no` as the default hierarchy's
`pop_criteria` will not have any effect: pops _will_ fall back to the default
hierarchy when their country's hierarchy doesn't apply to them.
