library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity comparator is
    port (
        funct3   : in  std_logic_vector(14 downto 12);
		rs1, rs2 : in  std_logic_vector(31 downto 0);
		result   : out std_logic
    );
end entity comparator;

architecture rtl of comparator is

begin
    compare: process(funct3, rs1, rs2)
	begin
		case funct3 is
			when b"000" => -- EQ
				if (rs1 = rs2) then result <= '1'; else result <= '0'; end if;
			when b"001" => -- NE
				if (rs1 /= rs2) then result <= '1'; else result <= '0'; end if;
			when b"100" => -- LT
				if (signed(rs1) < signed(rs2)) then result <= '1'; else result <= '0'; end if;
			when b"101" => -- GE
				if (signed(rs1) >= signed(rs2)) then result <= '1'; else result <= '0'; end if;
			when b"110" => -- LTU
				if (unsigned(rs1) < unsigned(rs2)) then result <= '1'; else result <= '0'; end if;
			when b"111" => -- GEU
				if (unsigned(rs1) >= unsigned(rs2)) then result <= '1'; else result <= '0'; end if;
			when others =>
				result <= '0';
		end case;
	end process compare;

end architecture;