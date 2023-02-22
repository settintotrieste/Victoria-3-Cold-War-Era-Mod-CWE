import csv
import os

# Read the filename and extract the SPA prefix from it
filename = "CWE-buildings - USA.csv"
prefix = os.path.splitext(os.path.basename(filename))[0].split(' - ')[1]

# Create the dictionary to store the building data
BUILDINGS = {}

# Open the CSV file and read the data
with open(filename) as csvfile:
    reader = csv.DictReader(csvfile)
    for row in reader:
        state = row.pop('State')

        # Create the dictionary to store the building data for this state
        state_buildings = {}

        for building, level in row.items():
            # Skip any empty cells
            if not level or level == "0":
                continue

            # Create a dictionary to store the data for this building
            building_data = {
                'building': building.lower().replace(' ', '_'),
                'level': int(level)
            }

            # Add the building data to the state_buildings dictionary
            state_buildings[f'create_building_{building.lower().replace(" ", "_")}'] = building_data

        # Add the state_buildings dictionary to the BUILDINGS dictionary
        BUILDINGS[f's:STATE_{state.upper()}'] = {
            f'region_state:{prefix.upper()}': state_buildings
        }

# Print the generated code
for state, data in BUILDINGS.items():
    print(f'{state}={{')
    for region, buildings in data.items():
        print(f'\t{region}={{')
        for building, building_data in buildings.items():
            print(f'\t\t{building}={{')
            for key, value in building_data.items():
                print(f'\t\t\t{key}={value}')
            print('\t\t}')
        print('\t}')
    print('}\n')
