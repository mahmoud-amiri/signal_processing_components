library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity FloatingPointAdder is
    Port (
        clk      : in  STD_LOGIC;
        rst      : in  STD_LOGIC;
        a        : in  STD_LOGIC_VECTOR (31 downto 0); -- Input operand a
        b        : in  STD_LOGIC_VECTOR (31 downto 0); -- Input operand b
        result   : out STD_LOGIC_VECTOR (31 downto 0)  -- Result of addition
    );
end FloatingPointAdder;

architecture Behavioral of FloatingPointAdder is

    -- IEEE 754 single precision format constants
    constant EXP_BITS : integer := 8;
    constant MANT_BITS : integer := 23;
    constant BIAS : integer := 127;

    -- Internal signals
    signal sign_a, sign_b, sign_result : STD_LOGIC;
    signal exp_a, exp_b, exp_result : integer range 0 to 255;
    signal mant_a, mant_b, mant_result : unsigned(MANT_BITS downto 0); -- Include hidden bit
    signal sum_mant : unsigned(MANT_BITS+2 downto 0); -- For carrying addition overflow
    signal shift_amount : integer range 0 to MANT_BITS+1;

begin

    process(clk, rst)
    begin
        if rst = '1' then
            result <= (others => '0');
            mant_a <= (others => '0');
            mant_b <= (others => '0');
            exp_a <= 0;
            exp_b <= 0;
            result <= (others => '0');
            mant_result <= (others => '0');
            sum_mant <= (others => '0');
            shift_amount <= 0;
            exp_result <= 0;
        elsif rising_edge(clk) then
            -- Extract sign, exponent, and mantissa
            sign_a <= a(31);
            sign_b <= b(31);
            exp_a <= to_integer(unsigned(a(30 downto MANT_BITS)));
            exp_b <= to_integer(unsigned(b(30 downto MANT_BITS)));
            mant_a <= unsigned('1' & a(MANT_BITS-1 downto 0));
            mant_b <= unsigned('1' & b(MANT_BITS-1 downto 0));

            -- Align exponents
            if exp_a > exp_b then
                shift_amount <= exp_a - exp_b;
                mant_b <= mant_b srl shift_amount;
                exp_result <= exp_a;
            else
                shift_amount <= exp_b - exp_a;
                mant_a <= mant_a srl shift_amount;
                exp_result <= exp_b;
            end if;

            -- Perform addition or subtraction
            if sign_a = sign_b then
                sum_mant <= ("0" & mant_a) + ("0" & mant_b);
                sign_result <= sign_a;
            else
                if mant_a >= mant_b then
                    sum_mant <= ("0" & mant_a) - ("0" & mant_b);
                    sign_result <= sign_a;
                else
                    sum_mant <= ("0" & mant_b) - ("0" & mant_a);
                    sign_result <= sign_b;
                end if;
            end if;

            -- Normalize result
            if sum_mant(MANT_BITS+2) = '1' then
                mant_result <= sum_mant(MANT_BITS+2 downto 1);
                exp_result <= exp_result + 1;
            else
                mant_result <= sum_mant(MANT_BITS+1 downto 0);
            end if;

            -- Pack result
            result(31) <= sign_result;
            result(30 downto 23) <= std_logic_vector(to_unsigned(exp_result, EXP_BITS));
            result(22 downto 0) <= std_logic_vector(mant_result(MANT_BITS downto 1)); -- Removing hidden bit

        end if;
    end process;

end Behavioral;
