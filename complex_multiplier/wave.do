onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /complex_multiplier_tb/clk
add wave -noupdate /complex_multiplier_tb/rst
add wave -noupdate /complex_multiplier_tb/real_part_a
add wave -noupdate /complex_multiplier_tb/imag_part_a
add wave -noupdate /complex_multiplier_tb/real_part_b
add wave -noupdate /complex_multiplier_tb/imag_part_b
add wave -noupdate /complex_multiplier_tb/real_output
add wave -noupdate /complex_multiplier_tb/imag_output
add wave -noupdate /complex_multiplier_tb/expected_real
add wave -noupdate /complex_multiplier_tb/expected_imag
add wave -noupdate /complex_multiplier_tb/dut/clk
add wave -noupdate /complex_multiplier_tb/dut/rst
add wave -noupdate /complex_multiplier_tb/dut/real_part_a
add wave -noupdate /complex_multiplier_tb/dut/imag_part_a
add wave -noupdate /complex_multiplier_tb/dut/real_part_b
add wave -noupdate /complex_multiplier_tb/dut/imag_part_b
add wave -noupdate /complex_multiplier_tb/dut/real_output
add wave -noupdate /complex_multiplier_tb/dut/imag_output
add wave -noupdate /complex_multiplier_tb/dut/ai_r2
add wave -noupdate /complex_multiplier_tb/dut/ar_r2
add wave -noupdate /complex_multiplier_tb/dut/bi_r2
add wave -noupdate /complex_multiplier_tb/dut/br_r2
add wave -noupdate /complex_multiplier_tb/dut/br_p_bi
add wave -noupdate /complex_multiplier_tb/dut/ar_p_ai
add wave -noupdate /complex_multiplier_tb/dut/ai_m_ar
add wave -noupdate /complex_multiplier_tb/dut/common_term
add wave -noupdate /complex_multiplier_tb/dut/real_term
add wave -noupdate /complex_multiplier_tb/dut/image_term
add wave -noupdate /complex_multiplier_tb/dut/pr
add wave -noupdate /complex_multiplier_tb/dut/pi
add wave -noupdate -expand -group r /complex_multiplier_tb/dut/ai_r
add wave -noupdate -expand -group r /complex_multiplier_tb/dut/ar_r
add wave -noupdate -expand -group r /complex_multiplier_tb/dut/bi_r
add wave -noupdate -expand -group r /complex_multiplier_tb/dut/br_r
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {4081 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 318
configure wave -valuecolwidth 100
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
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {53310 ps}
