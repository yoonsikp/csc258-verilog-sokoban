import glob
import imageio
files = glob.glob('./*.png')
files = list(files)
files.sort()
print("Num files found: " + str(len(files)))
palette = []

def get_hex(rgb):
    rbin = int(bin(rgb[0])[2:])
    gbin = int(bin(rgb[1])[2:])
    bbin = int(bin(rgb[2])[2:])
    x = ('%08d' % rbin)[:4] + ('%08d' % gbin)[:4] + ('%08d' % bbin)[:4]    
    return x
def get_pos(hex):
    num = palette.index(hex)
    numbin = int(bin(num)[2:])
    return ('%04d' % numbin)

for file in files:
    arr = imageio.imread(file)
    for i in range(8):
        for j in range(8):
            retval = get_hex(arr[i,j])
            if retval not in palette:
                palette.append(retval)
for file in files:
    arr = imageio.imread(file)
    for i in range(8):
        for j in range(8):
            retval = get_hex(arr[i,j])
            print(get_pos(retval),end='')
        print(" ", end='')

print("")
for i in range(len(palette)):
    print('%04d' % int(bin(i)[2:]))
    print(palette[i])
