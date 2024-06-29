library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity MovingAverageFilter is
    generic (
        N : integer := 8 -- Number of samples for moving average
    );
    Port (
        clk       : in  STD_LOGIC;
        rst       : in  STD_LOGIC;
        input     : in  STD_LOGIC_VECTOR(15 downto 0); -- 16-bit input sample
        output    : out STD_LOGIC_VECTOR(15 downto 0)  -- 16-bit filtered output
    );
end MovingAverageFilter;

architecture Behavioral of MovingAverageFilter is

    type sample_array is array (0 to N-1) of STD_LOGIC_VECTOR(15 downto 0);
    signal samples : sample_array := (others => (others => '0'));
    signal sum     : unsigned(31 downto 0) := (others => '0'); -- Sum of samples (wider to avoid overflow)
    signal index   : integer range 0 to N-1 := 0;

begin

    process(clk, rst)
    begin
        if rst = '1' then
            samples <= (others => (others => '0'));
            sum <= (others => '0');
            index <= 0;
            output <= (others => '0');
        elsif rising_edge(clk) then
            -- Subtract the oldest sample from sum and add the new sample
            sum <= sum - unsigned(samples(index)) + unsigned(input);
            -- Store the new sample in the current index
            samples(index) <= input;
            -- Update the index
            if index = N-1 then
                index <= 0;
            else
                index <= index + 1;
            end if;
            -- Compute the average and assign to output
            output <= std_logic_vector(sum / N);
        end if;
    end process;

end Behavioral;
