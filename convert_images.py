from PIL import Image
import pillow_heif
import os

pillow_heif.register_heif_opener()

pairs = [
    ("class diagram.png", "class-diagram.png"),
    ("use case diag.png", "use-case-diagram.png"),
    ("arch.png", "architecture-layers.png"),
]

os.chdir("images")
for src, dst in pairs:
    im = Image.open(src)
    im.load()
    if im.mode not in ("RGB", "RGBA"):
        im = im.convert("RGBA")
    im.save(dst, format="PNG", optimize=True)
    with open(dst, "rb") as f:
        sig = f.read(8).hex(" ")
    print(f"{src} ({im.size[0]}x{im.size[1]}) -> {dst} sig={sig} size={os.path.getsize(dst)}")