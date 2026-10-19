import re
from pathlib import Path

input_file = Path("build/pipeline_test.lst")
output_file = Path("build/pipeline_test_div_4.lst")

with open(input_file, "r") as infile, open(output_file, "w") as outfile:
    for line in infile:
        match = re.match(r"^\s*([0-9a-fA-F]+):", line)

        if match:
            address = int(match.group(1), 16)
            number = address // 4
            outfile.write(f"{number:x} {line}")
        else:
            outfile.write(line)

print(f"Done. Output saved to {output_file}")