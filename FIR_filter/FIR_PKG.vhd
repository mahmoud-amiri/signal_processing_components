library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library ieee;
use ieee.math_real.all;

package FIR_PKG is
    type real_vector is array (natural range <>) of real;
    type integer_vector is array (natural range <>) of integer;
    function maximum (arr : real_vector) return real;
    function find_opt_scale(coeffs : real_vector) return integer;
    function scale_coeffs(coeffs : real_vector; scale : real) return integer_vector;
end package FIR_PKG;


package body FIR_PKG is
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

    -- find optimum scaling 
    function find_opt_scale(coeffs : real_vector) return integer is
    begin
        return integer(trunc(log2(maximum(coeffs))));
    end find_opt_scale;

    -- Scale a real ceofficient vector and convert to integers
    function scale_coeffs(coeffs : real_vector; scale : real) return integer_vector is
        variable result_vec : integer_vector(0 to coeffs'length-1);
    begin
        for ct in coeffs'range loop
        result_vec(ct) := integer(scale*coeffs(ct));
        end loop;
        return result_vec;
    end scale_coeffs;

end FIR_PKG;
