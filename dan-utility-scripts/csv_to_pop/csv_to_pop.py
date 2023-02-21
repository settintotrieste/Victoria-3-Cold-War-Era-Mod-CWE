import csv
import os

def convert_csv_to_output(filename):
    newline = "\n"
    fourTabs="\t\t\t\t"
    region = filename.split('_')[0].upper()
    output = []
    with open(filename, 'r') as f:
        reader = csv.reader(f, delimiter=';')
        header = next(reader)

        for row in reader:
            state, *populations = row
            state = "STATE_" + state.upper().replace(" ","_")

            create_pop_blocks = "\n".join(
                [f"""\t\t\tcreate_pop = {{
                culture = {culture.split()[0]}
                {f"{newline}{fourTabs}religion = {culture.split()[1]}" if len(culture.split()) > 1 else ""}
                size = {int(float(population.replace('.', '')))}
                {f"{newline}{fourTabs}" if int(float(population.replace('.', ''))) > 0 else ""}
            }}""" for culture, population in zip(header[1:], populations) if int(float(population.replace('.', ''))) > 0])

            output.append(f"""\ts:{state} = {{
\t\tregion_state:{region} = {{
{create_pop_blocks}
\t\t}}
\t}}""")

    return "\n".join(output)

if __name__ == '__main__':
    pop_files = [f for f in os.listdir() if f.endswith('POP.csv')]
    for pop_file in pop_files:
        output = convert_csv_to_output(pop_file)
        output = f"POPS = {{\n{output}\n}}"
        new_filename = pop_file.replace('.csv', '.txt')
        with open(new_filename, 'w') as f:
            f.write(output)
