import argparse

def is_buggy(s: str) -> bool:
    count = 0
    for c in s:
        if c == '[':
            count += 1
        if c == ']':
            count -= 1
    return count != 0


if __name__== '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("file") # Add a required argument
    args = parser.parse_args()
    buggy = []
    with open(args.file, 'r', encoding="utf-8") as file:
        line_number = 1
        for line in file:
            # process the line
            if is_buggy(line):
                print(line_number)
            line_number+=1  
