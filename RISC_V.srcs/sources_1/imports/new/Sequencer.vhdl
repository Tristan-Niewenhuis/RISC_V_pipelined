library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.RISCV_package.all;

entity Sequencer is
    Port(clk, reset : in sl;
         load_inst, store_inst : in sl;
         fetch_busy, load_busy, store_busy, fetch_done, load_store_done : in sl;
         fetch_request, load_request, store_request, PC_inc, if_id_en, id_ex_en, ex_mem_en, mem_wb_en : out sl);
end Sequencer;

architecture Behavioral of Sequencer is
    signal fetch_stall, load_store_stall : sl;
begin
    fetch_stall <= (fetch_request and fetch_busy) and not fetch_done;
    load_store_stall <= ((load_request and load_busy) or (store_request and store_busy)) and not load_store_done;

    if_id_en <= not load_store_stall or fetch_stall;
    id_ex_en <= not load_store_stall;
    ex_mem_en <= not load_store_stall;
    mem_wb_en <= not load_store_stall;

    fetch_request <= not load_store_stall;
    store_request <= store_inst;
    load_request <= load_inst;
    PC_inc <= if_id_en;

end Behavioral;
