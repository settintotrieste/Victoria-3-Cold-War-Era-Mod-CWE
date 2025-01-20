import os
import time
import argparse
from tqdm import tqdm
from googletrans import Translator, LANGUAGES

# Please install "tqdm" and "googletrans" in advance.
# pip install tqdm googletrans

translator = Translator()
translatorCache = {}


def hasAlphabets(string):
    for ch in string:
        x = ord(ch)
        if ord("A") <= x and x <= ord("Z"):
            return True
        if ord("a") <= x and x <= ord("z"):
            return True
    return False


def getLineN(filepath):
    count = 0
    with open(filepath, "r", encoding="utf-8") as f:
        for line in f:
            count += 1
    return count


def separateTextAndCommands(rawText) -> tuple[str, str]:
    # $foo$ and [var] are commands which should not be translated
    texts = [""]
    commands = [""]
    isCommand = False
    commandBrackets = {"$": "$", "[": "]", "#": "!"}
    commandPrefix = None
    for ch in rawText:
        if not isCommand and ch in commandBrackets:
            # start of command
            isCommand = True
            commandPrefix = ch
            texts.append("")
            commands[-1] += ch
            continue
        elif isCommand and ch == commandBrackets[commandPrefix]:
            # end of command
            isCommand = False
            commands[-1] += ch
            commands.append("")
            continue
        if isCommand:
            commands[-1] += ch
        else:
            texts[-1] += ch
    return texts, commands


def mergeTextsAndCommands(texts, commands):
    result = ""
    while len(texts) > 0 or len(commands) > 0:
        if len(texts) > 0:
            result += texts.pop(0)
        if len(commands) > 0:
            result += commands.pop(0)
    return result


def translate(rawText, dstLang, srcLang="english") -> str:
    if rawText in translatorCache:
        return translatorCache[rawText]
    try:
        x = int(rawText.split(" ")[-1])
        rawText = " ".join(rawText.split(" ")[:-1])
        return translate(rawText, dstLang, srcLang) + " " + str(x)
    except:
        pass
    while True:
        try:
            texts, commands = separateTextAndCommands(rawText)
            translatedTexts = []
            for text in texts:
                if not hasAlphabets(text):
                    translatedText = text
                else:
                    print(text)
                    translatedText = translator.translate(text, dstLang, srcLang).text
                translatedTexts.append(translatedText)
            newline = mergeTextsAndCommands(translatedTexts, commands)
            translatorCache[rawText] = newline
            return newline
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
                translated = translate(rawtext, dstLang, srcLang)
                fields[1] = translated
        newline = '"'.join(fields)
        outFile.write(newline)
        pbar.update(1)
    pbar.close()

    outFile.close()
    inFile.close()


if __name__ == "__main__":
    # print(list(LANGUAGES.values())) # Supported Languages

    # All you need to do is set these three variables below.
    fileCommonName = "0_general_l"  # If you want to translate 0_events_je_l_english.yml, set "0_events_je_l"
    srcLang = "english"  # Source Language
    dstLang = "japanese"  # Target Language

    translateCWE(fileCommonName, dstLang, srcLang)
