library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity SqrtCalculator is
    generic (
        DATA_WIDTH : integer := 16 -- Input and output data width
    );
    Port (
        clk       : in  STD_LOGIC;
        rst       : in  STD_LOGIC;
        start     : in  STD_LOGIC; -- Start signal
        input     : in  STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0); -- Input value
        output    : out STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0); -- Output value (square root)
        ready     : out STD_LOGIC -- Ready signal
    );
end SqrtCalculator;

architecture Behavioral of SqrtCalculator is
    signal x, r, q : unsigned(DATA_WIDTH-1 downto 0);
    signal count : integer range 0 to DATA_WIDTH;
    signal done : STD_LOGIC;

begin

    process(clk, rst)
    begin
        if rst = '1' then
            x <= (others => '0');
            r <= (others => '0');
            q <= (others => '0');
            count <= 0;
            done <= '0';
            ready <= '0';
        elsif rising_edge(clk) then
            if start = '1' then
                x <= unsigned(input);
                r <= (others => '0');
                q <= (others => '0');
                count <= DATA_WIDTH/2;
                done <= '0';
                ready <= '0';
            elsif done = '0' then
                if count > 0 then
                    r <= r(DATA_WIDTH-2 downto 0) & x(DATA_WIDTH-1);
                    x <= x(DATA_WIDTH-2 downto 0) & '0';
                    if r >= (q & "1") then
                        r <= r - (q & "1");
                        q <= (q(DATA_WIDTH-2 downto 0) & '1');
                    else
                        q <= (q(DATA_WIDTH-2 downto 0) & '0');
                    end if;
                    count <= count - 1;
                else
                    done <= '1';
                    ready <= '1';
                end if;
            end if;
        end if;
    end process;

    output <= std_logic_vector(q);

end Behavioral;
