from pathlib import Path

from PIL import Image

src = Path(r"C:\Users\HP\.cursor\projects\c-MyProjects-builza\assets\BUILZA_Brand_Logo_and_App_Icon-ccc284cc-f5f4-42ba-9330-8c486471344e.jpg")
out_dir = Path(r"C:\MyProjects\builza\assets\brand")
out_dir.mkdir(parents=True, exist_ok=True)

im = Image.open(src).convert("RGBA")
w, h = im.size
pix = im.load()


def is_ink(p, threshold=245):
    r, g, b, _a = p
    return not (r > threshold and g > threshold and b > threshold)


row_counts = [sum(1 for x in range(w) if is_ink(pix[x, y])) for y in range(h)]
split_y = min(range(int(h * 0.35), int(h * 0.65)), key=lambda y: row_counts[y])


def make_transparent(cropped):
    data = list(cropped.getdata())
    cropped.putdata(
        [
            (r, g, b, 0) if r > 248 and g > 248 and b > 248 else (r, g, b, a)
            for r, g, b, a in data
        ]
    )
    return cropped


def crop_box(y0, y1, min_row_ink=40, pad=4):
    active = [y for y in range(y0, y1) if row_counts[y] >= min_row_ink]
    top, bottom = active[0], active[-1]
    xs = []
    for y in range(top, bottom + 1):
        for x in range(w):
            if is_ink(pix[x, y]):
                xs.append(x)
    left, right = min(xs), max(xs)
    box = (
        max(0, left - pad),
        max(0, top - pad),
        min(w, right + pad + 1),
        min(h, bottom + pad + 1),
    )
    return make_transparent(im.crop(box))


logo = crop_box(0, split_y, min_row_ink=20, pad=10)
# Skip the leftover wordmark fragment just below the gap.
icon = crop_box(split_y + 24, h, min_row_ink=80, pad=2)

# Center-crop icon to a square around the rounded app tile.
iw, ih = icon.size
side = min(iw, ih)
icon = icon.crop(((iw - side) // 2, 0, (iw - side) // 2 + side, side)) if iw > ih else icon

logo.save(out_dir / "builza_logo.png", "PNG")
icon.save(out_dir / "builza_icon.png", "PNG")
print("logo", logo.size, "icon", icon.size)

icon_bg = Image.new("RGBA", icon.size, (11, 45, 92, 255))
icon_bg.alpha_composite(icon)
square = icon_bg.convert("RGB")


def save_square(path, size):
    Path(path).parent.mkdir(parents=True, exist_ok=True)
    square.resize((size, size), Image.Resampling.LANCZOS).save(path, "PNG")


web = Path(r"C:\MyProjects\builza\web")
save_square(web / "favicon.png", 48)
save_square(web / "icons" / "Icon-192.png", 192)
save_square(web / "icons" / "Icon-512.png", 512)
save_square(web / "icons" / "Icon-maskable-192.png", 192)
save_square(web / "icons" / "Icon-maskable-512.png", 512)

android = Path(r"C:\MyProjects\builza\android\app\src\main\res")
for folder, size in {
    "mipmap-mdpi": 48,
    "mipmap-hdpi": 72,
    "mipmap-xhdpi": 96,
    "mipmap-xxhdpi": 144,
    "mipmap-xxxhdpi": 192,
}.items():
    save_square(android / folder / "ic_launcher.png", size)

windows_icon = Path(r"C:\MyProjects\builza\windows\runner\resources\app_icon.ico")
if windows_icon.parent.exists():
    square.resize((256, 256), Image.Resampling.LANCZOS).save(
        windows_icon, format="ICO", sizes=[(256, 256)]
    )

print("wrote brand assets")
