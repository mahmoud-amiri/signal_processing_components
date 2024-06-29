onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /complex_multiplier/INPUT_A_WIDTH
add wave -noupdate /complex_multiplier/INPUT_B_WIDTH
add wave -noupdate /complex_multiplier/clk
add wave -noupdate /complex_multiplier/real_part_a
add wave -noupdate /complex_multiplier/imag_part_a
add wave -noupdate /complex_multiplier/real_part_b
add wave -noupdate /complex_multiplier/imag_part_b
add wave -noupdate /complex_multiplier/real_output
add wave -noupdate /complex_multiplier/imag_output
add wave -noupdate /complex_multiplier/ai_reg
add wave -noupdate /complex_multiplier/ai_shift1
add wave -noupdate /complex_multiplier/ai_shift2
add wave -noupdate /complex_multiplier/ai_shift3
add wave -noupdate /complex_multiplier/ar_reg
add wave -noupdate /complex_multiplier/ar_shift1
add wave -noupdate /complex_multiplier/ar_shift2
add wave -noupdate /complex_multiplier/ar_shift3
add wave -noupdate /complex_multiplier/bi_reg
add wave -noupdate /complex_multiplier/bi_shift1
add wave -noupdate /complex_multiplier/bi_shift2
add wave -noupdate /complex_multiplier/br_reg
add wave -noupdate /complex_multiplier/br_shift1
add wave -noupdate /complex_multiplier/br_shift2
add wave -noupdate /complex_multiplier/common_addend
add wave -noupdate /complex_multiplier/add_result_real
add wave -noupdate /complex_multiplier/add_result_imag
add wave -noupdate /complex_multiplier/mult_temp
add wave -noupdate /complex_multiplier/product_real
add wave -noupdate /complex_multiplier/product_imag
add wave -noupdate /complex_multiplier/real_output_int
add wave -noupdate /complex_multiplier/imag_output_int
add wave -noupdate /complex_multiplier/common_result
add wave -noupdate /complex_multiplier/common_result1
add wave -noupdate /complex_multiplier/common_result2
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 233
configure wave -justifyvalue left
configure wave -signalnamewidth 0
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
WaveRestoreZoom {0 ns} {2 ns}
