library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity FloatingPointMultiplier is
    Port (
        clk      : in  STD_LOGIC;
        rst      : in  STD_LOGIC;
        a        : in  STD_LOGIC_VECTOR (31 downto 0); -- Input operand a
        b        : in  STD_LOGIC_VECTOR (31 downto 0); -- Input operand b
        result   : out STD_LOGIC_VECTOR (31 downto 0)  -- Result of multiplication
    );
end FloatingPointMultiplier;

architecture Behavioral of FloatingPointMultiplier is

    -- IEEE 754 single precision format constants
    constant EXP_BITS : integer := 8;
    constant MANT_BITS : integer := 23;
    constant BIAS : integer := 127;

    -- Internal signals
    signal sign_a, sign_b, sign_result : STD_LOGIC;
    signal exp_a, exp_b, exp_result : integer range 0 to 255;
    signal mant_a, mant_b : unsigned(MANT_BITS+1 downto 0); -- Include hidden bit
    signal product_mant : unsigned(2*MANT_BITS+1 downto 0); -- Double width for product
    signal norm_mant : unsigned(MANT_BITS downto 0); -- Normalized mantissa

begin

    process(clk, rst)
    begin
        if rst = '1' then
            result <= (others => '0');
        elsif rising_edge(clk) then
            -- Extract sign, exponent, and mantissa
            sign_a <= a(31);
            sign_b <= b(31);
            exp_a <= to_integer(unsigned(a(30 downto 23)));
            exp_b <= to_integer(unsigned(b(30 downto 23)));
            mant_a <= "1" & a(22 downto 0);
            mant_b <= "1" & b(22 downto 0);

            -- Calculate the resulting sign
            sign_result <= sign_a xor sign_b;

            -- Add exponents and adjust with bias
            exp_result <= exp_a + exp_b - BIAS;

            -- Multiply mantissas
            product_mant <= mant_a * mant_b;

            -- Normalize the result
            if product_mant(2*MANT_BITS+1) = '1' then
                norm_mant <= product_mant(2*MANT_BITS downto MANT_BITS+1);
                exp_result <= exp_result + 1;
            else
                norm_mant <= product_mant(2*MANT_BITS-1 downto MANT_BITS);
            end if;

            -- Handle special cases (overflow, underflow, zero)
            if exp_result >= 255 then
                exp_result <= 255; -- Overflow to infinity
                norm_mant <= (others => '0');
            elsif exp_result <= 0 then
                exp_result <= 0; -- Underflow to zero
                norm_mant <= (others => '0');
            end if;

            -- Pack result
            result(31) <= sign_result;
            result(30 downto 23) <= std_logic_vector(to_unsigned(exp_result, EXP_BITS));
            result(22 downto 0) <= std_logic_vector(norm_mant(MANT_BITS-1 downto 0));

        end if;
    end process;

end Behavioral;
