# conv_scipy.py

import scipy
import numpy as np
import cv2
import argparse

def write_to_file_hex(filename, img, byte_n=1):
    if byte_n == 1:
        l_hex = "02x"
    elif byte_n == 2:
        l_hex = "04x"
    elif byte_n == 4:
        l_hex = "08x"
    arr_f = img.flatten()
    f = open(filename, 'w')
    index = 0
    for px in arr_f:
        f.write(format((px & ((1<<(8*byte_n))-1)), l_hex))
        if (index == 4/byte_n-1):
            f.write("\n")
            index = 0
        else :
            index += 1
    while (index < 4/byte_n):
        f.write(format(0, l_hex))
        index += 1
    f.close()


# img = np.array([[29,15,28,57,32,10,60]
#       ,[42,28,54,5,5,6,36]
#       ,[54,9,15,9,16,25,43]
#       ,[0,5,10,5,47,62,49]
#       ,[45,33,61,0,44,58,58]
#       ,[23,27,27,2,1,53,6]
#       ,[13,47,3,50,6,40,61]])

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--input_file", "-i", type=str, help="Path to input image", default=None)
    parser.add_argument("--output_file", "-o", type=str, help="Path to output image", default=None)
    parser.add_argument("--mem_file", "-m", type=str, help="Path to output memory file", default="nodata.mem")
    parser.add_argument("--random_image", "-r", type=bool, help="Use random image", default=False)
    args = parser.parse_args()
    
    if args.random_image == True :
        img = np.random.randint(0, 64, (7, 7))
        kn = np.random.randint(-7, 8, (3, 3))
        print (">>> Convolution uses random images")
    else :
        img = cv2.imread(args.input_file, cv2.IMREAD_GRAYSCALE)
        kn = np.array([[1,0,-1]
            ,[2,0,-2]
            ,[1,0,-1]])
        print (">>> Convolution uses image from file")
        # kn = np.array([[1,2,1]
        #      ,[0,0,0]
        #      ,[-1,-2,-1]]) 

    dmem = np.concatenate((img.flatten(), kn.flatten()))
    # print(dmem)
    write_to_file_hex(args.mem_file, dmem, 1)

    out = scipy.signal.correlate2d(img, kn, mode='valid')
    print (">>> Output shape: ", out.shape)
    cv2.imwrite(args.output_file, out)
    print (">>> Write memory file done")

    # print(img)
    # print(kn)
    # print(out)
