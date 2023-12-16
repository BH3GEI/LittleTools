decimal_values = [32472, 22270, 26085, 24535, 65292, 21452, 20987, 21487, 20197, 26597, 30475, 35814, 32454, 21382, 21490, 35760, 24405]

text = ''.join(chr(decimal) for decimal in decimal_values)

print(text)

chinese_text = '测试'

decimal_values = [ord(char) for char in chinese_text]

print(decimal_values)

encoded_text = ''.join(f"#{ord(char)}" for char in chinese_text)

print(encoded_text)
