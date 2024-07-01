library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.FIR_PKG.all;
library ieee;
use ieee.math_real.all;


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

  constant COEF : real_vector(0 to N-1) := (0.01662606, -0.00696415, -0.03403663, -0.04855056, -0.01434685, 0.08048669,  0.20301046,  0.28957738,  0.28957738,  0.20301046, 0.08048669, -0.01434685, -0.04855056, -0.03403663, -0.00696415, 0.01662606);
  constant ACCEPTABLE_ERROR : real := 10.0**(-8);

  --We resize to 18 bits because the DSP slices offer 18x25 bit multipliers
  constant INT_BITS : integer := find_integer_bits(COEF);
  constant FRAC_BITS : integer := find_fraction_bits(ACCEPTABLE_ERROR);
  constant SCALE_FACTOR : real := 2.0 ** FRAC_BITS;
  constant SCALED_COEFS : integer_vector := scale_data(COEF, SCALE_FACTOR);
  constant COEFF_WIDTH : integer:= INT_BITS + FRAC_BITS;
  type coef_vector is array (natural range <>) of signed(COEFF_WIDTH - 1 downto 0);
  signal coefficient : coef_vector(0 to N-1);

  type input_vector is array (natural range <>) of signed(M - 1 downto 0);
  signal delay_line :input_vector(0 to N-1);
  type products_vector is array (natural range <>) of signed(COEFF_WIDTH + M - 1 downto 0);
  signal products :products_vector(0 to N-1);
  -- Maximum number of stages needed for the adder tree
  constant MAX_STAGES : integer := integer(ceil(log2(real(N))));
  -- Signals for the adder tree, using a 2D array
  type sum_vector is array (natural range <>) of products_vector(0 to N-1);
  signal sum_stages : sum_vector(0 to MAX_STAGES);

  signal acc : signed(COEFF_WIDTH + M - 1 downto 0):=(others=>'0');
begin

  process (clk, reset)
  begin
    if reset = '1' then
      for i in coefficient'range loop
        coefficient(i) <= to_signed(SCALED_COEFS(i), COEFF_WIDTH);
      end loop;
      delay_line <= (others => (others => '0'));
      acc <= (others => '0');
    elsif rising_edge(clk) then
      -- Shift delay line
      for i in 0 to N-2 loop
        delay_line(i+1) <= delay_line(i);
      end loop;
      delay_line(0) <= signed(x);
      
      -- Compute the partial products in parallel
      for i in 0 to N-1 loop
        -- products(i) <= delay_line(i) * coefficient(i);
        sum_stages(0)(i) <=  delay_line(i) * coefficient(i);
      end loop;

      -- Generate the adder tree
      for stage in 1 to MAX_STAGES loop
        for i in 0 to ((N-1)/(2**stage)) loop
          --check if there are enough elements to form a pair. If not, it carries forward the single remaining element
          if (2*i+1) < N then 
            sum_stages(stage)(i) <= sum_stages(stage-1)(2*i) + sum_stages(stage-1)(2*i+1);
          else
            sum_stages(stage)(i) <= sum_stages(stage-1)(2*i);
          end if;
        end loop;
      end loop;
      
    -- Assign the output
    y <= std_logic_vector(sum_stages(MAX_STAGES)(0)(M+COEFF_WIDTH-1 downto COEFF_WIDTH));
    end if;
  end process;

end architecture behavioral;
