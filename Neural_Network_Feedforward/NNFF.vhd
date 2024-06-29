LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all; -- package needed for SIGNED

PACKAGE neural_net_types IS
    CONSTANT BIT_WIDTH: INTEGER := 3; -- # of bits per input or weight
    TYPE input_vector_array IS ARRAY (NATURAL RANGE <>) OF SIGNED(BIT_WIDTH-1 DOWNTO 0);
    TYPE output_vector_array IS ARRAY (NATURAL RANGE <>) OF SIGNED(2*BIT_WIDTH+1 DOWNTO 0);
END neural_net_types;
---------- Neural Network Main Code: ------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all; -- package needed for SIGNED
USE work.neural_net_types.all; -- package of user-defined types

ENTITY neural_net IS
    GENERIC (
        NUM_NEURONS: INTEGER := 3; -- # of neurons
        NUM_INPUTS: INTEGER := 3; -- # of inputs or weights per neuron
        BIT_WIDTH: INTEGER := 3 -- # of bits per input or weight
    );
    PORT (
        inputs: IN input_vector_array(1 TO NUM_INPUTS);
        weights: IN input_vector_array(1 TO NUM_INPUTS*NUM_NEURONS);
        clock: IN STD_LOGIC;
        test_reg: OUT SIGNED(BIT_WIDTH-1 DOWNTO 0); -- register test
        outputs: OUT output_vector_array(1 TO NUM_NEURONS) -- output
    );
END neural_net;

ARCHITECTURE behavior OF neural_net IS
BEGIN
    PROCESS (clock, weights, inputs)
        VARIABLE weight_vector: input_vector_array(1 TO NUM_INPUTS*NUM_NEURONS);
        VARIABLE product, accumulator: SIGNED(2*BIT_WIDTH+1 DOWNTO 0);
        VARIABLE sign_bit: STD_LOGIC;
    BEGIN
        -- shift register inference
        IF (clock'EVENT AND clock='1') THEN
            weight_vector := weights;
        END IF;
        test_reg <= weight_vector(NUM_INPUTS);
        
        -- initialization
        accumulator := (OTHERS => '0');
        
        -- multiply-accumulate
        neuron_loop: FOR neuron_index IN 1 TO NUM_NEURONS LOOP
            input_loop: FOR input_index IN 1 TO NUM_INPUTS LOOP
                product := inputs(input_index) * weight_vector(NUM_INPUTS*(neuron_index-1)+input_index);
                sign_bit := accumulator(2*BIT_WIDTH);
                accumulator := accumulator + product;
                
                -- overflow check
                IF (sign_bit /= accumulator(2*BIT_WIDTH)) AND (accumulator(2*BIT_WIDTH) = '1') THEN
                    accumulator := (accumulator(2*BIT_WIDTH) & sign_bit, OTHERS => NOT sign_bit);
                END IF;
            END LOOP input_loop;
            outputs(neuron_index) <= accumulator;
            accumulator := (OTHERS => '0');
        END LOOP neuron_loop;
    END PROCESS;
END behavior;
