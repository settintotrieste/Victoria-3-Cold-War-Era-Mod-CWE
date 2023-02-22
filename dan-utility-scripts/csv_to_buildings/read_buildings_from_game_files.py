import os
import re
import csv

# set the folder path and URL
folder_path = os.path.join("..","..", "1. CWE Base Mod", "Cold War Era Mod (CWE)", "common", "buildings")

# create a list to store the results
results = []

# iterate over all files in the folder
for file in os.listdir(folder_path):
    if file.endswith(".txt"):
        # read the file contents
        with open(os.path.join(folder_path, file), "r") as f:
            contents = f.read()
            
            # search for the text pattern
            pattern = r"building_(\w+)\s*=\s*{"
            matches = re.findall(pattern, contents)
            
            # add any matches to the results list
            for match in matches:
                results.append(match)
                
# write the results to a CSV file
with open("all_building_names.csv", "w", newline="") as f:
    writer = csv.writer(f)
    for result in results:
        writer.writerow([result])
