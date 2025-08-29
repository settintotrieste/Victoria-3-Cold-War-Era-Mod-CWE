	principle_group_key = {
		blocking_identity = <identity key> 		# Which identity blocks picking this Principle Group. Can be repeated
		unlocking_identity = <identity key> 	# Which identity unlocks this Principle Group. Can be repeated
		primary_for_identity = <identity key>	# Specifies Identities for which Principle Groups should be considered Primary

		# The order of principles defines each principle's Level
		levels = {
			principle_name_1	# Keys of principle in /power_bloc_principles/
			principle_name_2
			principle_name_3
			...
		}
	}
