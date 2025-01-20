from googletrans import Translator

str = "これはバナナです。"  # 翻訳したい文字

translator = Translator()
trans_text = translator.translate(str)  # デフォルトでは英語へ変換
print(trans_text.text)
