from translateHeader import argosInit, translateCWEParalell

if __name__ == "__main__":

    # All you need to do is set three variables below.

    fileCommonNames = [
        "0_buildings_l",  # If you want to translate 0_buildings_l_english.yml, set "0_buildings_l"
        "0_countries_l",
        "0_events_je_l",
        "0_general_l",
        "0_hub_names_l",
        "0_laws_l",
        "0_leaders_l",
        "0_states_l",
        "0_techs_l",
    ]
    srcLang = "english"  # Source Language
    dstLang = "japanese"  # Target Language
    argosInit(srcLang, dstLang)
    translateCWEParalell(fileCommonNames, dstLang, srcLang)
