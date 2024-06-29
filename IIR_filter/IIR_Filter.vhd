library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity iir_filter is
  generic (
    M : integer := 8;           -- Bit-width of data
    B0 : integer := 64;         -- Coefficient B0 (gain)
    B1 : integer := -120;       -- Coefficient B1
    B2 : integer := 64;         -- Coefficient B2
    A1 : integer := -90;        -- Coefficient A1
    A2 : integer := 42          -- Coefficient A2
  );
  port (
    clk : in std_logic;         -- Clock input
    reset : in std_logic;       -- Reset input
    x : in std_logic_vector(M-1 downto 0);  -- Input data
    y : out std_logic_vector(M-1 downto 0)  -- Output data
  );
end entity iir_filter;

architecture behavioral of iir_filter is
  signal w1, w2, z : signed(M-1 downto 0) := (others => '0');
begin

  process (clk, reset)
  begin
    if reset = '1' then
      w1 <= (others => '0');
      w2 <= (others => '0');
      z <= (others => '0');
    elsif rising_edge(clk) then
      -- Calculate new w1 and w2
      w1 <= signed(x) - (to_signed(A1, M) * w1 + to_signed(A2, M) * w2) / to_signed(B0, M);
      w2 <= w1;
      
      -- Calculate output z
      z <= to_signed(B1, M) * w1 + to_signed(B2, M) * w2;
      
      -- Output y
      y <= std_logic_vector(z);
    end if;
  end process;

end architecture behavioral;
