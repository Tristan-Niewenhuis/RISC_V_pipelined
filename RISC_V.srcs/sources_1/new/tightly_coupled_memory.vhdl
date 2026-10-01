-- Imported from Larry Pyeatt's RISCV_pyeatt memory_interfaces
-- (tightly_coupled_memory.vhdl), with the USE_NEGEDGE half-cycle read
-- option from cache_data_array.vhdl.
--
-- ============================================================
-- Engineering checkoff log
--   2026-10-01  imported for RISC_V_pipelined; clog2 now comes from
--               RISCV_package; added USE_NEGEDGE for port A
-- ============================================================
--
-- Tightly Coupled Memory (TCM)
--
-- True dual-port BRAM with synchronous read and byte-lane write enables.
-- Port A is the CPU port; port B is the debug/JTAG port.
--
-- Can be used as ITCM or DTCM.  When READ_ONLY is true, CPU writes are
-- rejected and fault is asserted (combinational, same cycle).  The
-- pipeline should use fault to generate a Store/AMO access fault
-- (mcause = 7).  The debug port ignores READ_ONLY and can always
-- read and write.
--
-- Initialization file formats (detected from file extension):
--   .hex -- one 32-bit word per line as hex digits (e.g. "00000093")
--   .bin -- one 32-bit word per line as binary digits
--   .coe -- Xilinx COE format (radix 2, 10, or 16; both
--           memory_initialization_radix and memory_initialization_vector
--           lines required)
--
-- Vivado compatibility: init functions avoid VHDL access type operations
-- (null checks, .all dereference) that Vivado synthesis does not support.
--
-- Generics:
--   SIZE_BYTES  -- memory size in bytes (must be power of 2, >= 8)
--   INIT_FILE   -- path to initialization file ("" for all zeros)
--   READ_ONLY   -- when true, CPU writes are rejected with fault='1'
--   USE_NEGEDGE -- when true, port A is clocked on the falling edge
--
-- The memory uses the lower address bits for indexing.  The instantiating
-- level is responsible for address decoding.  SIZE_BYTES must be
-- naturally aligned (base address must be a multiple of SIZE_BYTES).
--
-- Timing: synchronous read (1-cycle latency, read-first) on both ports.
-- ready is always '1'.  fault is combinational.
--
-- Half-cycle option (USE_NEGEDGE, from cache_data_array):
--   USE_NEGEDGE=false (default): port A is clocked on the rising edge.
--   USE_NEGEDGE=true:  port A is clocked on the FALLING edge of clk.
--     The BRAM captures the address at mid-cycle and its output
--     settles before the next rising edge (~2.1 ns clock-to-Q vs 5 ns
--     half-period at 100 MHz), so rising-edge logic sees read data in
--     the same cycle it presents the address.  The address must be
--     valid by mid-cycle.  A BRAM port has a single clock, so port A
--     WRITES also happen on the falling edge; designs that need
--     full-cycle write timing should write through port B, which is
--     always clocked on the rising edge.
--
-- All init functions report severity failure on malformed input,
-- which terminates elaboration in both GHDL and Vivado.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.RISCV_package.clog2;

library std;
use std.textio.all;

use ieee.std_logic_textio.all;

entity tightly_coupled_memory is
  generic(
    SIZE_BYTES  : natural := 4096;
    INIT_FILE   : string  := "";
    READ_ONLY   : boolean := false;
    USE_NEGEDGE : boolean := false
  );
  port(
    clk   : in  std_logic;

    -- CPU port (port A)
    addr  : in  std_logic_vector(31 downto 0);
    wdata : in  std_logic_vector(31 downto 0);
    rdata : out std_logic_vector(31 downto 0);
    we    : in  std_logic;
    wstrb : in  std_logic_vector(3 downto 0);
    ready : out std_logic;
    fault : out std_logic;

    -- Debug / JTAG port (port B) — ignores READ_ONLY
    dbg_addr  : in  std_logic_vector(31 downto 0);
    dbg_wdata : in  std_logic_vector(31 downto 0);
    dbg_rdata : out std_logic_vector(31 downto 0);
    dbg_we    : in  std_logic;
    dbg_wstrb : in  std_logic_vector(3 downto 0)
  );
