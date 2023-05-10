onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_processor/clk
add wave -noupdate /tb_processor/reset
add wave -noupdate /tb_processor/done
add wave -noupdate /tb_processor/done_exporting
add wave -noupdate -expand -group {IMEM signal} /tb_processor/imem_address
add wave -noupdate -expand -group {IMEM signal} /tb_processor/imem_data_in
add wave -noupdate -expand -group {IMEM signal} /tb_processor/imem_req
add wave -noupdate -expand -group {IMEM signal} /tb_processor/imem_ack
add wave -noupdate -expand -group {IF stage} /tb_processor/uut/st_fetch_instruction
add wave -noupdate -expand -group {IF stage} /tb_processor/uut/st_fetch_pc
add wave -noupdate -expand -group {IF stage} /tb_processor/uut/st_fetch_instruction_ready
add wave -noupdate -expand -group {IF stage} /tb_processor/uut/st_fetch_pc_next
add wave -noupdate -expand -group {IF stage} /tb_processor/uut/flush_id
add wave -noupdate -expand -group {IF stage} /tb_processor/uut/stall_id
add wave -noupdate -expand -group {IF stage} /tb_processor/uut/branch_target
add wave -noupdate -expand -group {IF stage} /tb_processor/uut/branch_taken
add wave -noupdate -expand -group {IF stage} /tb_processor/uut/st_fetch_cancel_fetch
add wave -noupdate -expand -group {ID Stage} /tb_processor/uut/st_decode_pc
add wave -noupdate -expand -group {ID Stage} /tb_processor/uut/st_decode_instruction
add wave -noupdate -expand -group {ID Stage} /tb_processor/uut/st_decode_immediate
add wave -noupdate -expand -group {ID Stage} /tb_processor/uut/st_decode_funct3
add wave -noupdate -expand -group {ID Stage} /tb_processor/uut/st_decode_rd_addr
add wave -noupdate -expand -group {ID Stage} /tb_processor/uut/st_decode_rd_write
add wave -noupdate -expand -group {ID Stage} /tb_processor/uut/st_decode_rs1_addr
add wave -noupdate -expand -group {ID Stage} /tb_processor/uut/st_decode_rs1_data
add wave -noupdate -expand -group {ID Stage} /tb_processor/uut/st_decode_rs2_addr
add wave -noupdate -expand -group {ID Stage} /tb_processor/uut/st_decode_rs2_data
add wave -noupdate -expand -group {ID Stage} /tb_processor/uut/st_decode_shamt
add wave -noupdate -expand -group {ID Stage} /tb_processor/uut/st_decode_branch_type
add wave -noupdate -expand -group {ID Stage} /tb_processor/uut/st_decode_alu_x_src
add wave -noupdate -expand -group {ID Stage} /tb_processor/uut/st_decode_alu_y_src
add wave -noupdate -expand -group {ID Stage} /tb_processor/uut/st_decode_alu_op
add wave -noupdate -expand -group {ID Stage} /tb_processor/uut/st_decode_mem_op
add wave -noupdate -expand -group {ID Stage} /tb_processor/uut/st_decode_mem_size
add wave -noupdate -expand -group {ID Stage} /tb_processor/uut/st_decode_conv_op
add wave -noupdate -expand -group {ID Stage} /tb_processor/uut/st_decode_conv_rd_write
add wave -noupdate -expand -group {ID Stage} /tb_processor/uut/st_decode_is_conv_opr
add wave -noupdate -expand -group {ID Stage} /tb_processor/uut/flush_ex
add wave -noupdate -expand -group {ID Stage} /tb_processor/uut/stall_ex
add wave -noupdate /tb_processor/uut/load_hazard_detected
add wave -noupdate -expand -group {EX Stage} /tb_processor/uut/st_execute_rs1_data
add wave -noupdate -expand -group {EX Stage} /tb_processor/uut/st_execute_rs2_data
add wave -noupdate -expand -group {EX Stage} /tb_processor/uut/st_execute_rd_data
add wave -noupdate -expand -group {EX Stage} /tb_processor/uut/st_execute_alu_op
add wave -noupdate -expand -group {EX Stage} /tb_processor/uut/st_execute_alu_x_src
add wave -noupdate -expand -group {EX Stage} /tb_processor/uut/st_execute_alu_y_src
add wave -noupdate -expand -group {EX Stage} /tb_processor/uut/alu_x
add wave -noupdate -expand -group {EX Stage} /tb_processor/uut/alu_y
add wave -noupdate -expand -group {EX Stage} /tb_processor/uut/alu_result
add wave -noupdate -expand -group {EX Stage} /tb_processor/uut/branch_condition
add wave -noupdate -expand -group {EX Stage} /tb_processor/uut/branch_target
add wave -noupdate -expand -group {EX Stage} /tb_processor/uut/branch_taken
add wave -noupdate -expand -group {EX Stage} /tb_processor/uut/st_execute_pc
add wave -noupdate -expand -group {EX Stage} /tb_processor/uut/st_execute_branch_type
add wave -noupdate -expand -group {EX Stage} /tb_processor/uut/st_execute_mem_op
add wave -noupdate -expand -group {EX Stage} /tb_processor/uut/st_execute_mem_size
add wave -noupdate -expand -group {EX Stage} /tb_processor/uut/st_execute_immediate
add wave -noupdate -expand -group {EX Stage} /tb_processor/uut/st_execute_shamt
add wave -noupdate -expand -group {EX Stage} /tb_processor/uut/st_execute_funct3
add wave -noupdate -expand -group {EX Stage} /tb_processor/uut/st_execute_conv_op
add wave -noupdate -expand -group {EX Stage} /tb_processor/uut/st_execute_conv_reg_img
add wave -noupdate -expand -group {EX Stage} /tb_processor/uut/st_execute_conv_reg_kn
add wave -noupdate -expand -group {EX Stage} /tb_processor/uut/st_execute_conv_res_reg_fwd
add wave -noupdate -expand -group {EX Stage} /tb_processor/uut/st_execute_conv_rd_data
add wave -noupdate -expand -group {EX Stage} /tb_processor/uut/st_execute_conv_rd_addr
add wave -noupdate -expand -group {EX Stage} /tb_processor/uut/st_execute_conv_rd_write
add wave -noupdate -expand -group {EX Stage} /tb_processor/uut/st_execute_is_conv_opr
add wave -noupdate -expand -group {EX Stage} /tb_processor/uut/st_execute_conv_clear
add wave -noupdate -expand -group {EX Stage} /tb_processor/uut/stall_mem
add wave -noupdate -expand -group {EX Stage} /tb_processor/uut/st_execute_dmem_address
add wave -noupdate -expand -group {EX Stage} /tb_processor/uut/st_execute_dmem_data_size
add wave -noupdate -expand -group {EX Stage} /tb_processor/uut/st_execute_dmem_data_out
add wave -noupdate -expand -group {EX Stage} /tb_processor/uut/st_execute_dmem_read_req
add wave -noupdate -expand -group {EX Stage} /tb_processor/uut/st_execute_dmem_write_req
add wave -noupdate -expand -group {CNV-Reg File} /tb_processor/uut/conv_reg_file/rs_parallel_data_img
add wave -noupdate -expand -group {CNV-Reg File} /tb_processor/uut/conv_reg_file/rs_parallel_data_kn
add wave -noupdate -expand -group {CNV-Reg File} /tb_processor/uut/conv_reg_file/res_out
add wave -noupdate -expand -group {CNV-Reg File} /tb_processor/uut/conv_reg_file/rd_addr
add wave -noupdate -expand -group {CNV-Reg File} /tb_processor/uut/conv_reg_file/rd_data
add wave -noupdate -expand -group {CNV-Reg File} /tb_processor/uut/conv_reg_file/registers
add wave -noupdate -expand -group {DMEM Signal} /tb_processor/dmem_address
add wave -noupdate -expand -group {DMEM Signal} /tb_processor/dmem_data_in
add wave -noupdate -expand -group {DMEM Signal} /tb_processor/dmem_data_out
add wave -noupdate -expand -group {DMEM Signal} /tb_processor/dmem_data_size
add wave -noupdate -expand -group {DMEM Signal} /tb_processor/dmem_read_req
add wave -noupdate -expand -group {DMEM Signal} /tb_processor/dmem_write_req
add wave -noupdate -expand -group {DMEM Signal} /tb_processor/dmem_read_ack
add wave -noupdate -expand -group {DMEM Signal} /tb_processor/dmem_write_ack
add wave -noupdate -expand -group {MEM Stage} /tb_processor/uut/st_memory_dmem_data
add wave -noupdate -expand -group {MEM Stage} /tb_processor/uut/st_memory_rd_write
add wave -noupdate -expand -group {MEM Stage} /tb_processor/uut/st_memory_rd_addr
add wave -noupdate -expand -group {MEM Stage} /tb_processor/uut/st_memory_rd_data
add wave -noupdate -expand -group {MEM Stage} /tb_processor/uut/st_memory_conv_rd_addr
add wave -noupdate -expand -group {MEM Stage} /tb_processor/uut/st_memory_conv_rd_data
add wave -noupdate -expand -group {MEM Stage} /tb_processor/uut/st_memory_conv_rd_write
add wave -noupdate -expand -group {MEM Stage} /tb_processor/uut/st_memory_conv_clear
add wave -noupdate -expand -group {WB Stage} /tb_processor/uut/st_writeback_rd_addr
add wave -noupdate -expand -group {WB Stage} /tb_processor/uut/st_writeback_rd_data
add wave -noupdate -expand -group {WB Stage} /tb_processor/uut/st_writeback_rd_write
add wave -noupdate -expand -group {WB Stage} /tb_processor/uut/st_writeback_conv_rd_data
add wave -noupdate -expand -group {WB Stage} /tb_processor/uut/st_writeback_conv_rd_write
add wave -noupdate -expand -group {WB Stage} /tb_processor/uut/st_writeback_conv_rd_addr
add wave -noupdate -expand -group {WB Stage} /tb_processor/uut/st_writeback_conv_clear
add wave -noupdate -expand -group {REG file} /tb_processor/uut/regfile/rs1_addr
add wave -noupdate -expand -group {REG file} /tb_processor/uut/regfile/rs1_data
add wave -noupdate -expand -group {REG file} /tb_processor/uut/regfile/rs2_addr
add wave -noupdate -expand -group {REG file} /tb_processor/uut/regfile/rs2_data
add wave -noupdate -expand -group {REG file} /tb_processor/uut/regfile/rd_addr
add wave -noupdate -expand -group {REG file} /tb_processor/uut/regfile/rd_data
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {808485 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 229
configure wave -valuecolwidth 160
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {74 ns} {203 ns}
