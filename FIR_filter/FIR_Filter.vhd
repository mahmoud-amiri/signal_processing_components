library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fir_filter is
  generic (
    N : integer := 8;           -- Number of taps (filter length)
    M : integer := 8             -- Bit-width of filter coefficients and data
  );
  port (
    clk : in std_logic;         -- Clock input
    reset : in std_logic;       -- Reset input
    x : in std_logic_vector(M-1 downto 0);  -- Input data
    y : out std_logic_vector(M-1 downto 0)  -- Output data
  );
end entity fir_filter;

architecture behavioral of fir_filter is
  type coef_array is array(0 to N-1) of integer range -(2**(M-1)) to 2**(M-1)-1;
  signal coefficients : coef_array := (others => 0);  -- Define your coefficients here
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
        acc <= acc + coefficients(i) * to_integer(signed(delay_line(i)));
      end loop;
      
      -- Output the result
      y <= std_logic_vector(to_signed(acc, M));
    end if;
  end process;

end architecture behavioral;
