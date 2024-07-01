`timescale 1ns / 1ps

module complex_multiplier_tb;

    parameter EXP_BITS := 8;
    parameter MANT_BITS := 23;
    parameter BIAS := 127;
    // Inputs
    reg clk = 0;
    reg rst = 1;
    reg [31:0] a;
    reg [31:0] b;
    reg sign_a, sign_b;
    reg unsigned [MANT_BITS+1 : 0] exp_a, exp_b;
    reg unsigned [MANT_BITS+1 : 0] mant_a, mant_b;
    
    // Outputs
    wire [31:0] result;

    reg [31:0] expected_result;
    real rand_num_a, rand_num_b;



    // Clock generation
    always #5 clk = ~clk;

    // Instantiate the DUT (Design Under Test)
    FloatingPointAdder dut (
        .clk(clk),
        .rst(rst),
        .a(a),
        .b(b),
        .result(result)
    );

    // Function to display inputs and outputs
    function void display_inputs;
        $display("===============================");
        $display("Inputs:");
        $display("a = %h", a);
        $display("b = %h", b);
        $display("===============================");
    endfunction

    // Function to convert a real to a 32-bit IEEE 754 floating point number
    function bit [31:0] real_to_float(input real r);
        bit [31:0] f;
        int i;
        bit [22:0] fraction;
        bit [7:0] exponent;
        bit sign;
        
        // Handle special cases
        if (r == 0.0) begin
            return 32'b0;
        end else if (r == -0.0) begin
            return 32'b1_00000000_00000000000000000000000;
        end else if (r == 1.0/0.0) begin
            return 32'b0_11111111_00000000000000000000000; // +Infinity
        end else if (r == -1.0/0.0) begin
            return 32'b1_11111111_00000000000000000000000; // -Infinity
        end

        sign = (r < 0);
        if (sign) r = -r;
        
        // Extract exponent
        int exponent_unbiased = $clog2(r);
        exponent = 127 + exponent_unbiased;

        // Normalize the real number
        r = r / (2 ** exponent_unbiased);

        // Extract fraction
        r = r - 1.0; // Remove leading 1
        for (i = 0; i < 23; i = i + 1) begin
            r = r * 2;
            fraction[22-i] = (r >= 1);
            if (r >= 1) r = r - 1.0;
        end

        // Assemble the floating-point number
        f = {sign, exponent, fraction};

        return f;
    endfunction

    // Function to generate a random real number in a given range
    function real random_real(input real min, input real max);
        real range;
        real rand;
        range = max - min;
        rand = $urandom_range(0, 1000000) / 1000000.0; // Normalize to [0.0, 1.0]
        return min + rand * range;
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
            rand_num_a = random_real(-10**100, 10**100);
            a = real_to_float(rand_num_a);
            rand_num_b = random_real(-10**100, 10**100);
            b = real_to_float(rand_num_b);

            // Predicted outputs
            expected_result = real_to_float(rand_num_a + rand_num_b);
            
            // Wait for some clock cycle
            #40;

            // Display inputs and actual outputs
            display_inputs;

            // Compare predicted and actual outputs
            if (result !== expected_result ) begin
                $error("Output mismatch! Expected output=%0d, but got %0d",
                    expected_result, result);
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
