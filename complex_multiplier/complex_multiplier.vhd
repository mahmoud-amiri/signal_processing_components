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
        rst : in std_logic;  -- Reset signal
        real_part_a : in std_logic_vector(INPUT_A_WIDTH - 1 downto 0);  -- 1st input's real part
        imag_part_a : in std_logic_vector(INPUT_A_WIDTH - 1 downto 0);  -- 1st input's imaginary part
        real_part_b : in std_logic_vector(INPUT_B_WIDTH - 1 downto 0);  -- 2nd input's real part
        imag_part_b : in std_logic_vector(INPUT_B_WIDTH - 1 downto 0);  -- 2nd input's imaginary part
        real_output : out std_logic_vector(INPUT_A_WIDTH + INPUT_B_WIDTH downto 0);  -- Real part of output
        imag_output : out std_logic_vector(INPUT_A_WIDTH + INPUT_B_WIDTH downto 0)   -- Imaginary part of output
    );
end complex_multiplier;

architecture rtl of complex_multiplier is
    signal ai_r, ai_r2, ai_r3, ai_r4 : signed(INPUT_A_WIDTH - 1 downto 0);
    signal ar_r, ar_r2, ar_r3, ar_r4 : signed(INPUT_A_WIDTH - 1 downto 0);
    signal bi_r, bi_r2, bi_r3, br_r, br_r2, br_r3 : signed(INPUT_B_WIDTH - 1 downto 0);
    signal common_addend : signed(INPUT_A_WIDTH downto 0);
    signal add_result_real, add_result_imag : signed(INPUT_B_WIDTH downto 0);
    signal mult_temp, product_real, product_imag, real_output_int, imag_output_int : signed(INPUT_A_WIDTH + INPUT_B_WIDTH downto 0);
    signal common_result, common_result1, common_result2 : signed(INPUT_A_WIDTH + INPUT_B_WIDTH downto 0);
begin
    -- Process for registering inputs on rising edge of clock
    process (clk, rst)
    begin
        if rst = '1' then
            ar_r <= (others => '0');
            ar_r2 <= (others => '0');
            ai_r <= (others => '0');
            ai_r2 <= (others => '0');
            br_r <= (others => '0');
            br_r2 <= (others => '0');
            br_r3 <= (others => '0');
            bi_r <= (others => '0');
            bi_r2 <= (others => '0');
            bi_r3 <= (others => '0');
        elsif rising_edge(clk) then
            ar_r <= signed(real_part_a);
            ar_r2 <= signed(ar_r);
            ai_r <= signed(imag_part_a);
            ai_r2 <= signed(ai_r);
            br_r <= signed(real_part_b);
            br_r2 <= signed(br_r);
            br_r3 <= signed(br_r2);
            bi_r <= signed(imag_part_b);
            bi_r2 <= signed(bi_r);
            bi_r3 <= signed(bi_r2);
        end if;
    end process;

    -- Real part calculation process
    process (clk, rst)
    begin
        if rst = '1' then
            common_addend <= (others => '0');
            mult_temp <= (others => '0');
            common_result <= (others => '0');
        elsif rising_edge(clk) then
            common_addend <= resize(ar_r2, INPUT_A_WIDTH + 1) - resize(ai_r2, INPUT_A_WIDTH + 1);
            mult_temp <= common_addend * bi_r3;
            common_result <= mult_temp;
        end if;
    end process;

    -- Real product calculation process
    process (clk, rst)
    begin
        if rst = '1' then
            ar_r3 <= (others => '0');
            ar_r4 <= (others => '0');
            add_result_real <= (others => '0');
            product_real <= (others => '0');
            common_result1 <= (others => '0');
            real_output_int <= (others => '0');
        elsif rising_edge(clk) then
            ar_r3 <= ar_r2;
            ar_r4 <= ar_r3;
            add_result_real <= resize(br_r3, INPUT_B_WIDTH + 1) - resize(bi_r3, INPUT_B_WIDTH + 1);
            product_real <= add_result_real * ar_r4;
            common_result1 <= common_result;
            real_output_int <= product_real + common_result1;
        end if;
    end process;

    -- Imaginary product calculation process
    process (clk, rst)
    begin
        if rst = '1' then
            ai_r3 <= (others => '0');
            ai_r4 <= (others => '0');   
            add_result_imag <= (others => '0');
            product_imag <= (others => '0');
            common_result2 <= (others => '0');
            imag_output_int <= (others => '0');
        elsif rising_edge(clk) then
            ai_r3 <= ai_r2;
            ai_r4 <= ai_r3;
            add_result_imag <= resize(br_r3, INPUT_B_WIDTH + 1) + resize(bi_r3, INPUT_B_WIDTH + 1);
            product_imag <= add_result_imag * ai_r4;
            common_result2 <= common_result;
            imag_output_int <= product_imag + common_result2;
        end if;
    end process;

    -- Output assignments
    real_output <= std_logic_vector(real_output_int);
    imag_output <= std_logic_vector(imag_output_int);
end rtl;
