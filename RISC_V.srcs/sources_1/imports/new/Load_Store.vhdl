library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.RISCV_package.all;

entity Load_Store is
	port(
		load_store : in sl; --1 is load, 0 is store
		access_type : in slv(2 downto 0);
		ls_address_in : in slv(D_ADDR_BITS - 1 downto 0);
		store_data : in slv(31 downto 0);
		load_data_out : out slv(31 downto 0);
		--bram port
		ls_address_out : out slv(D_ADDR_BITS - 1 downto 0);
		load_data_in : in slv(31 downto 0);
		store_data_out : out slv(31 downto 0);
		write_strobe : out slv(3 downto 0);
	);
end Load_Store;

architecture implementation of Load_Store is
	signal pre_load_data : slv(31 downto 0);
	signal byte_mask, half_mask, pre_mask : slv(3 downto 0);
begin
	ls_address_out <= ls_address_in;
	--format load_store_out
	with ls_address_in(1 downto 0) select pre_load_data <=
		(31 downto 8 => '0') & load_data_in(15 downto 8) when "01",
		(31 downto 8 => '0') & load_data_in(31 downto 24) when "11",
		(31 downto 16 => '0') & load_data_in(31 downto 16) when "10",
		load_data_in(31 downto 0) when others;

	with access_type select load_data_out <=
		(31 downto 8 => pre_load_data(7)) & pre_load_data(7 downto 0) when "000",
		(31 downto 16 => pre_load_data(15)) & pre_load_data(15 downto 0) when "001",
		(31 downto 8 => '0') & pre_load_data(7 downto 0) when "100",
		(31 downto 16 => '0') & pre_load_data(15 downto 0) when "101",
		pre_load_data when others; --"010"

	--format store data
	with ls_address_in(1 downto 0) select store_data_out <=
		(31 downto 16 => '0') & store_data(7 downto 0) & (7 downto 0 => '0') when "01",
		store_data(7 downto 0) & (23 downto 0 => '0') when "11",
		store_data(15 downto 0) & (15 downto 0 => '0') when "10",
		store_data when others;
	with ls_address_in(1 downto 0) select byte_mask <=
		"0001" when "00",
		"0010" when "01",
		"0100" when "10",
		"1000" when others; --"11"
	half_mask <= "0011" when ls_address_in(1) = '0' else "1100";

	with access_type(1 downto 0) select pre_mask <=
		byte_mask when "00",
		half_mask when "01",
		"1111" when others;

	write_strobe <= pre_mask when load_store = '0' else "0000";
end implementation;
