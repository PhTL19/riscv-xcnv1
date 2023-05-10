import numpy as np
import cv2

def mx_mult_sum(a, b, sizeh, sizew):
    s = 0
    for i in range(sizeh):
        for j in range(sizew):
            s += a[i][j]*b[i][j]
    return s

def convolution2D(I, k):
    h, w = k.shape[0], k.shape[1]
    H, W = I.shape[0], I.shape[1]
    output_h = H - h + 1
    output_w = W - w + 1

    output = np.zeros((output_h, output_w), dtype=np.int16)
    for i in range(output_h):
        for j in range(output_w):
                output[i][j] = mx_mult_sum(I[i:i + h, j:j + w], k, h, w)
    return output

def write_to_file_hex(filename, arr):
    arr_f = arr.flatten()
    f = open(filename, 'w')
    index = 0
    for px in arr_f:
        print(px.type)
        f.write(format((px & ((1<<16)-1)), '04x'))
        if (index == 3):
            f.write("\n")
            index = 0
        else :
            index += 1
    f.close()

# img = np.random.randint(0, 64, (5, 5))


# print(img)
# # write_to_file_hex("dmem_i.mem",img)

# kn = np.random.randint(-15, 16, (5, 5))
# print(kn)
# write_to_file_hex("dmem_k.mem",img)

# # kn = np.array(([1, 0, -1], 
# #                [2, 0, -2], 
# #                [1, 0, -1],))

# conv = convolution2D(img, kn)
# print(conv)
# # hex()

# write_to_file_hex("dmem_res2.mem", conv)

img = cv2.imread("img.png", cv2.IMREAD_GRAYSCALE)
kn = np.array([[1,0,-1]
     ,[2,0,-2]
     ,[1,0,-1]])
out = convolution2D(img, kn)

