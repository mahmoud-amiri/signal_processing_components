library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity MedianFilter is
    generic (
        N : integer := 5 -- Number of samples for median filter, must be odd
    );
    Port (
        clk       : in  STD_LOGIC;
        rst       : in  STD_LOGIC;
        input     : in  STD_LOGIC_VECTOR(15 downto 0); -- 16-bit input sample
        output    : out STD_LOGIC_VECTOR(15 downto 0)  -- 16-bit filtered output
    );
end MedianFilter;

architecture Behavioral of MedianFilter is

    type sample_array is array (0 to N-1) of STD_LOGIC_VECTOR(15 downto 0);
    signal samples : sample_array := (others => (others => '0'));
    signal index   : integer range 0 to N-1 := 0;

    -- Comparator and swap process
    procedure comparator_swap(signal a : inout STD_LOGIC_VECTOR(15 downto 0);
                              signal b : inout STD_LOGIC_VECTOR(15 downto 0)) is
        variable tmp : STD_LOGIC_VECTOR(15 downto 0);
    begin
        if unsigned(a) > unsigned(b) then
            tmp := a;
            a := b;
            b := tmp;
        end if;
    end procedure;

    -- Odd-even transposition sorting network
    process(clk, rst)
        variable i, j : integer;
    begin
        if rst = '1' then
            samples <= (others => (others => '0'));
            index <= 0;
            output <= (others => '0');
        elsif rising_edge(clk) then
            -- Store the new sample in the current index
            samples(index) <= input;
            -- Update the index
            if index = N-1 then
                index <= 0;
            else
                index <= index + 1;
            end if;

            -- Perform odd-even transposition sort
            for i in 0 to N-2 loop
                if i mod 2 = 0 then
                    -- Even phase
                    for j in 0 to N/2-1 loop
                        comparator_swap(samples(2*j), samples(2*j+1));
                    end loop;
                else
                    -- Odd phase
                    for j in 0 to (N-1)/2-1 loop
                        comparator_swap(samples(2*j+1), samples(2*j+2));
                    end loop;
                end if;
            end loop;

            -- Assign the median to output
            output <= samples((N-1)/2);
        end if;
    end process;

end Behavioral;
