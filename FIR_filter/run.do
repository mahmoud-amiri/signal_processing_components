# Check if the 'work' library exists and delete it if present
if {[file exists "work"]} {
    vdel -all
}
vlib work

# Compile the design files
vcom -2008 -work work FIR_filter.vhd
vcom -2008 -work work FIR_PKG.vhd
vlog -sv -work work FIR_filter_tb.sv

# Optimize the testbench design
vopt work.FIR_filter_tb -o tb_optimized +acc

# Load and simulate the testbench
vsim -lib work tb_optimized

# Setup for simulation
set NoQuitOnFinish 1
onbreak {resume}
log /* -r
add wave -r /*

# Run the simulation
run -all

# Save waveforms if waves.do file exists
if {[file exists "waves.do"]} {
    do waves.do
    wave save waves.wlf
}
quit
