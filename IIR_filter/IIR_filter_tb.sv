`timescale 1ns / 1ps

module tb_iir_filter;

  // Constants
  parameter CLK_PERIOD = 10;  // Clock period in ns
  parameter SIM_TIME = 1000;  // Simulation time in ns

  // Signals
  logic clk;
  logic reset;
  logic signed [7:0] input_data;
  logic signed [7:0] filtered_output;

  // Instantiate DUT (Design Under Test)
  iir_filter dut (
    .clk(clk),
    .reset(reset),
    .x(input_data),
    .y(filtered_output)
  );

  // Clock generation process
  always #((CLK_PERIOD)/2) clk = ~clk;

  // Automatic test sequence
  initial begin
    // Initialize
    reset = 1;
    clk = 0;
    input_data = 0;

    // Wait for initial reset
    #100;

    // Release reset
    reset = 0;
    #100;

    // Randomized test sequence
    repeat (20) begin  // Number of test iterations
      // Randomize input_data
      $randomize(input_data) with { input_data dist { uniform { 8'b00000000, 8'b11111111 } } };
      
      // Drive input_data to DUT
      @(posedge clk);
      #1;
      @(posedge clk);
      #1;
      @(posedge clk);
      input_data <= input_data;

      // Wait for filter response
      @(posedge clk);
      #100;

      // Check filtered_output (optional assertion)
      $display("Input: %d, Output: %d", input_data, filtered_output);
    end

    // End of testbench simulation
    #100;
    $finish;
  end

endmodule
