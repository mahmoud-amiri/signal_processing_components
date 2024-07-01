`timescale 1ns / 1ps

module tb_fir_filter;

  parameter N = 16;
  parameter M = 8;

  reg clk;
  reg reset;
  reg [M-1:0] x;
  wire [M-1:0] y;
  
  reg [M-1:0] input_data [0:N-1];
  reg [M-1:0] expected_output [0:N-1];
  integer i;

  // Instantiate the FIR filter
  fir_filter #(
    .N(N),
    .M(M)
  ) uut (
    .clk(clk),
    .reset(reset),
    .x(x),
    .y(y)
  );

  // Clock generation
  always #5 clk = ~clk;

  // Test procedure
  initial begin
    // Initialize signals
    clk = 0;
    reset = 1;
    x = 0;

    // Load input and expected output data from files
    $readmemb("input_signal.txt", input_data);
    $readmemb("output_signal.txt", expected_output);

    // Wait for some time and then release reset
    #20 reset = 0;

    // Apply inputs and check outputs
    for (i = 0; i < N; i = i + 1) begin
      x = input_data[i];
      #10;  // Wait for the output to stabilize
      if (y !== expected_output[i]) begin
        $display("Mismatch at index %0d: expected %b, got %b", i, expected_output[i], y);
      end else begin
        $display("Match at index %0d: expected %b, got %b", i, expected_output[i], y);
      end
    end

    // Finish simulation
    $finish;
  end

endmodule
