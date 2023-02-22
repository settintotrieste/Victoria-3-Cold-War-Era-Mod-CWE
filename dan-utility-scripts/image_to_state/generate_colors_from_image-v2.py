import os
from PIL import Image

def hex_colors(image_path):
    with Image.open(image_path) as im:
        im = im.convert("RGB")
        width, height = im.size
        pixels = im.load()
        hex_colors = set()
        for x in range(width):
            for y in range(height):
                r, g, b = pixels[x, y]
                hex_colors.add('#{:02x}{:02x}{:02x}'.format(r, g, b))
        return list(hex_colors)

output_dict = {}
for filename in os.listdir():
    if filename.endswith(".png") and filename.startswith("STATE_"):
        state_name = filename.split("-")[0].replace(".png","")
        country_tag = filename[-7:-4]
        colors = [color.upper().replace('#', 'x') for color in hex_colors(filename)]
        colors_string = "\n\t\t\t".join(" ".join(colors[i:i+20]) for i in range(0, len(colors), 20)).replace('x000000 ','')
        if state_name not in output_dict:
            output_dict[state_name] = []
        output_dict[state_name].append(f'create_state = {{\n\t\tcountry = c:{country_tag}\n\t\towned_provinces = {{\n\t\t\t{colors_string}\n\t\t}}\n\t}}')

for state_name in output_dict:
    print(f"s:{state_name} = {{\n\t{' '.join(output_dict[state_name])}\n}}")
