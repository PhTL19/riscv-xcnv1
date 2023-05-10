import numpy as np
import cv2
import argparse

def twos_complement(hexstr, bits):
    value = int(hexstr, 16)
    if value & (1 << (bits - 1)):
        value -= 1 << bits
    return value

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--input_mem_file", "-i", type=str, help="Path to input memory file")
    parser.add_argument("--output_size", "-s", type=int, help="Output image size", default=1)
    parser.add_argument("--output_image", "-o", type=str, help="Path to output image")
    args = parser.parse_args()

    print (">>> Read file")
    f = open(args.input_mem_file, 'r')
    img_size = args.output_size
    img = np.zeros((img_size, img_size))
    
    for i in range(img_size):
        for j in range(img_size):
            line = f.readline().split('\n')
            px = twos_complement(line[0], 32)
            img[i][j] = 0 if px < 0 else 255 if px > 255 else px  
    f.close()
    cv2.imwrite(args.output_image,img)
    print (">>> Done converting")