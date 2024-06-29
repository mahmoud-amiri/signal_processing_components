# Complex Multiplier VHDL Project

This VHDL project implements a complex multiplier that computes the product of two complex numbers. It takes two sets of input signals representing the real and imaginary parts of each complex number and outputs the real and imaginary parts of the resulting product.

## Usage

Example instantiation in another VHDL module:
```vhdl
entity my_complex_system is
    port (
        clk : in std_logic;
        -- other ports
        result_real : out std_logic_vector(31 downto 0);
        result_imag : out std_logic_vector(31 downto 0)
    );
end entity my_complex_system;

architecture rtl of my_complex_system is
    signal a_real, a_imag, b_real, b_imag : std_logic_vector(15 downto 0);
    signal result_real, result_imag : std_logic_vector(31 downto 0);

    component complex_multiplier is
        generic (
            INPUT_A_WIDTH : natural := 16;
            INPUT_B_WIDTH : natural := 18
        );
        port (
            clk : in std_logic;
            real_part_a : in std_logic_vector(INPUT_A_WIDTH - 1 downto 0);
            imag_part_a : in std_logic_vector(INPUT_A_WIDTH - 1 downto 0);
            real_part_b : in std_logic_vector(INPUT_B_WIDTH - 1 downto 0);
            imag_part_b : in std_logic_vector(INPUT_B_WIDTH - 1 downto 0);
            real_output : out std_logic_vector(INPUT_A_WIDTH + INPUT_B_WIDTH downto 0);
            imag_output : out std_logic_vector(INPUT_A_WIDTH + INPUT_B_WIDTH downto 0)
        );
    end component;

begin
    multiplier_inst : complex_multiplier
    generic map (
        INPUT_A_WIDTH => 16,
        INPUT_B_WIDTH => 18
    )
    port map (
        clk => clk,
        real_part_a => a_real,
        imag_part_a => a_imag,
        real_part_b => b_real,
        imag_part_b => b_imag,
        real_output => result_real,
        imag_output => result_imag
    );

    -- other signal assignments and processes
end architecture rtl;
```

## License

This project is licensed under the [MIT License](LICENSE).

## Contributing

Contributions are welcome! Please fork this repository and create a pull request with your suggested changes.
