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
    signal ai_r ,ar_r , ai_r2, ar_r2 : signed(INPUT_A_WIDTH - 1 downto 0);
    signal bi_r, bi_r2, br_r, br_r2 : signed(INPUT_B_WIDTH - 1 downto 0);
    signal br_p_bi : signed(INPUT_B_WIDTH downto 0);
    signal ar_p_ai, ai_m_ar : signed(INPUT_A_WIDTH downto 0);
    signal common_term, real_term, image_term : signed(INPUT_A_WIDTH + INPUT_B_WIDTH downto 0);
    signal pr, pi : signed(INPUT_A_WIDTH + INPUT_B_WIDTH downto 0);
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
            bi_r <= (others => '0');
            bi_r2 <= (others => '0');
            br_p_bi <= (others => '0');
            ar_p_ai <= (others => '0');
            ai_m_ar <= (others => '0');
            common_term <= (others => '0');
            real_term <= (others => '0');
            image_term <= (others => '0');
            pr <= (others => '0');
            pi <= (others => '0');
        elsif rising_edge(clk) then

            ar_r <= signed(real_part_a);
            ai_r <= signed(imag_part_a);
            br_r <= signed(real_part_b);
            bi_r <= signed(imag_part_b);
            --
            br_p_bi <= resize(br_r, INPUT_B_WIDTH + 1) + resize(bi_r, INPUT_B_WIDTH + 1);
            ar_p_ai <= resize(ar_r, INPUT_A_WIDTH + 1) + resize(ai_r, INPUT_A_WIDTH + 1);
            ai_m_ar <= resize(ai_r, INPUT_A_WIDTH + 1) - resize(ar_r, INPUT_A_WIDTH + 1);
            --
            ar_r2 <= ar_r;
            ai_r2 <= ai_r;
            br_r2 <= br_r;
            bi_r2 <= bi_r;
            common_term <= ar_r2 * br_p_bi;
            real_term <= bi_r2 * ar_p_ai;
            image_term <= br_r2 * ai_m_ar;
            --
            pr <= common_term - real_term;
            pi <= common_term + image_term;
        end if;
    end process;
    
    -- Output assignments
    real_output <= std_logic_vector(pr);
    imag_output <= std_logic_vector(pi);
end rtl;
