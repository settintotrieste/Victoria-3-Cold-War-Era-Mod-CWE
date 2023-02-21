import pyperclip

# This script reads your clipboard, assuming you selected a single pop, splits it into two and adds the second religion you specified
# you must "pip install pyperclip" in your command prompt before using

sub_religion = "catholic"
sub_religion_fraction = 0.05
main_religion_fraction = 1-sub_religion_fraction

# Get the contents of the clipboard
clipboard_content = pyperclip.paste()

print(f'{clipboard_content}')

# Split the text into two parts
lines = clipboard_content.strip().replace("\t","").replace("\n","").split('\r')
print(f"lines={lines}")
part_culture = lines[1]
part_size = lines[2]

# Calculate the sizes
print(f"part_size={part_size}")
total_size = int(part_size.split('size = ')[1])
part1_size = int(total_size * main_religion_fraction)
part2_size = int(total_size * sub_religion_fraction)

# Update the parts with the calculated sizes and religion key
part1 = f'\n	create_pop = {{\n		{part_culture}\n\t	size = {part1_size}\n	}}'
part2 = f'	create_pop = {{\n		{part_culture}\n\t	religion = {sub_religion}\n\t	size = {part2_size}\n	}}'

# Combine the parts into a single string
result = f'{part1}\n{part2}'

# Write the updated text back to the clipboard
pyperclip.copy(result)

# Print the result to the console
print(result)
