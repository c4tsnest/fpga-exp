
from PIL import Image

INPUT_BMP = "backp1.bmp"   # 入力画像
OUTPUT_HEX = "image.hex"  # 出力ファイル
WIDTH = 64                # 幅（画像サイズに合わせて変更）
HEIGHT = 64               # 高さ

img = Image.open(INPUT_BMP).convert("RGB")
img = img.resize((WIDTH, HEIGHT))

with open(OUTPUT_HEX, "w") as f:
    for y in range(HEIGHT):
        for x in range(WIDTH):
            r, g, b = img.getpixel((x, y))
            # RGB333形式 (R3G3B3)
            r3 = r >> 5   # 上位3bit
            g3 = g >> 5
            b3 = b >> 5
            rgb333 = (r3 << 6) | (g3 << 3) | b3
            f.write(f"{rgb333:03x}\n")

