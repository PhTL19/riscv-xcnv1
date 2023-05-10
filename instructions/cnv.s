# x5 - t0 : temporary DMEM address
# x6 - t1 : temporary cnv_regs address
# x7 - t2 : temporary DMEM address start
# x18 - s2: img width
# x19 - s3: kernel width
# x20 - s4: saved img start address on DMEM
# x21 - s5: kernel start address on DMEM
# x22 - s6: DMEM address for result
# x23 - s7: saved value s2- s3
# x28 - t3: temporary i counter
# x29 - t4: temporary j counter
# x30 - t5: temporary a counter
# x31 - t6: temporary b counter
# x28, x29, x30, x31 : i, j, a, b

# Setup variables
addi x0, x0, 0
addi x18, x0, 28
addi x19, x0, 3
addi x20, x0, 0
addi x21, x0, 784
addi x22, x0, 800
# Load kernel
sub x23, x18, x19
addi x6, x0, 0x31
add x5, x0, x21
addi x28, x0, 0
load_kn_i: 
bge x28, x19, load_kn_end
addi x28, x28, 0x1
addi x29, x0, 0
load_kn_j: 
bge x29, x19, load_kn_i
addi x29, x29, 0x1
xcnv.lbkn 0(x5), x6
addi x5, x5, 1
addi x6, x6, 1
jal x0, load_kn_j
load_kn_end: 
addi x30, x0, 0
# Load image
addi x0, x0, 0
load_img_a: 
blt x23, x30, end_conv
addi x30, x30, 1
addi x31, x0, 0
load_img_b: 
blt x23, x31, load_img_b_end
addi x31, x31, 1
addi x6, x0, 0
add x5, x0, x20
addi x28, x0, 0
load_img_i: 
bge x28, x19, load_img_end
addi x28, x28, 0x1
addi x29, x0, 0
load_img_j: 
bge x29, x19, load_img_ij
addi x29, x29, 0x1
xcnv.lbimg 0(x5), x6
addi x5, x5, 1
addi x6, x6, 1
jal x0, load_img_j
load_img_ij: 
add x5, x5, x23
jal x0, load_img_i
load_img_end: 
addi x28, x0, 0
# convolve and store
xcnv.conv
addi x0, x0, 0
xcnv.swcnv 0(x22)
addi x22, x22, 2
addi x20, x20, 1
jal x0, load_img_b
load_img_b_end: 
add x20, x20, x19
addi x20, x20, -1
jal x0, load_img_a
# end convolution and clear regs
end_conv: 
xcnv.clcnv