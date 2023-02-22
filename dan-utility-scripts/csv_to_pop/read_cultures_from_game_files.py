import os
import re
import csv

# set the folder path and URL
mod_path = os.path.join("..","..", "1. CWE Base Mod", "Cold War Era Mod (CWE)", "common", "buildings")
vanilla_path = os.path.realpath('D:\SteamLibrary\steamapps\common\Victoria 3\game\common\cultures')

folder_path = vanilla_path

# create a list to store the results
results = []

# iterate over all files in the folder
for file in os.listdir(folder_path):
    if file.endswith(".txt"):
        # read the file contents
        with open(os.path.join(folder_path, file), "r") as f:
            lines = f.readlines()
            for line in lines:
                if not line.startswith("\t") and "=" in line:
                    pattern = r"^\s*([a-zA-Z_]+)\s*="
                    match = re.search(pattern, line)
                    if match:
                        results.append(match.group(1))

print(results)

# write the results to a CSV file
with open("all_culture_names.csv", "w", newline="") as f:
    writer = csv.writer(f)
    for result in results:
        writer.writerow([result])
