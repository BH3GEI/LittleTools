decimal_values = [27979, 35797]

text = ''.join(chr(decimal) for decimal in decimal_values)

print(text)

chinese_text = '测试'

decimal_values = [ord(char) for char in chinese_text]

print(decimal_values)

encoded_text = ''.join(f"#{ord(char)}" for char in chinese_text)

print(encoded_text)
