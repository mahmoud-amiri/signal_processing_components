library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library ieee;
use ieee.math_real.all;
use ieee.numeric_std.all;

package FIR_PKG is
    type real_vector is array (natural range <>) of real;
    type integer_vector is array (natural range <>) of integer;
    function abs_arr (arr : real_vector) return real_vector;
    function maximum (arr : real_vector) return real;
    function find_integer_bits(coeffs : real_vector) return integer;
    function find_fraction_bits(acceptable_error : real) return integer;
    function scale_data(arr : real_vector; scale_factor : real) return integer_vector;
end package FIR_PKG;


package body FIR_PKG is

    -- calculate abs in an array
    function abs_arr (arr : real_vector) return real_vector is
        variable abs_data : real_vector(arr'range);
    begin
        for i in arr'range loop
            if arr(i) < 0.0 then
                abs_data(i) := -arr(i);
            else
                abs_data(i) := arr(i);
            end if;
        end loop;
        return abs_data;
    end function abs_arr;

    -- find max in an array
    function maximum (arr : real_vector) return real is
        variable max_val : real := arr(0);
    begin
        for i in arr'range loop
            if arr(i) > max_val then
                max_val := arr(i);
            end if;
        end loop;
        return max_val;
    end function maximum;

    -- find int part bit number 
    function find_integer_bits(coeffs : real_vector) return integer is
    begin
        return integer(ceil(log2(maximum(abs_arr(coeffs)))))  + 1; -- +1 for sign bit
    end find_integer_bits;

    -- find fraction part bit number 
    function find_fraction_bits(acceptable_error : real) return integer is
    begin
        return integer(ceil(log2(1.0 / acceptable_error))); 
    end find_fraction_bits;

    -- calculate scaled array
    function scale_data(arr : real_vector; scale_factor : real) return integer_vector is
    variable result_vec : integer_vector(0 to arr'length-1);
    begin
        for i in arr'range loop
            result_vec(i) := integer(scale_factor*arr(i));
        end loop;
        return result_vec; 
    end scale_data;

end FIR_PKG;
