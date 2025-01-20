import os
import time
import argparse
from tqdm import tqdm
from googletrans import Translator, LANGUAGES

# Please install "tqdm" and "googletrans" in advance.
# pip install tqdm googletrans

translator = Translator()
translatorCache = {}


def getLineN(filepath):
    count = 0
    with open(filepath, "r", encoding="utf-8") as f:
        for line in f:
            count += 1
    return count


def translateText(rawtext, dstLang, srcLang="english") -> str:
    if rawtext in translatorCache:
        return translatorCache[rawtext]
    try:
        x = int(rawtext.split(" ")[-1])
        rawtext = " ".join(rawtext.split(" ")[:-1])
        return translateText(rawtext, dstLang, srcLang) + " " + str(x)
    except:
        pass
    while True:
        try:
            translated = translator.translate(rawtext, dstLang, srcLang)
            translatorCache[rawtext] = translated.text
            return translated.text
        except:
            print("Error occured. Waiting for 5 secs...")
            time.sleep(5)


def translateCWE(fileCommonName, dstLang, srcLang="english", overwriteFlag=False):
    inPath = os.path.join(srcLang, f"{fileCommonName}_{srcLang}.yml")
    outPath = os.path.join(dstLang, f"{fileCommonName}_{dstLang}.yml")

    if not overwriteFlag and os.path.exists(outPath):
        print(f"{outPath} exists. Skipping...")
        return

    print(f"Translating {inPath} ({srcLang}) -> {outPath} ({dstLang})")
    inFile = open(inPath, "r", encoding="utf-8")
    outFile = open(outPath, "w", encoding="utf-8")

    pbar = tqdm(total=getLineN(inPath))
    for line in inFile:
        fields = line.split('"')
        if len(fields) == 3:
            rawtext = fields[1]
            if len(rawtext.removeprefix(" ")) > 0:
                translated = translateText(rawtext, dstLang, srcLang)
                fields[1] = translated
        newline = '"'.join(fields)
        outFile.write(newline)
        pbar.update(1)
    pbar.close()

    outFile.close()
    inFile.close()


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Translator for Cold War Era Mod")
    parser.add_argument("commonName", help="", default="0_general_l")
    parser.add_argument(
        "dstLang", help="Target language", choices=list(LANGUAGES.values())
    )
    parser.add_argument(
        "--srcLang",
        help="Source language",
        default="english",
        choices=list(LANGUAGES.values()),
    )
    args = parser.parse_args()
    # All you need to do is set these three variables below.
    fileCommonName = "0_general_l"
    srcLang = "english"
    dstLang = "japanese"

    translateCWE(args.commonName, args.dstLang, args.srcLang)
