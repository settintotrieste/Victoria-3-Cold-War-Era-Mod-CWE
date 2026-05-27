
Discrimination traits have a type and potentially a trait group. The type can be heritage, language or tradition. Heritage and Language type traits need to have a defined trait_group with a matching type as well. Tradition traits should not have a trait group defined. Religious heritage traits work the same as Cultural heritage traits.

Examples:

heritage_abyssinian = {
	type = heritage
	trait_group = heritage_group_african
}

language_gbe = {
	type = language
	trait_group = language_group_volta_niger
}

tradition_rumelian = {
	type = tradition
}

heritage_indigenous = {
	type = heritage
	trait_group = heritage_group_naturalistic
}
