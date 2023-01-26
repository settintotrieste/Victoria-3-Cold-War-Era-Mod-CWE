from PIL import Image

country_tag = "GBR"
image_path = "colors.png"

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

colors = [color.upper().replace('#', 'x') for color in hex_colors(image_path)]
colors_string = " ".join(colors).replace('x000000 ','')
output = f'create_state = {{\n\tcountry = c:{country_tag}\n\towned_provinces = {{ {colors_string} }}\n}}'
print(output)