library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.RISCV_package.all;

entity Sequencer is
    Port(clk, reset : in sl;
         load_inst, store_inst : in sl;
         fetch_done, load_done, store_done : in sl;
         start_fetch, start_load, start_store, ex, PC_inc : out sl);
end Sequencer;

architecture Behavioral of Sequencer is
    type state_t is (RESETING, FETCH, DECODE, LOAD1, LOAD2, STORE1, STORE2, EXECUTE);
    signal cur_state, next_state_i, next_state_final : state_t;
    signal RESETING_next, FETCH_next, EXECUTE_next : state_t;
    signal DECODE_next, LOAD1_next, LOAD2_next, STORE1_next, STORE2_next : state_t;
    signal ctrl : slv(1 downto 0);
begin
    --memory
    cur_state <= next_state_final when rising_edge(clk);
    next_state_final <= RESETING when reset = '1' else next_state_i;
    --next state
    with cur_state select next_state_i <=
        RESETING_next when RESETING,
        FETCH_next when FETCH,
        DECODE_next when DECODE,
        LOAD1_next when LOAD1,
        LOAD2_next when LOAD2,
        STORE1_next when STORE1,
        STORE2_next when STORE2,
        EXECUTE_next when EXECUTE;

    RESETING_next <= FETCH;

    FETCH_next <= DECODE when fetch_done = '1' else FETCH;

    ctrl <= load_inst & store_inst;
    with ctrl select DECODE_next <=
        EXECUTE when "00",
        LOAD1 when "10",
        STORE1 when others;

    LOAD1_next <= LOAD2;
    LOAD2_next <= EXECUTE when load_done = '1' else LOAD2;

    STORE1_next <= STORE2;
    STORE2_next <= FETCH when store_done = '1' else STORE2;

    EXECUTE_next <= FETCH;

    --outputs moore
    start_fetch <= '1' when cur_state = FETCH else '0';
    ex <= '1' when cur_state = EXECUTE else '0';
    start_load <= '1' when cur_state = LOAD1 else '0';
    start_store <= '1' when cur_state = STORE1 else '0';

    --outputs mealy 
    PC_inc <= '1' when cur_state = FETCH and fetch_done = '1' else '0';

end Behavioral;
