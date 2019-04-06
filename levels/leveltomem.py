import sys
file = open(sys.argv[1])
translate_dict = {
    "@": "001", #floor
    "$": "101", #crate
    "#": "000", #wall
    ".": "010", #goal
    "-": "001", #floor
    "=": "011" #black
}
for line in file.readlines():
    for char in line:
        if (char != '\n'):
            print(translate_dict[char], end=' ')
