library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity complex_multiplier is
    generic (
        INPUT_A_WIDTH : natural := 16;  -- Size of 1st input of multiplier
        INPUT_B_WIDTH : natural := 18   -- Size of 2nd input of multiplier
    );
    port (
        clk : in std_logic;
        real_part_a : in  std_logic_vector(INPUT_A_WIDTH - 1 downto 0);  -- 1st input's real part
        imag_part_a : in  std_logic_vector(INPUT_A_WIDTH - 1 downto 0);  -- 1st input's imaginary part
        real_part_b : in  std_logic_vector(INPUT_B_WIDTH - 1 downto 0);  -- 2nd input's real part
        imag_part_b : in  std_logic_vector(INPUT_B_WIDTH - 1 downto 0);  -- 2nd input's imaginary part
        real_output : out std_logic_vector(INPUT_A_WIDTH + INPUT_B_WIDTH downto 0);  -- Real part of output
        imag_output : out std_logic_vector(INPUT_A_WIDTH + INPUT_B_WIDTH downto 0)   -- Imaginary part of output
    );
end complex_multiplier;

architecture rtl of complex_multiplier is
    signal ai_reg, ai_shift1, ai_shift2, ai_shift3 : signed(INPUT_A_WIDTH - 1 downto 0);
    signal ar_reg, ar_shift1, ar_shift2, ar_shift3 : signed(INPUT_A_WIDTH - 1 downto 0);
    signal bi_reg, bi_shift1, bi_shift2, br_reg, br_shift1, br_shift2 : signed(INPUT_B_WIDTH - 1 downto 0);
    signal common_addend : signed(INPUT_A_WIDTH downto 0);
    signal add_result_real, add_result_imag : signed(INPUT_B_WIDTH downto 0);
    signal mult_temp, product_real, product_imag, real_output_int, imag_output_int : signed(INPUT_A_WIDTH + INPUT_B_WIDTH downto 0);
    signal common_result, common_result1, common_result2 : signed(INPUT_A_WIDTH + INPUT_B_WIDTH downto 0);
begin
    -- Process for registering inputs on rising edge of clock
    process (clk)
    begin
        if rising_edge(clk) then
            ar_reg <= signed(real_part_a);
            ar_shift1 <= signed(ar_reg);
            ai_reg <= signed(imag_part_a);
            ai_shift1 <= signed(ai_reg);
            br_reg <= signed(real_part_b);
            br_shift1 <= signed(br_reg);
            br_shift2 <= signed(br_shift1);
            bi_reg <= signed(imag_part_b);
            bi_shift1 <= signed(bi_reg);
            bi_shift2 <= signed(bi_shift1);
        end if;
    end process;

    -- Real part calculation process
    process (clk)
    begin
        if rising_edge(clk) then
            common_addend <= resize(ar_shift1, INPUT_A_WIDTH + 1) - resize(ai_shift1, INPUT_A_WIDTH + 1);
            mult_temp <= common_addend * bi_shift2;
            common_result <= mult_temp;
        end if;
    end process;

    -- Real product calculation process
    process (clk)
    begin
        if rising_edge(clk) then
            ar_shift2 <= ar_shift1;
            ar_shift3 <= ar_shift2;
            add_result_real <= resize(br_shift2, INPUT_B_WIDTH + 1) - resize(bi_shift2, INPUT_B_WIDTH + 1);
            product_real <= add_result_real * ar_shift3;
            common_result1 <= common_result;
            real_output_int <= product_real + common_result1;
        end if;
    end process;

    -- Imaginary product calculation process
    process (clk)
    begin
        if rising_edge(clk) then
            ai_shift2 <= ai_shift1;
            ai_shift3 <= ai_shift2;
            add_result_imag <= resize(br_shift2, INPUT_B_WIDTH + 1) + resize(bi_shift2, INPUT_B_WIDTH + 1);
            product_imag <= add_result_imag * ai_shift3;
            common_result2 <= common_result;
            imag_output_int <= product_imag + common_result2;
        end if;
    end process;

    -- Output assignments
    real_output <= std_logic_vector(real_output_int);
    imag_output <= std_logic_vector(imag_output_int);
end rtl;
