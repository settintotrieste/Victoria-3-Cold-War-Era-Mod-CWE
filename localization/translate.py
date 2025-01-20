from googletrans import Translator
import time

translator = Translator()

cache = {}


def translate(rawtext) -> str:
    if rawtext in cache:
        return cache[rawtext]
    try:
        x = int(rawtext.split(" ")[-1])
        rawtext = " ".join(rawtext.split(" ")[:-1])
        return translate(rawtext) + " " + str(x)
    except:
        pass
    while True:
        try:
            translated = translator.translate(rawtext, "ja", "en")
            cache[rawtext] = translated.text
            return translated.text
        except:
            print("Error occured. Waiting for 5 secs...")
            time.sleep(5)


dstLang = "japanese"
fileCommonName = "0_buildings_l"
filepathIn = f"english\\{fileCommonName}_english.yml"
filepathOut = f"{dstLang}\\{fileCommonName}_{dstLang}.yml"

with open(filepathIn, "r", encoding="utf-8") as f:
    with open(filepathOut, "w", encoding="utf-8") as of:
        for line in f:
            fields = line.split('"')
            if len(fields) == 3:
                rawtext = fields[1]
                print(rawtext)
                if len(rawtext.removeprefix(" ")) > 0:
                    translated = translate(rawtext)
                    fields[1] = translated
            newline = '"'.join(fields)
            print(newline)
            of.write(newline)
