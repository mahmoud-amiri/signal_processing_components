`timescale 1ns / 1ps

module complex_multiplier_tb;

    // Inputs
    reg clk = 0;
    reg rst = 1;
    reg [15:0] real_part_a = 16'h0000;
    reg [15:0] imag_part_a = 16'h0000;
    reg [17:0] real_part_b = 18'h0000;
    reg [17:0] imag_part_b = 18'h0000;
    
    // Outputs
    wire [34:0] real_output;
    wire [34:0] imag_output;

    reg [34:0] expected_real = 35'b0;
    reg [34:0] expected_imag = 35'b0;
    // Clock generation
    always #5 clk = ~clk;

    // Instantiate the DUT (Design Under Test)
    complex_multiplier dut (
        .clk(clk),
        .rst(rst),
        .real_part_a(real_part_a),
        .imag_part_a(imag_part_a),
        .real_part_b(real_part_b),
        .imag_part_b(imag_part_b),
        .real_output(real_output),
        .imag_output(imag_output)
    );

    // Function to display inputs and outputs
    function void display_inputs_outputs;
        $display("===============================");
        $display("Inputs:");
        $display("real_part_a = %h", real_part_a);
        $display("imag_part_a = %h", imag_part_a);
        $display("real_part_b = %h", real_part_b);
        $display("imag_part_b = %h", imag_part_b);
        $display("===============================");
    endfunction

    // Initial block
    initial begin
        // Reset the DUT
        rst = 1;
        #15;
        rst = 0;

        // Test sequence 1: Default inputs
        // display_inputs_outputs;
        
        // Test sequence 2: Randomize inputs and predict outputs
        repeat (10) begin
            // Randomize inputs
            real_part_a = $urandom_range(0, 65535); // Random 16-bit value
            imag_part_a = $urandom_range(0, 65535); // Random 16-bit value
            real_part_b = $urandom_range(0, 262143); // Random 18-bit value
            imag_part_b = $urandom_range(0, 262143); // Random 18-bit value
            
            // Predicted outputs
            expected_real = real_part_a * real_part_b - imag_part_a * imag_part_b;
            expected_imag = real_part_a * imag_part_b + imag_part_a * real_part_b;
            
            // Wait for some clock cycle
            #40;

            // Display inputs and actual outputs
            display_inputs_outputs;

            // Compare predicted and actual outputs
            if ($signed(real_output) !== expected_real || $signed(imag_output) !== expected_imag) begin
                $error("Output mismatch! Expected real_output=%0d, imag_output=%0d, but got real_output=%0d, imag_output=%0d",
                    expected_real, expected_imag, real_output, imag_output);
            end else begin
                $display("Matched!");
            end

            // Wait for a clock cycle
            #10;
        end

        // End simulation
        $finish;
    end

endmodule
