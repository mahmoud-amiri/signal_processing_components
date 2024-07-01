`timescale 1ns / 1ps

module FIR_filter_tb;

  parameter TAP_NUM = 51;
  parameter DATA_WIDTH = 16;
  parameter INPUT_DATA_NUM = 5000;
  parameter DELAY = 9;
  reg clk;
  reg reset;
  reg signed [DATA_WIDTH-1:0] x;
  wire signed [DATA_WIDTH-1:0] y;
  int input_data [0:INPUT_DATA_NUM-1];
  int output_data [0:INPUT_DATA_NUM + DELAY-1];
  int expected_output [0:INPUT_DATA_NUM-1];
  integer i;
  int num_values;
  int match_cnt = 0;
  int unmatch_cnt = 0;

  // Instantiate the FIR filter
  fir_filter #(
    .TAP_NUM(TAP_NUM),
    .DATA_WIDTH(DATA_WIDTH)
  ) uut (
    .clk(clk),
    .reset(reset),
    .x(x),
    .y(y)
  );

  // Clock generation
  always #5 clk = ~clk;

    // Function to read data from a file
  function int read_values_from_file(
    input string filename,
    output int data_array [0:INPUT_DATA_NUM-1]
    );
    int file, r;
    string line;
    int value;
    int value_count;

    // Open the file
    file = $fopen(filename, "r");
    if (file == 0) begin
        $display("Error: could not open file %s", filename);
        return 0;
    end

    // Read the line from the file
    r = $fgets(line, file);
    if (r == 0) begin
      $display("Error: could not read from file %s", filename);
      $fclose(file);
      return 0;
    end
    
    // Close the file as we only read one line
    $fclose(file);

    // Initialize the counter
    value_count = 0;

    // Parse the comma-separated values
    while ($sscanf(line, "%d,%s", value, line) == 2) begin
      if (value_count < INPUT_DATA_NUM) begin
        data_array[value_count] = value;
        value_count++;
      end else begin
        $display("Warning: maximum number of values (%d) exceeded", INPUT_DATA_NUM);
        break;
      end
    end

    // Return the number of values read
    return value_count;
  endfunction


  function logic signed [31:0] abs(input logic signed [31:0] value);
    if (value < 0)
      abs = -value;
    else
      abs = value;
  endfunction

  // Test procedure
  initial begin
    // Initialize signals
    clk = 0;
    reset = 1;
    x = 0;

    // Load input and expected output data from files
    num_values = read_values_from_file("input_signal.txt", input_data);
    num_values = read_values_from_file("output_signal.txt", expected_output);
    // Wait for some time and then release reset
    #20 reset = 0;

    // Apply inputs and check outputs
    for (i = 0; i < INPUT_DATA_NUM + DELAY; i = i + 1) begin
      if (i < INPUT_DATA_NUM) begin
        x = input_data[i];
      end
      if(i > DELAY) begin
        output_data[i - DELAY] = y;  
      end
      #10;  // Wait for the output to stabilize
    end

    for (i = 0; i < INPUT_DATA_NUM; i = i + 1) begin
      if (abs(output_data[i] - expected_output[i]) > 5) begin
        unmatch_cnt = unmatch_cnt + 1;
        $display("Mismatch at index %0d: expected %b, got %b", i, expected_output[i], output_data[i]);
      end else begin
        match_cnt = match_cnt + 1;
        // $display("Mat?ch at index %0d: expected %b, got %b", i, expected_output[i], output_data[i]);
      end
    end

    $display("Match rate : %0d", (match_cnt * 100) / (match_cnt + unmatch_cnt));
    // Finish simulation
    $finish;
  end

endmodule
