import re

infile = "cylon_test.dis"
outfile = "cylon_test_with_words.dis"

with open(infile, "r") as fin, open(outfile, "w") as fout:
    for line in fin:
        m = re.match(r'\s*([0-9a-fA-F]+):', line)

        if m:
            addr_str = m.group(1)
            addr = int(addr_str, 16)
            fout.write(f"{addr // 4:x}-{addr_str}:{line[m.end():]}")
        else:
            fout.write(line)