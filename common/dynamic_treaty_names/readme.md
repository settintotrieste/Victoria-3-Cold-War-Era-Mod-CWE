# Notes

## party, not party
Unless otherwise specified, in this document any mention of "party" or
"parties" refers to a party or parties to a treaty, not to political parties.

# Reference
```
some_dyanmic_name = {
    trigger = { trigger block }
    weight = { script value block }
}
```

# Properties

## Key
The key of the dynamic name (the `some_dynamic_name` part in the reference) is
used as the localization key for the dynamic name. So there needs to be a
corresponding `some_dynamic_name: "localization"` entry in one of the
localization files.

## trigger (default: empty)
This trigger determines whether this name can be chosen for a given treaty.
An empty trigger is equivalent to `always = yes`, but due to technical reasons
an empty trigger is evaluated faster than an `always = yes` trigger.

### trigger scopes
Within the `trigger` trigger, the following scope objects are accessible:
- `root` is a `treaty_options` scope, holding various information about a treaty, before the treaty is created

Examples of information accessible from a `treaty_options` scope:
- `first_country` is one of the parties of the potential treaty
- `second_country` is the other party of te potential treaty
- `any_scope_article_option` is a scriptlist for evaluation of the article options of the potential treaty

## weight (default: 1)
This script values determines an absolute weight value for a given dynamic name.
Names with higher weights are more likely to be picked.

### weight scopes
The `root` scope of the weight value is the same `treaty_options` scope that
is the root of `trigger`.
