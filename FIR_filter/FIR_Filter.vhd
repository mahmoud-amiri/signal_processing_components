library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library ieee;
use ieee.math_real.all;
-- Import the custom package
library work;
use work.FIR_PKG.all;

entity fir_filter is
  generic (
    TAP_NUM : integer := 50;  -- Number of taps (filter length)
    DATA_WIDTH : integer := 16  -- Bit-width of filter coefficients and data
    ) ;
  port (
    clk : in std_logic; -- Clock input
    reset : in std_logic; -- Reset input
    x : in std_logic_vector(DATA_WIDTH-1 downto 0);  -- Input data
    y : out std_logic_vector(DATA_WIDTH-1 downto 0) -- Output data
  );
end entity fir_filter;

architecture behavioral of fir_filter is

  signal coefficient : int_arr(0 to TAP_NUM-1):=(33,36,42,52,65,82,103,128,156,187,221,257,295,334,373,412,451,487,521,552,580,603,622,635,643,646,643,635,622,603,580,552,521,487,451,412,373,334,295,257,221,187,156,128,103,82,65,52,42,36,33);
  constant COEFF_WIDTH : integer:= 16;
  constant FRACTION_WIDTH : integer:= 14;
  -- constant COEF : real_arr(0 to TAP_NUM-1) := (0.00201416,0.002197266,0.002563477,0.003173828,0.003967285,0.005004883,0.006286621,0.0078125,0.009521484,0.01141357,0.01348877,0.01568604,0.01800537,0.02038574,0.02276611,0.02514648,0.02752686,0.02972412,0.03179932,0.03369141,0.03540039,0.0368042,0.03796387,0.03875732,0.03924561,0.03942871,0.03924561,0.03875732,0.03796387,0.0368042,0.03540039,0.03369141,0.03179932,0.02972412,0.02752686,0.02514648,0.02276611,0.02038574,0.01800537,0.01568604,0.01348877,0.01141357,0.009521484,0.0078125,0.006286621,0.005004883,0.003967285,0.003173828,0.002563477,0.002197266,0.00201416);
  -- constant ACCEPTABLE_ERROR : real := 10.0**(-8);

  --We resize to 18 bits because the DSP slices offer 18x25 bit multipliers
  -- constant INT_BITS : integer := find_integer_bits(COEF);
  -- constant FRAC_BITS : integer := find_fraction_bits(ACCEPTABLE_ERROR);
  -- constant SCALE_FACTOR : real := 2.0 ** FRAC_BITS;
  -- constant SCALED_COEFS : int_arr := scale_data(COEF, SCALE_FACTOR);
  -- constant COEFF_WIDTH : integer:= INT_BITS + FRAC_BITS;
  -- type coef_vector is array (natural range <>) of signed(COEFF_WIDTH - 1 downto 0);
  -- signal coefficient : coef_vector(0 to TAP_NUM-1);

  type input_vector is array (natural range <>) of signed(DATA_WIDTH - 1 downto 0);
  signal delay_line :input_vector(0 to TAP_NUM-1);
  type products_vector is array (natural range <>) of signed(COEFF_WIDTH + DATA_WIDTH - 1 downto 0);
  -- signal products :products_vector(0 to TAP_NUM-1);
  -- Maximum number of stages needed for the adder tree
  constant MAX_STAGES : integer := integer(ceil(log2(real(TAP_NUM))));
  -- Signals for the adder tree, using a 2D array
  type sum_vector is array (natural range <>) of products_vector(0 to TAP_NUM-1);
  signal sum_stages : sum_vector(0 to MAX_STAGES);

  signal acc : signed(COEFF_WIDTH + DATA_WIDTH - 1 downto 0):=(others=>'0');
begin

  process (clk, reset)
  begin
    if reset = '1' then
      -- for i in coefficient'range loop
      --   coefficient(i) <= to_signed(SCALED_COEFS(i), COEFF_WIDTH);
      -- end loop;
      delay_line <= (others => (others => '0'));
      sum_stages <= (others =>(others => (others => '0')));
      acc <= (others => '0');
      y <= (others => '0');
    elsif rising_edge(clk) then
      -- Shift delay line
      for i in 0 to TAP_NUM-2 loop
        delay_line(i+1) <= delay_line(i);
      end loop;
      delay_line(0) <= signed(x);
      
      -- Compute the partial products in parallel
      for i in 0 to TAP_NUM-1 loop
        -- products(i) <= delay_line(i) * coefficient(i);
        sum_stages(0)(i) <=  delay_line(i) * to_signed(coefficient(i), COEFF_WIDTH);
      end loop;

      -- Generate the adder tree
      for stage in 1 to MAX_STAGES loop
        for i in 0 to ((TAP_NUM-1)/(2**stage)) loop
          --check if there are enough elements to form a pair. If not, it carries forward the single remaining element
          if (2*i+1) < TAP_NUM then 
            sum_stages(stage)(i) <= sum_stages(stage-1)(2*i) + sum_stages(stage-1)(2*i+1);
          else
            sum_stages(stage)(i) <= sum_stages(stage-1)(2*i);
          end if;
        end loop;
      end loop;
      
    -- Assign the output
    y <= std_logic_vector(sum_stages(MAX_STAGES)(0)(DATA_WIDTH+FRACTION_WIDTH-1 downto FRACTION_WIDTH));
    end if;
  end process;

end architecture behavioral;
