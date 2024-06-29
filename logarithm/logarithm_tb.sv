`timescale 1ns/1ps

module tb_fixedpoint_log_calc;

  // Parameters
  parameter IN_WORD_LEN = 18;
  parameter IN_FRAC_LEN = 17;
  parameter OUT_WORD_LEN = 18;

  // DUT Ports
  reg Clock;
  reg Reset;
  reg Valid_in;
  reg [IN_WORD_LEN-1:0] Data_in;
  wire Valid_out;
  wire [OUT_WORD_LEN-1:0] Data_out;

  // Predictor Variables
  reg [OUT_WORD_LEN-1:0] predicted_Data_out;
  reg expected_Valid_out;

  // DUT Instantiation
  fixedpoint_log_calc #(IN_WORD_LEN, IN_FRAC_LEN, OUT_WORD_LEN) DUT (
    .Clock(Clock),
    .Reset(Reset),
    .Valid_in(Valid_in),
    .Data_in(Data_in),
    .Valid_out(Valid_out),
    .Data_out(Data_out)
  );

  // Clock generation
  initial begin
    Clock = 0;
    forever #5 Clock = ~Clock; // 10ns period
  end

  // Reset task
  task apply_reset();
    begin
      Reset = 1;
      #20;
      Reset = 0;
    end
  endtask

  // Random Data generation
  task generate_random_data();
    begin
      Data_in = $random;
    end
  endtask

  // Predictor
  task predictor(input [IN_WORD_LEN-1:0] Data_in, output [OUT_WORD_LEN-1:0] predicted_Data_out);
    // Placeholder for the actual prediction logic
    begin
      // This is a simplified placeholder prediction logic
      predicted_Data_out = (Data_in * 98641) >> 17; // Adjust based on actual expected behavior
    end
  endtask

  // Test Process
  initial begin
    // Initialize signals
    Valid_in = 0;
    Data_in = 0;
    apply_reset();

    // Test loop
    repeat (100) begin
      generate_random_data();
      Valid_in = 1;
      predictor(Data_in, predicted_Data_out);

      @(posedge Clock);
      if (Valid_out !== expected_Valid_out) begin
        $display("VALID MISMATCH at time %0t: expected %0b, got %0b", $time, expected_Valid_out, Valid_out);
      end
      if (Valid_out) begin
        if (Data_out !== predicted_Data_out) begin
          $display("DATA MISMATCH at time %0t: expected %0h, got %0h", $time, predicted_Data_out, Data_out);
        end else begin
          $display("DATA MATCH at time %0t: expected %0h, got %0h", $time, predicted_Data_out, Data_out);
        end
      end

      Valid_in = 0;
      @(posedge Clock);
    end

    $stop;
  end

endmodule
