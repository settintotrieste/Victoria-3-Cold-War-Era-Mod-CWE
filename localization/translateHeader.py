import os
from tqdm import tqdm
from multiprocessing import Pool, freeze_support, RLock
import argostranslate.package
import argostranslate.translate

# Please install "tqdm" and "argostranslate" in advance.
# pip install tqdm argostranslate

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


def separateTextAndSymbols(rawText) -> tuple[str, str]:
    # $foo$, [var] and #foobar#! are symbols which should not be translated
    texts = [""]
    symbols = [""]
    isCommand = False
    commandBrackets = {"$": "$", "[": "]", "#": "!"}
    commandPrefix = None
    for ch in rawText:
        if not isCommand and ch in commandBrackets:
            # start of command
            isCommand = True
            commandPrefix = ch
            texts.append("")
            symbols[-1] += ch
            continue
        elif isCommand and ch == commandBrackets[commandPrefix]:
            # end of command
            isCommand = False
            symbols[-1] += ch
            symbols.append("")
            continue
        if isCommand:
            symbols[-1] += ch
        else:
            texts[-1] += ch
    return texts, symbols


def mergeTextsAndSymbols(texts, symbols):
    result = ""
    while len(texts) > 0 or len(symbols) > 0:
        if len(texts) > 0:
            result += texts.pop(0)
        if len(symbols) > 0:
            result += symbols.pop(0)
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
    translatedText = rawText
    if hasAlphabets(rawText):
        texts, symbols = separateTextAndSymbols(rawText)
        if len(texts) > texts.count(""):
            langs = argostranslate.translate.get_installed_languages()
            from_code = [x.code for x in langs if x.name.lower() == srcLang][0]
            to_code = [x.code for x in langs if x.name.lower() == dstLang][0]
            newTexts = (
                argostranslate.translate.translate(
                    " XXX ".join(texts), from_code, to_code
                )
                .replace("xxx", "XXX")
                .split("XXX")
            )
            translatedText = mergeTextsAndSymbols(newTexts, symbols)
    translatorCache[rawText] = translatedText
    return translatedText


def translateCWE(
    fileCommonName, dstLang, srcLang="english", overwriteFlag=False, position=0
):
    inPath = os.path.join(srcLang, f"{fileCommonName}_{srcLang}.yml")
    outPath = os.path.join(dstLang, f"{fileCommonName}_{dstLang}.yml")
    if not overwriteFlag and os.path.exists(outPath):
        print(f"{outPath} exists. Skipping...")
        return

    print(f"Translating {inPath} ({srcLang}) -> {outPath} ({dstLang})")
    inFile = open(inPath, "r", encoding="utf-8")
    outFile = open(outPath, "w", encoding="utf-8")

    pbar = tqdm(desc=fileCommonName, total=getLineN(inPath), position=position)
    for line in inFile:
        pbar.update(1)
        if not hasAlphabets(line) or line.removeprefix(" ")[0] == "#":
            outFile.write(line)
            continue
        fields = line.split('"')
        if len(fields) == 3:
            rawtext = fields[1]
            translated = translate(rawtext, dstLang, srcLang)
            fields[1] = translated
        elif len(fields) == 1:
            fields[0] = fields[0].replace(f"l_{srcLang}", f"l_{dstLang}")
        newline = '"'.join(fields)
        outFile.write(newline)
    pbar.close()

    outFile.close()
    inFile.close()


def translateCWETask(input):
    position, fileCommonName, dstLang, srcLang = input
    translateCWE(fileCommonName, dstLang, srcLang, position=position)


def translateCWEParalell(fileCommonNames, dstLang, srcLang):
    input = [
        (position, fileCommonNames[position], dstLang, srcLang)
        for position in range(len(fileCommonNames))
    ]
    freeze_support()
    with Pool(initializer=tqdm.set_lock, initargs=(RLock(),)) as p:
        p.map(translateCWETask, input)


def argosInit(srcLang, dstLang):
    print("Downloading Argos Package...")
    argostranslate.package.update_package_index()
    available_packages = argostranslate.package.get_available_packages()
    try:
        package_to_install = next(
            filter(
                lambda x: x.from_name.lower() == srcLang.lower()
                and x.to_name.lower() == dstLang,
                available_packages,
            )
        )
    except:
        raise ModuleNotFoundError(f"{srcLang} -> {dstLang} not supported.")
    argostranslate.package.install_from_path(package_to_install.download())
