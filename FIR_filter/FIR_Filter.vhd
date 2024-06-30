library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.FIR_PKG.all;


entity fir_filter is
  generic (
    N : integer := 16;  -- Number of taps (filter length)
    M : integer := 8  -- Bit-width of filter coefficients and data
    ) ;
  port (
    clk : in std_logic; -- Clock input
    reset : in std_logic; -- Reset input
    x : in std_logic_vector(M-1 downto 0);  -- Input data
    y : out std_logic_vector(M-1 downto 0) -- Output data
  );
end entity fir_filter;

architecture behavioral of fir_filter is

  constant coefficients : real_vector(0 to N-1) := (0.01662606, -0.00696415, -0.03403663, -0.04855056, -0.01434685, 0.08048669,  0.20301046,  0.28957738,  0.28957738,  0.20301046, 0.08048669, -0.01434685, -0.04855056, -0.03403663, -0.00696415, 0.01662606);

  --We resize to 18 bits because the DSP slices offer 18x25 bit multipliers
  constant COEF_SCALE_BITS : integer := find_opt_scale(coefficients);
  constant COEF_SCALE : real := real(2 ** (17 - COEF_SCALE_BITS));
  constant SCALED_COEFS : integer_vector := scale_coeffs(coefficients, COEF_SCALE);


  signal delay_line : std_logic_vector(M-1 downto 0) := (others => '0');
  signal acc : integer range -(2**(M-1)) to 2**(M-1)-1 := 0;
begin

  process (clk, reset)
  begin
    if reset = '1' then
      -- Reset logic here
      delay_line <= (others => '0');
      acc <= 0;
    elsif rising_edge(clk) then
      -- Shift delay line
      delay_line <= x & delay_line(N-1 downto 1);
      
      -- Compute new accumulator value
      acc <= 0;
      for i in 0 to N-1 loop
        acc <= acc + SCALED_COEFS(i) * to_integer(signed(delay_line(i)));
      end loop;
      
      -- Output the result
      y <= std_logic_vector(to_signed(acc, M));
    end if;
  end process;

end architecture behavioral;