end tightly_coupled_memory;

architecture behavioral of tightly_coupled_memory is

  constant NUM_WORDS : natural := SIZE_BYTES / 4;
  constant ADDR_BITS : natural := clog2(SIZE_BYTES);

  type mem_type is array(0 to NUM_WORDS - 1)
    of std_logic_vector(31 downto 0);

  ---------------------------------------------------------------------------
  -- Helper functions
  ---------------------------------------------------------------------------

  function is_hex_char(c : character) return boolean is
  begin
    return (c >= '0' and c <= '9') or
           (c >= 'a' and c <= 'f') or
           (c >= 'A' and c <= 'F');
  end function;

  -- Left-pad string s with '0' to the given width.
  function zero_pad(s : string; width : positive) return string is
    variable result : string(1 to width) := (others => '0');
    variable slen   : natural := s'length;
  begin
    if slen >= width then
      for i in 0 to width - 1 loop
        result(width - i) := s(s'right - i);
      end loop;
    else
      for i in 0 to slen - 1 loop
        result(width - i) := s(s'right - i);
      end loop;
    end if;
    return result;
  end function;

  -- Convert a decimal digit string to natural.
  function str_to_nat(s : string; len : natural) return natural is
    variable result : natural := 0;
  begin
    for i in 1 to len loop
      assert s(i) >= '0' and s(i) <= '9'
        report "TCM init_coe: non-digit '" & s(i) &
               "' in decimal value at position " & integer'image(i)
        severity failure;
      result := result * 10 + (character'pos(s(i)) - character'pos('0'));
    end loop;
    return result;
  end function;

  function to_lower(c : character) return character is
  begin
    if c >= 'A' and c <= 'Z' then
      return character'val(character'pos(c) + 32);
    else
      return c;
    end if;
  end function;

  -- Return the portion of filename after the last '.', lower-cased.
  -- Returns "" if there is no '.'.  Max 8-character extension.
  function file_extension(filename : string) return string is
    variable dot_pos : integer := 0;
    variable ext     : string(1 to 8) := (others => ' ');
    variable ext_len : natural := 0;
  begin
    for i in filename'right downto filename'left loop
      if filename(i) = '.' then
        dot_pos := i;
        ext_len := filename'right - dot_pos;
        if ext_len = 0 or ext_len > 8 then
          return "";
        end if;
        for j in 1 to ext_len loop
          ext(j) := to_lower(filename(dot_pos + j));
        end loop;
        return ext(1 to ext_len);
      end if;
    end loop;
    return "";
  end function;

  ---------------------------------------------------------------------------
  -- Hex text format: one 32-bit word per line as hex digits
  ---------------------------------------------------------------------------
  impure function init_hex(filename : string) return mem_type is
    file f        : text;
    variable stat : file_open_status;
    variable l    : line;
    variable mem  : mem_type := (others => (others => '0'));
    variable v    : std_logic_vector(31 downto 0);
    variable good : boolean;
    variable lineno : natural := 0;
  begin
    file_open(stat, f, filename, read_mode);
    if stat /= open_ok then
      assert false
        report "TCM init_hex: cannot open """ & filename & """"
        severity failure;
      return mem;
    end if;

    for i in 0 to NUM_WORDS - 1 loop
      if not endfile(f) then
        readline(f, l);
        lineno := lineno + 1;
        hread(l, v, good);
        if good then
          mem(i) := v;
        end if;
      end if;
    end loop;

    file_close(f);
    return mem;
  end function;

  ---------------------------------------------------------------------------
  -- Binary text format: one 32-bit word per line as binary digits
  ---------------------------------------------------------------------------
  impure function init_bin(filename : string) return mem_type is
    file f        : text;
    variable stat : file_open_status;
    variable l    : line;
    variable mem  : mem_type := (others => (others => '0'));
    variable v    : std_logic_vector(31 downto 0);
    variable good : boolean;
    variable lineno : natural := 0;
  begin
    file_open(stat, f, filename, read_mode);
    if stat /= open_ok then
      assert false
        report "TCM init_bin: cannot open """ & filename & """"
        severity failure;
      return mem;
    end if;

    for i in 0 to NUM_WORDS - 1 loop
      if not endfile(f) then
        readline(f, l);
        lineno := lineno + 1;
        read(l, v, good);
        if good then
          mem(i) := v;
        end if;
      end if;
    end loop;

    file_close(f);
    return mem;
  end function;

  ---------------------------------------------------------------------------
  -- Xilinx COE format
  --
  -- Expects both memory_initialization_radix and
  -- memory_initialization_vector lines.  Supports radix 2, 10, and 16.
  -- Comments (lines starting with ';') are skipped.
  --
  -- Parsing strategy: count '=' signs.  The first '=' introduces the
  -- radix value; the second '=' introduces the data values.  Data values
  -- are separated by ',' and terminated by ';'.
  ---------------------------------------------------------------------------
  impure function init_coe(filename : string) return mem_type is
    file f          : text;
    variable stat     : file_open_status;
    variable l        : line;
    variable mem      : mem_type := (others => (others => '0'));
    variable c        : character;
    variable good     : boolean;
    variable eq_count   : integer := 0;
    variable in_data    : boolean := false;
    variable idx        : integer := 0;
    variable buf        : string(1 to 32);
    variable buflen     : integer := 0;
    variable radix_buf  : string(1 to 4);
    variable radix_len  : integer := 0;
    variable radix      : integer := 16;
    variable v          : std_logic_vector(31 downto 0);
    variable temp_line  : line;
    variable skip_line  : boolean;
    variable int_val    : natural;
    variable first_char : boolean;
    variable lineno     : natural := 0;
    variable val_count  : natural := 0;

    -- Emit the value accumulated in buf(1..buflen).
    -- Returns false on parse error (err_msg set via assert failure).
    impure function emit_value return boolean is
    begin
      if buflen = 0 then
        return true;  -- nothing to emit, not an error
      end if;
      v := (others => '0');
      good := false;
      if radix = 16 then
        if buflen > 8 then
          assert false
            report "TCM init_coe: hex value longer than 8 digits on line " &
                   integer'image(lineno) & " of """ & filename & """"
            severity failure;
          return false;
        end if;
        temp_line := null;
        write(temp_line, zero_pad(buf(1 to buflen), 8));
        hread(temp_line, v, good);
        if not good then
          assert false
            report "TCM init_coe: bad hex value on line " &
                   integer'image(lineno) & " of """ & filename & """"
            severity failure;
          return false;
        end if;
      elsif radix = 2 then
        if buflen > 32 then
          assert false
            report "TCM init_coe: binary value longer than 32 bits on line " &
                   integer'image(lineno) & " of """ & filename & """"
            severity failure;
          return false;
        end if;
        temp_line := null;
        write(temp_line, zero_pad(buf(1 to buflen), 32));
        read(temp_line, v, good);
        if not good then
          assert false
            report "TCM init_coe: bad binary value on line " &
                   integer'image(lineno) & " of """ & filename & """"
            severity failure;
          return false;
        end if;
      elsif radix = 10 then
        int_val := str_to_nat(buf, buflen);
        v := std_logic_vector(to_unsigned(int_val, 32));
        good := true;
      end if;
      if good then
        mem(idx) := v;
      end if;
      idx := idx + 1;
      val_count := val_count + 1;
      buflen := 0;
      return true;
    end function;

  begin
    file_open(stat, f, filename, read_mode);
    if stat /= open_ok then
      assert false
        report "TCM init_coe: cannot open """ & filename & """"
        severity failure;
      return mem;
    end if;

    while not endfile(f) and idx < NUM_WORDS loop
      readline(f, l);
      lineno := lineno + 1;
      skip_line := false;
      first_char := true;

      while not skip_line and idx < NUM_WORDS loop
        -- Check if line is exhausted (read returns good=false)
        read(l, c, good);
        if not good then
          skip_line := true;

          -- Skip comment lines (first non-whitespace is ';')
          elsif first_char and c = ';' then
            skip_line := true;
          elsif first_char and (c = ' ' or c = HT) then
            null;  -- skip leading whitespace, stay on first_char

          elsif in_data then
            first_char := false;
            -----------------------------------------------------------
            -- Data parsing: accumulate digits, emit on ',' or ';'
            -----------------------------------------------------------
            if (radix = 16 and is_hex_char(c)) or
               (radix = 2  and (c = '0' or c = '1')) or
               (radix = 10 and c >= '0' and c <= '9') then
              buflen := buflen + 1;
              if buflen <= 32 then
                buf(buflen) := c;
              end if;
            elsif c = ',' or c = ';' then
              if not emit_value then
                file_close(f);
                return mem;
              end if;
              if c = ';' then
                skip_line := true;  -- rest of line is comment
              end if;
            elsif c /= ' ' and c /= HT then
              file_close(f);
              assert false
                report "TCM init_coe: unexpected character '" & c &
                       "' in data on line " & integer'image(lineno) &
                       " of """ & filename & """"
                severity failure;
              return mem;
            end if;

          else
            first_char := false;
            -----------------------------------------------------------
            -- Header parsing: find radix and vector start
            -----------------------------------------------------------
            if c = '=' then
              if eq_count = 0 then
                eq_count := 1;
                radix_len := 0;
              else
                eq_count := 2;
                in_data := true;
                buflen := 0;
              end if;
            elsif eq_count = 1 then
              if c >= '0' and c <= '9' then
                radix_len := radix_len + 1;
                if radix_len <= 4 then
                  radix_buf(radix_len) := c;
                end if;
              elsif c = ';' then
                -- Determine radix from accumulated digits
                if radix_len = 1 and radix_buf(1) = '2' then
                  radix := 2;
                elsif radix_len = 2 and radix_buf(1 to 2) = "10" then
                  radix := 10;
                elsif radix_len = 2 and radix_buf(1 to 2) = "16" then
                  radix := 16;
                else
                  file_close(f);
                  assert false
                    report "TCM init_coe: unsupported radix """ &
                           radix_buf(1 to radix_len) &
                           """ on line " & integer'image(lineno) &
                           " of """ & filename &
                           """ (must be 2, 10, or 16)"
                    severity failure;
                  return mem;
                end if;
                skip_line := true;
              end if;
            elsif c = ';' then
              skip_line := true;  -- comment or stray semicolon
            end if;
          end if;
      end loop;
    end loop;

    -- Handle last value if file ends without trailing comma/semicolon
    if buflen > 0 and idx < NUM_WORDS then
      if not emit_value then
        file_close(f);
        return mem;
      end if;
    end if;

    if not in_data then
      file_close(f);
      assert false
        report "TCM init_coe: no memory_initialization_vector found in """ &
               filename & """ (expected two '=' signs)"
        severity failure;
      return mem;
    end if;

    if val_count = 0 then
      file_close(f);
      assert false
        report "TCM init_coe: no data values found in """ & filename & """"
        severity failure;
      return mem;
    end if;

    file_close(f);
    return mem;
  end function;

  ---------------------------------------------------------------------------
  -- Dispatcher: detect format from file extension, open and parse.
  ---------------------------------------------------------------------------
  impure function init_mem(filename : string) return mem_type is
    constant ext : string := file_extension(filename);
  begin
    if filename'length = 0 then
      return (others => (others => '0'));
    end if;

    assert ext'length > 0
      report "TCM init: no file extension on """ & filename &
             """ (expected .hex, .bin, or .coe)"
      severity failure;

    if ext = "hex" then
      return init_hex(filename);
    elsif ext = "bin" then
      return init_bin(filename);
    elsif ext = "coe" then
      return init_coe(filename);
    end if;

    assert false
      report "TCM init: unrecognised extension ""." & ext &
             """ on """ & filename &
             """ (expected .hex, .bin, or .coe)"
      severity failure;

    return (others => (others => '0'));
  end function;

  shared variable mem : mem_type := init_mem(INIT_FILE);
  attribute ram_style : string;
  attribute ram_style of mem : variable is "block";

begin

  ---------------------------------------------------------------------------
  -- True dual-port BRAM (two processes, UG901 pattern).
  -- Port A = CPU, port B = debug/JTAG.
  -- Separate processes required for Vivado BRAM inference.
  -- CPU writes are suppressed when READ_ONLY is true.
  ---------------------------------------------------------------------------
  -- Port A edge is selected by USE_NEGEDGE (see header).
  gen_port_a_posedge : if not USE_NEGEDGE generate
    port_a : process(clk)
      variable cpu_word_addr : natural;
    begin
      if rising_edge(clk) then
        cpu_word_addr := to_integer(unsigned(addr(ADDR_BITS - 1 downto 2)));

        -- Port A: CPU read (synchronous, read-first)
        rdata <= mem(cpu_word_addr);

        -- Port A: CPU write (suppressed when READ_ONLY)
        if we = '1' and not READ_ONLY then
          if wstrb(0) = '1' then
            mem(cpu_word_addr)(7 downto 0) := wdata(7 downto 0);
          end if;
          if wstrb(1) = '1' then
            mem(cpu_word_addr)(15 downto 8) := wdata(15 downto 8);
          end if;
          if wstrb(2) = '1' then
            mem(cpu_word_addr)(23 downto 16) := wdata(23 downto 16);
          end if;
          if wstrb(3) = '1' then
            mem(cpu_word_addr)(31 downto 24) := wdata(31 downto 24);
          end if;
        end if;
      end if;
    end process;
  end generate;

  gen_port_a_negedge : if USE_NEGEDGE generate
    port_a : process(clk)
      variable cpu_word_addr : natural;
    begin
      if falling_edge(clk) then
        cpu_word_addr := to_integer(unsigned(addr(ADDR_BITS - 1 downto 2)));

        -- Port A: CPU read (synchronous, read-first)
        rdata <= mem(cpu_word_addr);

        -- Port A: CPU write (suppressed when READ_ONLY)
        if we = '1' and not READ_ONLY then
          if wstrb(0) = '1' then
            mem(cpu_word_addr)(7 downto 0) := wdata(7 downto 0);
          end if;
          if wstrb(1) = '1' then
            mem(cpu_word_addr)(15 downto 8) := wdata(15 downto 8);
          end if;
          if wstrb(2) = '1' then
            mem(cpu_word_addr)(23 downto 16) := wdata(23 downto 16);
          end if;
          if wstrb(3) = '1' then
            mem(cpu_word_addr)(31 downto 24) := wdata(31 downto 24);
          end if;
        end if;
      end if;
    end process;
  end generate;

  port_b : process(clk)
    variable dbg_word_addr : natural;
  begin
    if rising_edge(clk) then
      dbg_word_addr := to_integer(unsigned(dbg_addr(ADDR_BITS - 1 downto 2)));

      -- Port B: debug read (synchronous, read-first)
      dbg_rdata <= mem(dbg_word_addr);

      -- Port B: debug write (always allowed)
      if dbg_we = '1' then
        if dbg_wstrb(0) = '1' then
          mem(dbg_word_addr)(7 downto 0) := dbg_wdata(7 downto 0);
        end if;
        if dbg_wstrb(1) = '1' then
          mem(dbg_word_addr)(15 downto 8) := dbg_wdata(15 downto 8);
        end if;
        if dbg_wstrb(2) = '1' then
          mem(dbg_word_addr)(23 downto 16) := dbg_wdata(23 downto 16);
        end if;
        if dbg_wstrb(3) = '1' then
          mem(dbg_word_addr)(31 downto 24) := dbg_wdata(31 downto 24);
        end if;
      end if;
    end if;
  end process;

  -- TCM always responds in one clock cycle
  ready <= '1';

  -- Store access fault: combinational, fires same cycle as the write attempt
  ro_fault: if READ_ONLY generate
    fault <= we;
  end generate;
  rw_fault: if not READ_ONLY generate
    fault <= '0';
  end generate;

end behavioral;
