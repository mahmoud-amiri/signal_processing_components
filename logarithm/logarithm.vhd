library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library work;
use work.conv_pkg.all;

entity fixedpoint_log_calc is
    generic (
        IN_WORD_LEN : natural := 18;
        IN_FRAC_LEN : natural := 17;
        OUT_WORD_LEN : natural := 18
    );
    Port (
        Clock : in STD_LOGIC;
        Reset : in STD_LOGIC;
        Valid_in : in STD_LOGIC;
        Data_in : in STD_LOGIC_VECTOR (IN_WORD_LEN-1 downto 0);
        Valid_out : out STD_LOGIC;
        Data_out : out STD_LOGIC_VECTOR (OUT_WORD_LEN-1 downto 0)
    );
end fixedpoint_log_calc;

architecture Behavioral of fixedpoint_log_calc is
    constant COEFFICIENT : signed := to_signed(98641,18);
    constant N_BITS : natural := 32;
    constant F_BITS : natural := 16;
    constant N : natural := 6;

    type FRACTION_LUT_ARRAY is array (0 to 2**N-1) of std_logic_vector(18-1 downto 0);
    constant FRACTION_LUT : FRACTION_LUT_ARRAY := (
        "000000000000000000", "000000000010110111", "000000000101101011",
        "000000001000011101", "000000001011001100", "000000001101111001",
        "000000010000100011", "000000010011001010", "000000010101110000",
        "000000011000010011", "000000011010110011", "000000011101010010",
        "000000011111101111", "000000100010001001", "000000100100100010",
        "000000100110111000", "000000101001001101", "000000101011100000",
        "000000101101110001", "000000110000000000", "000000110010001101",
        "000000110100011001", "000000110110100011", "000000111000101100",
        "000000111010110011", "000000111100111001", "000000111110111101",
        "000001000000111111", "000001000011000001", "000001000101000000",
        "000001000110111111", "000001001000111100", "000001001010111000",
        "000001001100110010", "000001001110101011", "000001010000100011",
        "000001010010011010", "000001010100010000", "000001010110000100",
        "000001010111110111", "000001011001101010", "000001011011011011",
        "000001011101001011", "000001011110111010", "000001100000101000",
        "000001100010010100", "000001100100000000", "000001100101101011",
        "000001100111010101", "000001101000111110", "000001101010100111",
        "000001101100001110", "000001101101110100", "000001101111011010",
        "000001110000111110", "000001110010100010", "000001110100000101",
        "000001110101100111", "000001110111001000", "000001111000101001",
        "000001111010001000", "000001111011100111", "000001111101000101",
        "000001111110100011"
    );

    signal X_signal : std_logic_vector(N_BITS-1 downto 0) := (others => '0');
    signal S_signal : signed(18-1 downto 0) := (others => '0');
    signal F_signal : signed(18-1 downto 0) := (others => '0');
    signal Y_signal : signed(36-1 downto 0) := (others => '0');
    signal M_signal : integer range 0 to N_BITS-1 := 0;
    signal A_signal : integer range 0 to 2**N-1 := 0;
    signal T_signal : std_logic_vector(6-1 downto 0) := (others => '0');
    signal Valid_r1, Valid_r2 : std_logic := '0';

    function Lead_One_Detector(Input : std_logic_vector) return integer is
        constant LENGTH : integer := Input'length;
        variable Index : integer range 0 to LENGTH-1;
    begin
        Index := 0;
        for i in 0 to LENGTH-1 loop
            if Input(i) = '1' then
                Index := i;
            end if;
        end loop;
        return Index;
    end function Lead_One_Detector;

begin
    X_signal <= convert_type(Data_in, IN_WORD_LEN, IN_FRAC_LEN, xlSigned, N_BITS, F_BITS, xlSigned, xltruncate, xlwrap);

    process(Clock)
    begin
        if rising_edge(Clock) then
            if Valid_in = '1' then
                M_signal <= Lead_One_Detector(X_signal);
            end if;
            Valid_r1 <= Valid_in;
            Valid_r2 <= Valid_r1;
            Valid_out <= Valid_r2;
        end if;
    end process;

    T_signal <= std_logic_vector(to_signed(M_signal-F_BITS,6));
    A_signal <= to_integer(unsigned(X_signal(M_signal-1 downto M_signal-N))) when M_signal >= N-1 else 31;

    process(Clock)
    begin
        if rising_edge(Clock) then
            if Reset = '1' then
                S_signal <= (others => '0');
                F_signal <= (others => '0');
            else
                S_signal <= signed(convert_type(T_signal, 6, 0, xlSigned, 18, 13, xlSigned, xltruncate, xlwrap));
                F_signal <= signed(FRACTION_LUT(A_signal));
            end if;
        end if;
    end process;

    process(Clock)
    begin
        if rising_edge(Clock) then
            if Reset = '1' then
                Y_signal <= (others => '0');
            else
                Y_signal <= (S_signal + F_signal) * COEFFICIENT;
            end if;
        end if;
    end process;

    Data_out <= convert_type(std_logic_vector(Y_signal), 36, 28, xlSigned, 18, 10, xlSigned, xltruncate, xlwrap);
end Behavioral;
