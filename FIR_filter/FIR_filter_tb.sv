`timescale 1ns / 1ps

module tb_fir_filter;

  function void read_data_from_file(string file_name, logic signed [M-1:0] data_array[]);
    int file;
    int code;
    int index;
    logic signed [31:0] temp;
    file = $fopen(file_name, "r");
    if (file == 0) begin
      $display("Error opening file: %s", file_name);
      $finish;
    end
    
    index = 0;
    while (!$feof(file)) begin
      code = $fscanf(file, "%d\n", temp);
      if (code == 1) begin
        data_array[index] = temp;
        index = index + 1;
      end
    end
    $fclose(file);
  endfunction


  // Parameters
  localparam N = 8;    // Number of taps (filter length)
  localparam M = 8;    // Bit-width of filter coefficients and data
  
  // Clock and reset signals
  logic clk;
  logic reset;
  
  // Signals for FIR filter module
  logic signed [M-1:0] x;
  logic signed [M-1:0] y;
  
  // Instantiate the FIR filter module
  fir_filter #(.N(N), .M(M)) dut (
    .clk(clk),
    .reset(reset),
    .x(x),
    .y(y)
  );
  
  // Testbench variables
  int expected_output;
  int input_value;
  int filter_output;
  int error_count = 0;
  
  // Clock generation process
  always begin
    clk = 0;
    #5;
    clk = 1;
    #5;
  end
  
  // Reset generation process
  initial begin
    reset = 1;
    #10;
    reset = 0;
  end
  
  // Stimulus generation and checking
  initial begin
    // Randomize input values and check output
    repeat (100) begin
      // Randomize input value
      input_value = $random % 256;  // Random value between 0 and 255
      
      // Drive input to DUT
      x = input_value;
      
      // Predict output based on filter coefficients and input_value
      expected_output = compute_expected_output(input_value);
      
      // Wait for output to stabilize
      @(posedge clk);
      
      // Compare output with expected output
      filter_output = y;
      if (filter_output !== expected_output) begin
        $display("Error: Expected output %d, but got %d for input %d", expected_output, filter_output, input_value);
        error_count++;
      end
      
      // Display input and output values
      $display("Input: %d, Output: %d", input_value, filter_output);
      
      // Delay before next iteration
      #20;
    end
    
    // Display final summary
    if (error_count == 0)
      $display("Testbench completed successfully with no errors.");
    else
      $display("Testbench completed with %0d errors.", error_count);
      
    // End simulation
    $finish;
  end
  
  // Function to compute expected output (replace with actual computation)
  function int compute_expected_output(int input);
    int sum = 0;
    // Example: Simple moving average
    for (int i = 0; i < N; i++)
      sum += input / N;
    return sum;
  endfunction

endmodule
