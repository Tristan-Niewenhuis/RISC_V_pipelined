--Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
--Copyright 2022-2026 Advanced Micro Devices, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2026.1 (win64) Build 6511674 Tue Jun 16 11:02:23 MDT 2026
--Date        : Fri Aug 28 09:28:08 2026
--Host        : DESKTOP-P2Q0K54 running 64-bit major release  (build 9200)
--Command     : generate_target RISC_V_block.bd
--Design      : RISC_V_block
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity RISC_V_block is
  port (
    dip_switches_16bits_tri_i : in STD_LOGIC_VECTOR ( 15 downto 0 );
    led_16bits_tri_o : out STD_LOGIC_VECTOR ( 15 downto 0 );
    resetn : in STD_LOGIC;
    sys_clock : in STD_LOGIC
  );
  attribute CORE_GENERATION_INFO : string;
  attribute CORE_GENERATION_INFO of RISC_V_block : entity is "RISC_V_block,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=RISC_V_block,x_ipVersion=1.00.a,x_ipLanguage=VHDL}";
  attribute HW_HANDOFF : string;
  attribute HW_HANDOFF of RISC_V_block : entity is "RISC_V_block.hwdef";
end RISC_V_block;

architecture STRUCTURE of RISC_V_block is
  component RISC_V_block_RISC_V_0_0 is
  port (
    clk : in STD_LOGIC;
    reset : in STD_LOGIC;
    f_M_AXI_ARID : out STD_LOGIC_VECTOR ( 0 to 0 );
    f_M_AXI_ARADDR : out STD_LOGIC_VECTOR ( 31 downto 0 );
    f_M_AXI_ARLEN : out STD_LOGIC_VECTOR ( 7 downto 0 );
    f_M_AXI_ARSIZE : out STD_LOGIC_VECTOR ( 2 downto 0 );
    f_M_AXI_ARBURST : out STD_LOGIC_VECTOR ( 1 downto 0 );
    f_M_AXI_ARLOCK : out STD_LOGIC;
    f_M_AXI_ARCACHE : out STD_LOGIC_VECTOR ( 3 downto 0 );
    f_M_AXI_ARPROT : out STD_LOGIC_VECTOR ( 2 downto 0 );
    f_M_AXI_ARQOS : out STD_LOGIC_VECTOR ( 3 downto 0 );
    f_M_AXI_ARVALID : out STD_LOGIC;
    f_M_AXI_ARREADY : in STD_LOGIC;
    f_M_AXI_RID : in STD_LOGIC_VECTOR ( 0 to 0 );
    f_M_AXI_RDATA : in STD_LOGIC_VECTOR ( 31 downto 0 );
    f_M_AXI_RRESP : in STD_LOGIC_VECTOR ( 1 downto 0 );
    f_M_AXI_RLAST : in STD_LOGIC;
    f_M_AXI_RVALID : in STD_LOGIC;
    f_M_AXI_RREADY : out STD_LOGIC;
    ls_M_AXI_ARID : out STD_LOGIC_VECTOR ( 0 to 0 );
    ls_M_AXI_ARADDR : out STD_LOGIC_VECTOR ( 31 downto 0 );
    ls_M_AXI_ARLEN : out STD_LOGIC_VECTOR ( 7 downto 0 );
    ls_M_AXI_ARSIZE : out STD_LOGIC_VECTOR ( 2 downto 0 );
    ls_M_AXI_ARBURST : out STD_LOGIC_VECTOR ( 1 downto 0 );
    ls_M_AXI_ARLOCK : out STD_LOGIC;
    ls_M_AXI_ARCACHE : out STD_LOGIC_VECTOR ( 3 downto 0 );
    ls_M_AXI_ARPROT : out STD_LOGIC_VECTOR ( 2 downto 0 );
    ls_M_AXI_ARQOS : out STD_LOGIC_VECTOR ( 3 downto 0 );
    ls_M_AXI_ARVALID : out STD_LOGIC;
    ls_M_AXI_ARREADY : in STD_LOGIC;
    ls_M_AXI_RID : in STD_LOGIC_VECTOR ( 0 to 0 );
    ls_M_AXI_RDATA : in STD_LOGIC_VECTOR ( 31 downto 0 );
    ls_M_AXI_RRESP : in STD_LOGIC_VECTOR ( 1 downto 0 );
    ls_M_AXI_RLAST : in STD_LOGIC;
    ls_M_AXI_RVALID : in STD_LOGIC;
    ls_M_AXI_RREADY : out STD_LOGIC;
    ls_M_AXI_AWID : out STD_LOGIC_VECTOR ( 0 to 0 );
    ls_M_AXI_AWADDR : out STD_LOGIC_VECTOR ( 31 downto 0 );
    ls_M_AXI_AWLEN : out STD_LOGIC_VECTOR ( 7 downto 0 );
    ls_M_AXI_AWSIZE : out STD_LOGIC_VECTOR ( 2 downto 0 );
    ls_M_AXI_AWBURST : out STD_LOGIC_VECTOR ( 1 downto 0 );
    ls_M_AXI_AWLOCK : out STD_LOGIC;
    ls_M_AXI_AWCACHE : out STD_LOGIC_VECTOR ( 3 downto 0 );
    ls_M_AXI_AWPROT : out STD_LOGIC_VECTOR ( 2 downto 0 );
    ls_M_AXI_AWQOS : out STD_LOGIC_VECTOR ( 3 downto 0 );
    ls_M_AXI_AWVALID : out STD_LOGIC;
    ls_M_AXI_AWREADY : in STD_LOGIC;
    ls_M_AXI_WDATA : out STD_LOGIC_VECTOR ( 31 downto 0 );
    ls_M_AXI_WSTRB : out STD_LOGIC_VECTOR ( 3 downto 0 );
    ls_M_AXI_WLAST : out STD_LOGIC;
    ls_M_AXI_WVALID : out STD_LOGIC;
    ls_M_AXI_WREADY : in STD_LOGIC;
    ls_M_AXI_BID : in STD_LOGIC_VECTOR ( 0 to 0 );
    ls_M_AXI_BRESP : in STD_LOGIC_VECTOR ( 1 downto 0 );
    ls_M_AXI_BVALID : in STD_LOGIC;
    ls_M_AXI_BREADY : out STD_LOGIC
  );
  end component RISC_V_block_RISC_V_0_0;
  component RISC_V_block_axi_bram_ctrl_0_0 is
  port (
    s_axi_aclk : in STD_LOGIC;
    s_axi_aresetn : in STD_LOGIC;
    s_axi_awaddr : in STD_LOGIC_VECTOR ( 14 downto 0 );
    s_axi_awlen : in STD_LOGIC_VECTOR ( 7 downto 0 );
    s_axi_awsize : in STD_LOGIC_VECTOR ( 2 downto 0 );
    s_axi_awburst : in STD_LOGIC_VECTOR ( 1 downto 0 );
    s_axi_awlock : in STD_LOGIC;
    s_axi_awcache : in STD_LOGIC_VECTOR ( 3 downto 0 );
    s_axi_awprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
    s_axi_awvalid : in STD_LOGIC;
    s_axi_awready : out STD_LOGIC;
    s_axi_wdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    s_axi_wstrb : in STD_LOGIC_VECTOR ( 3 downto 0 );
    s_axi_wlast : in STD_LOGIC;
    s_axi_wvalid : in STD_LOGIC;
    s_axi_wready : out STD_LOGIC;
    s_axi_bresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    s_axi_bvalid : out STD_LOGIC;
    s_axi_bready : in STD_LOGIC;
    s_axi_araddr : in STD_LOGIC_VECTOR ( 14 downto 0 );
    s_axi_arlen : in STD_LOGIC_VECTOR ( 7 downto 0 );
    s_axi_arsize : in STD_LOGIC_VECTOR ( 2 downto 0 );
    s_axi_arburst : in STD_LOGIC_VECTOR ( 1 downto 0 );
    s_axi_arlock : in STD_LOGIC;
    s_axi_arcache : in STD_LOGIC_VECTOR ( 3 downto 0 );
    s_axi_arprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
    s_axi_arvalid : in STD_LOGIC;
    s_axi_arready : out STD_LOGIC;
    s_axi_rdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    s_axi_rresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    s_axi_rlast : out STD_LOGIC;
    s_axi_rvalid : out STD_LOGIC;
    s_axi_rready : in STD_LOGIC;
    bram_rst_a : out STD_LOGIC;
    bram_clk_a : out STD_LOGIC;
    bram_en_a : out STD_LOGIC;
    bram_we_a : out STD_LOGIC_VECTOR ( 3 downto 0 );
    bram_addr_a : out STD_LOGIC_VECTOR ( 14 downto 0 );
    bram_wrdata_a : out STD_LOGIC_VECTOR ( 31 downto 0 );
    bram_rddata_a : in STD_LOGIC_VECTOR ( 31 downto 0 )
  );
  end component RISC_V_block_axi_bram_ctrl_0_0;
  component RISC_V_block_axi_bram_ctrl_0_bram_0 is
  port (
    clka : in STD_LOGIC;
    rsta : in STD_LOGIC;
    ena : in STD_LOGIC;
    addra : in STD_LOGIC_VECTOR ( 31 downto 0 );
    douta : out STD_LOGIC_VECTOR ( 31 downto 0 );
    rsta_busy : out STD_LOGIC
  );
  end component RISC_V_block_axi_bram_ctrl_0_bram_0;
  component RISC_V_block_axi_bram_ctrl_1_0 is
  port (
    s_axi_aclk : in STD_LOGIC;
    s_axi_aresetn : in STD_LOGIC;
    s_axi_awaddr : in STD_LOGIC_VECTOR ( 14 downto 0 );
    s_axi_awlen : in STD_LOGIC_VECTOR ( 7 downto 0 );
    s_axi_awsize : in STD_LOGIC_VECTOR ( 2 downto 0 );
    s_axi_awburst : in STD_LOGIC_VECTOR ( 1 downto 0 );
    s_axi_awlock : in STD_LOGIC;
    s_axi_awcache : in STD_LOGIC_VECTOR ( 3 downto 0 );
    s_axi_awprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
    s_axi_awvalid : in STD_LOGIC;
    s_axi_awready : out STD_LOGIC;
    s_axi_wdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    s_axi_wstrb : in STD_LOGIC_VECTOR ( 3 downto 0 );
    s_axi_wlast : in STD_LOGIC;
    s_axi_wvalid : in STD_LOGIC;
    s_axi_wready : out STD_LOGIC;
    s_axi_bresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    s_axi_bvalid : out STD_LOGIC;
    s_axi_bready : in STD_LOGIC;
    s_axi_araddr : in STD_LOGIC_VECTOR ( 14 downto 0 );
    s_axi_arlen : in STD_LOGIC_VECTOR ( 7 downto 0 );
    s_axi_arsize : in STD_LOGIC_VECTOR ( 2 downto 0 );
    s_axi_arburst : in STD_LOGIC_VECTOR ( 1 downto 0 );
    s_axi_arlock : in STD_LOGIC;
    s_axi_arcache : in STD_LOGIC_VECTOR ( 3 downto 0 );
    s_axi_arprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
    s_axi_arvalid : in STD_LOGIC;
    s_axi_arready : out STD_LOGIC;
    s_axi_rdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    s_axi_rresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    s_axi_rlast : out STD_LOGIC;
    s_axi_rvalid : out STD_LOGIC;
    s_axi_rready : in STD_LOGIC;
    bram_rst_a : out STD_LOGIC;
    bram_clk_a : out STD_LOGIC;
    bram_en_a : out STD_LOGIC;
    bram_we_a : out STD_LOGIC_VECTOR ( 3 downto 0 );
    bram_addr_a : out STD_LOGIC_VECTOR ( 14 downto 0 );
    bram_wrdata_a : out STD_LOGIC_VECTOR ( 31 downto 0 );
    bram_rddata_a : in STD_LOGIC_VECTOR ( 31 downto 0 )
  );
  end component RISC_V_block_axi_bram_ctrl_1_0;
  component RISC_V_block_axi_bram_ctrl_1_bram_0 is
  port (
    clka : in STD_LOGIC;
    rsta : in STD_LOGIC;
    ena : in STD_LOGIC;
    wea : in STD_LOGIC_VECTOR ( 3 downto 0 );
    addra : in STD_LOGIC_VECTOR ( 31 downto 0 );
    dina : in STD_LOGIC_VECTOR ( 31 downto 0 );
    douta : out STD_LOGIC_VECTOR ( 31 downto 0 );
    rsta_busy : out STD_LOGIC
  );
  end component RISC_V_block_axi_bram_ctrl_1_bram_0;
  component RISC_V_block_axi_gpio_0_0 is
  port (
    s_axi_aclk : in STD_LOGIC;
    s_axi_aresetn : in STD_LOGIC;
    s_axi_awaddr : in STD_LOGIC_VECTOR ( 8 downto 0 );
    s_axi_awvalid : in STD_LOGIC;
    s_axi_awready : out STD_LOGIC;
    s_axi_wdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    s_axi_wstrb : in STD_LOGIC_VECTOR ( 3 downto 0 );
    s_axi_wvalid : in STD_LOGIC;
    s_axi_wready : out STD_LOGIC;
    s_axi_bresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    s_axi_bvalid : out STD_LOGIC;
    s_axi_bready : in STD_LOGIC;
    s_axi_araddr : in STD_LOGIC_VECTOR ( 8 downto 0 );
    s_axi_arvalid : in STD_LOGIC;
    s_axi_arready : out STD_LOGIC;
    s_axi_rdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    s_axi_rresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    s_axi_rvalid : out STD_LOGIC;
    s_axi_rready : in STD_LOGIC;
    gpio_io_i : in STD_LOGIC_VECTOR ( 15 downto 0 )
  );
  end component RISC_V_block_axi_gpio_0_0;
  component RISC_V_block_axi_gpio_1_0 is
  port (
    s_axi_aclk : in STD_LOGIC;
    s_axi_aresetn : in STD_LOGIC;
    s_axi_awaddr : in STD_LOGIC_VECTOR ( 8 downto 0 );
    s_axi_awvalid : in STD_LOGIC;
    s_axi_awready : out STD_LOGIC;
    s_axi_wdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    s_axi_wstrb : in STD_LOGIC_VECTOR ( 3 downto 0 );
    s_axi_wvalid : in STD_LOGIC;
    s_axi_wready : out STD_LOGIC;
    s_axi_bresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    s_axi_bvalid : out STD_LOGIC;
    s_axi_bready : in STD_LOGIC;
    s_axi_araddr : in STD_LOGIC_VECTOR ( 8 downto 0 );
    s_axi_arvalid : in STD_LOGIC;
    s_axi_arready : out STD_LOGIC;
    s_axi_rdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    s_axi_rresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    s_axi_rvalid : out STD_LOGIC;
    s_axi_rready : in STD_LOGIC;
    gpio_io_o : out STD_LOGIC_VECTOR ( 15 downto 0 )
  );
  end component RISC_V_block_axi_gpio_1_0;
  component RISC_V_block_clk_wiz_0_0 is
  port (
    resetn : in STD_LOGIC;
    clk_in1 : in STD_LOGIC;
    clk_out1 : out STD_LOGIC;
    locked : out STD_LOGIC
  );
  end component RISC_V_block_clk_wiz_0_0;
  component RISC_V_block_proc_sys_reset_0_0 is
  port (
    slowest_sync_clk : in STD_LOGIC;
    ext_reset_in : in STD_LOGIC;
    aux_reset_in : in STD_LOGIC;
    mb_debug_sys_rst : in STD_LOGIC;
    dcm_locked : in STD_LOGIC;
    mb_reset : out STD_LOGIC;
    bus_struct_reset : out STD_LOGIC_VECTOR ( 0 to 0 );
    peripheral_reset : out STD_LOGIC_VECTOR ( 0 to 0 );
    interconnect_aresetn : out STD_LOGIC_VECTOR ( 0 to 0 );
    peripheral_aresetn : out STD_LOGIC_VECTOR ( 0 to 0 )
  );
  end component RISC_V_block_proc_sys_reset_0_0;
  component RISC_V_block_smartconnect_0_0 is
  port (
    aclk : in STD_LOGIC;
    aresetn : in STD_LOGIC;
    S00_AXI_arid : in STD_LOGIC_VECTOR ( 0 to 0 );
    S00_AXI_araddr : in STD_LOGIC_VECTOR ( 31 downto 0 );
    S00_AXI_arlen : in STD_LOGIC_VECTOR ( 7 downto 0 );
    S00_AXI_arsize : in STD_LOGIC_VECTOR ( 2 downto 0 );
    S00_AXI_arburst : in STD_LOGIC_VECTOR ( 1 downto 0 );
    S00_AXI_arlock : in STD_LOGIC_VECTOR ( 0 to 0 );
    S00_AXI_arcache : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S00_AXI_arprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
    S00_AXI_arqos : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S00_AXI_arvalid : in STD_LOGIC;
    S00_AXI_arready : out STD_LOGIC;
    S00_AXI_rid : out STD_LOGIC_VECTOR ( 0 to 0 );
    S00_AXI_rdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    S00_AXI_rresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    S00_AXI_rlast : out STD_LOGIC;
    S00_AXI_rvalid : out STD_LOGIC;
    S00_AXI_rready : in STD_LOGIC;
    S01_AXI_awid : in STD_LOGIC_VECTOR ( 0 to 0 );
    S01_AXI_awaddr : in STD_LOGIC_VECTOR ( 31 downto 0 );
    S01_AXI_awlen : in STD_LOGIC_VECTOR ( 7 downto 0 );
    S01_AXI_awsize : in STD_LOGIC_VECTOR ( 2 downto 0 );
    S01_AXI_awburst : in STD_LOGIC_VECTOR ( 1 downto 0 );
    S01_AXI_awlock : in STD_LOGIC_VECTOR ( 0 to 0 );
    S01_AXI_awcache : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S01_AXI_awprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
    S01_AXI_awqos : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S01_AXI_awvalid : in STD_LOGIC;
    S01_AXI_awready : out STD_LOGIC;
    S01_AXI_wdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    S01_AXI_wstrb : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S01_AXI_wlast : in STD_LOGIC;
    S01_AXI_wvalid : in STD_LOGIC;
    S01_AXI_wready : out STD_LOGIC;
    S01_AXI_bid : out STD_LOGIC_VECTOR ( 0 to 0 );
    S01_AXI_bresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    S01_AXI_bvalid : out STD_LOGIC;
    S01_AXI_bready : in STD_LOGIC;
    S01_AXI_arid : in STD_LOGIC_VECTOR ( 0 to 0 );
    S01_AXI_araddr : in STD_LOGIC_VECTOR ( 31 downto 0 );
    S01_AXI_arlen : in STD_LOGIC_VECTOR ( 7 downto 0 );
    S01_AXI_arsize : in STD_LOGIC_VECTOR ( 2 downto 0 );
    S01_AXI_arburst : in STD_LOGIC_VECTOR ( 1 downto 0 );
    S01_AXI_arlock : in STD_LOGIC_VECTOR ( 0 to 0 );
    S01_AXI_arcache : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S01_AXI_arprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
    S01_AXI_arqos : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S01_AXI_arvalid : in STD_LOGIC;
    S01_AXI_arready : out STD_LOGIC;
    S01_AXI_rid : out STD_LOGIC_VECTOR ( 0 to 0 );
    S01_AXI_rdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    S01_AXI_rresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    S01_AXI_rlast : out STD_LOGIC;
    S01_AXI_rvalid : out STD_LOGIC;
    S01_AXI_rready : in STD_LOGIC;
    M00_AXI_awaddr : out STD_LOGIC_VECTOR ( 14 downto 0 );
    M00_AXI_awlen : out STD_LOGIC_VECTOR ( 7 downto 0 );
    M00_AXI_awsize : out STD_LOGIC_VECTOR ( 2 downto 0 );
    M00_AXI_awburst : out STD_LOGIC_VECTOR ( 1 downto 0 );
    M00_AXI_awlock : out STD_LOGIC_VECTOR ( 0 to 0 );
    M00_AXI_awcache : out STD_LOGIC_VECTOR ( 3 downto 0 );
    M00_AXI_awprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    M00_AXI_awqos : out STD_LOGIC_VECTOR ( 3 downto 0 );
    M00_AXI_awvalid : out STD_LOGIC;
    M00_AXI_awready : in STD_LOGIC;
    M00_AXI_wdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    M00_AXI_wstrb : out STD_LOGIC_VECTOR ( 3 downto 0 );
    M00_AXI_wlast : out STD_LOGIC;
    M00_AXI_wvalid : out STD_LOGIC;
    M00_AXI_wready : in STD_LOGIC;
    M00_AXI_bresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    M00_AXI_bvalid : in STD_LOGIC;
    M00_AXI_bready : out STD_LOGIC;
    M00_AXI_araddr : out STD_LOGIC_VECTOR ( 14 downto 0 );
    M00_AXI_arlen : out STD_LOGIC_VECTOR ( 7 downto 0 );
    M00_AXI_arsize : out STD_LOGIC_VECTOR ( 2 downto 0 );
    M00_AXI_arburst : out STD_LOGIC_VECTOR ( 1 downto 0 );
    M00_AXI_arlock : out STD_LOGIC_VECTOR ( 0 to 0 );
    M00_AXI_arcache : out STD_LOGIC_VECTOR ( 3 downto 0 );
    M00_AXI_arprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    M00_AXI_arqos : out STD_LOGIC_VECTOR ( 3 downto 0 );
    M00_AXI_arvalid : out STD_LOGIC;
    M00_AXI_arready : in STD_LOGIC;
    M00_AXI_rdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    M00_AXI_rresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    M00_AXI_rlast : in STD_LOGIC;
    M00_AXI_rvalid : in STD_LOGIC;
    M00_AXI_rready : out STD_LOGIC;
    M01_AXI_awaddr : out STD_LOGIC_VECTOR ( 14 downto 0 );
    M01_AXI_awlen : out STD_LOGIC_VECTOR ( 7 downto 0 );
    M01_AXI_awsize : out STD_LOGIC_VECTOR ( 2 downto 0 );
    M01_AXI_awburst : out STD_LOGIC_VECTOR ( 1 downto 0 );
    M01_AXI_awlock : out STD_LOGIC_VECTOR ( 0 to 0 );
    M01_AXI_awcache : out STD_LOGIC_VECTOR ( 3 downto 0 );
    M01_AXI_awprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    M01_AXI_awqos : out STD_LOGIC_VECTOR ( 3 downto 0 );
    M01_AXI_awvalid : out STD_LOGIC;
    M01_AXI_awready : in STD_LOGIC;
    M01_AXI_wdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    M01_AXI_wstrb : out STD_LOGIC_VECTOR ( 3 downto 0 );
    M01_AXI_wlast : out STD_LOGIC;
    M01_AXI_wvalid : out STD_LOGIC;
    M01_AXI_wready : in STD_LOGIC;
    M01_AXI_bresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    M01_AXI_bvalid : in STD_LOGIC;
    M01_AXI_bready : out STD_LOGIC;
    M01_AXI_araddr : out STD_LOGIC_VECTOR ( 14 downto 0 );
    M01_AXI_arlen : out STD_LOGIC_VECTOR ( 7 downto 0 );
    M01_AXI_arsize : out STD_LOGIC_VECTOR ( 2 downto 0 );
    M01_AXI_arburst : out STD_LOGIC_VECTOR ( 1 downto 0 );
    M01_AXI_arlock : out STD_LOGIC_VECTOR ( 0 to 0 );
    M01_AXI_arcache : out STD_LOGIC_VECTOR ( 3 downto 0 );
    M01_AXI_arprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    M01_AXI_arqos : out STD_LOGIC_VECTOR ( 3 downto 0 );
    M01_AXI_arvalid : out STD_LOGIC;
    M01_AXI_arready : in STD_LOGIC;
    M01_AXI_rdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    M01_AXI_rresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    M01_AXI_rlast : in STD_LOGIC;
    M01_AXI_rvalid : in STD_LOGIC;
    M01_AXI_rready : out STD_LOGIC;
    M02_AXI_awaddr : out STD_LOGIC_VECTOR ( 8 downto 0 );
    M02_AXI_awprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    M02_AXI_awvalid : out STD_LOGIC;
    M02_AXI_awready : in STD_LOGIC;
    M02_AXI_wdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    M02_AXI_wstrb : out STD_LOGIC_VECTOR ( 3 downto 0 );
    M02_AXI_wvalid : out STD_LOGIC;
    M02_AXI_wready : in STD_LOGIC;
    M02_AXI_bresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    M02_AXI_bvalid : in STD_LOGIC;
    M02_AXI_bready : out STD_LOGIC;
    M02_AXI_araddr : out STD_LOGIC_VECTOR ( 8 downto 0 );
    M02_AXI_arprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    M02_AXI_arvalid : out STD_LOGIC;
    M02_AXI_arready : in STD_LOGIC;
    M02_AXI_rdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    M02_AXI_rresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    M02_AXI_rvalid : in STD_LOGIC;
    M02_AXI_rready : out STD_LOGIC;
    M03_AXI_awaddr : out STD_LOGIC_VECTOR ( 8 downto 0 );
    M03_AXI_awprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    M03_AXI_awvalid : out STD_LOGIC;
    M03_AXI_awready : in STD_LOGIC;
    M03_AXI_wdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    M03_AXI_wstrb : out STD_LOGIC_VECTOR ( 3 downto 0 );
    M03_AXI_wvalid : out STD_LOGIC;
    M03_AXI_wready : in STD_LOGIC;
    M03_AXI_bresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    M03_AXI_bvalid : in STD_LOGIC;
    M03_AXI_bready : out STD_LOGIC;
    M03_AXI_araddr : out STD_LOGIC_VECTOR ( 8 downto 0 );
    M03_AXI_arprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    M03_AXI_arvalid : out STD_LOGIC;
    M03_AXI_arready : in STD_LOGIC;
    M03_AXI_rdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    M03_AXI_rresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    M03_AXI_rvalid : in STD_LOGIC;
    M03_AXI_rready : out STD_LOGIC
  );
  end component RISC_V_block_smartconnect_0_0;
  signal RISC_V_0_f_M_AXI_ARADDR : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal RISC_V_0_f_M_AXI_ARBURST : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal RISC_V_0_f_M_AXI_ARCACHE : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal RISC_V_0_f_M_AXI_ARID : STD_LOGIC_VECTOR ( 0 to 0 );
  signal RISC_V_0_f_M_AXI_ARLEN : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal RISC_V_0_f_M_AXI_ARLOCK : STD_LOGIC;
  signal RISC_V_0_f_M_AXI_ARPROT : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal RISC_V_0_f_M_AXI_ARQOS : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal RISC_V_0_f_M_AXI_ARREADY : STD_LOGIC;
  signal RISC_V_0_f_M_AXI_ARSIZE : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal RISC_V_0_f_M_AXI_ARVALID : STD_LOGIC;
  signal RISC_V_0_f_M_AXI_RDATA : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal RISC_V_0_f_M_AXI_RID : STD_LOGIC_VECTOR ( 0 to 0 );
  signal RISC_V_0_f_M_AXI_RLAST : STD_LOGIC;
  signal RISC_V_0_f_M_AXI_RREADY : STD_LOGIC;
  signal RISC_V_0_f_M_AXI_RRESP : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal RISC_V_0_f_M_AXI_RVALID : STD_LOGIC;
  signal RISC_V_0_ls_M_AXI_ARADDR : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal RISC_V_0_ls_M_AXI_ARBURST : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal RISC_V_0_ls_M_AXI_ARCACHE : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal RISC_V_0_ls_M_AXI_ARID : STD_LOGIC_VECTOR ( 0 to 0 );
  signal RISC_V_0_ls_M_AXI_ARLEN : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal RISC_V_0_ls_M_AXI_ARLOCK : STD_LOGIC;
  signal RISC_V_0_ls_M_AXI_ARPROT : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal RISC_V_0_ls_M_AXI_ARQOS : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal RISC_V_0_ls_M_AXI_ARREADY : STD_LOGIC;
  signal RISC_V_0_ls_M_AXI_ARSIZE : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal RISC_V_0_ls_M_AXI_ARVALID : STD_LOGIC;
  signal RISC_V_0_ls_M_AXI_AWADDR : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal RISC_V_0_ls_M_AXI_AWBURST : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal RISC_V_0_ls_M_AXI_AWCACHE : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal RISC_V_0_ls_M_AXI_AWID : STD_LOGIC_VECTOR ( 0 to 0 );
  signal RISC_V_0_ls_M_AXI_AWLEN : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal RISC_V_0_ls_M_AXI_AWLOCK : STD_LOGIC;
  signal RISC_V_0_ls_M_AXI_AWPROT : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal RISC_V_0_ls_M_AXI_AWQOS : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal RISC_V_0_ls_M_AXI_AWREADY : STD_LOGIC;
  signal RISC_V_0_ls_M_AXI_AWSIZE : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal RISC_V_0_ls_M_AXI_AWVALID : STD_LOGIC;
  signal RISC_V_0_ls_M_AXI_BID : STD_LOGIC_VECTOR ( 0 to 0 );
  signal RISC_V_0_ls_M_AXI_BREADY : STD_LOGIC;
  signal RISC_V_0_ls_M_AXI_BRESP : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal RISC_V_0_ls_M_AXI_BVALID : STD_LOGIC;
  signal RISC_V_0_ls_M_AXI_RDATA : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal RISC_V_0_ls_M_AXI_RID : STD_LOGIC_VECTOR ( 0 to 0 );
  signal RISC_V_0_ls_M_AXI_RLAST : STD_LOGIC;
  signal RISC_V_0_ls_M_AXI_RREADY : STD_LOGIC;
  signal RISC_V_0_ls_M_AXI_RRESP : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal RISC_V_0_ls_M_AXI_RVALID : STD_LOGIC;
  signal RISC_V_0_ls_M_AXI_WDATA : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal RISC_V_0_ls_M_AXI_WLAST : STD_LOGIC;
  signal RISC_V_0_ls_M_AXI_WREADY : STD_LOGIC;
  signal RISC_V_0_ls_M_AXI_WSTRB : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal RISC_V_0_ls_M_AXI_WVALID : STD_LOGIC;
  signal axi_bram_ctrl_0_BRAM_PORTA_ADDR : STD_LOGIC_VECTOR ( 14 downto 0 );
  signal axi_bram_ctrl_0_BRAM_PORTA_CLK : STD_LOGIC;
  signal axi_bram_ctrl_0_BRAM_PORTA_DOUT : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal axi_bram_ctrl_0_BRAM_PORTA_EN : STD_LOGIC;
  signal axi_bram_ctrl_0_BRAM_PORTA_RST : STD_LOGIC;
  signal axi_bram_ctrl_1_BRAM_PORTA_ADDR : STD_LOGIC_VECTOR ( 14 downto 0 );
  signal axi_bram_ctrl_1_BRAM_PORTA_CLK : STD_LOGIC;
  signal axi_bram_ctrl_1_BRAM_PORTA_DIN : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal axi_bram_ctrl_1_BRAM_PORTA_DOUT : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal axi_bram_ctrl_1_BRAM_PORTA_EN : STD_LOGIC;
  signal axi_bram_ctrl_1_BRAM_PORTA_RST : STD_LOGIC;
  signal axi_bram_ctrl_1_BRAM_PORTA_WE : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal clk_wiz_0_clk_out1 : STD_LOGIC;
  signal clk_wiz_0_locked : STD_LOGIC;
  signal ilconstant_0_dout : STD_LOGIC_VECTOR ( 0 to 0 );
  signal ilconstant_1_dout : STD_LOGIC_VECTOR ( 0 to 0 );
  signal proc_sys_reset_0_mb_reset : STD_LOGIC;
  signal proc_sys_reset_0_peripheral_aresetn : STD_LOGIC_VECTOR ( 0 to 0 );
  signal smartconnect_0_M00_AXI_ARADDR : STD_LOGIC_VECTOR ( 14 downto 0 );
  signal smartconnect_0_M00_AXI_ARBURST : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal smartconnect_0_M00_AXI_ARCACHE : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal smartconnect_0_M00_AXI_ARLEN : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal smartconnect_0_M00_AXI_ARLOCK : STD_LOGIC_VECTOR ( 0 to 0 );
  signal smartconnect_0_M00_AXI_ARPROT : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal smartconnect_0_M00_AXI_ARREADY : STD_LOGIC;
  signal smartconnect_0_M00_AXI_ARSIZE : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal smartconnect_0_M00_AXI_ARVALID : STD_LOGIC;
  signal smartconnect_0_M00_AXI_AWADDR : STD_LOGIC_VECTOR ( 14 downto 0 );
  signal smartconnect_0_M00_AXI_AWBURST : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal smartconnect_0_M00_AXI_AWCACHE : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal smartconnect_0_M00_AXI_AWLEN : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal smartconnect_0_M00_AXI_AWLOCK : STD_LOGIC_VECTOR ( 0 to 0 );
  signal smartconnect_0_M00_AXI_AWPROT : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal smartconnect_0_M00_AXI_AWREADY : STD_LOGIC;
  signal smartconnect_0_M00_AXI_AWSIZE : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal smartconnect_0_M00_AXI_AWVALID : STD_LOGIC;
  signal smartconnect_0_M00_AXI_BREADY : STD_LOGIC;
  signal smartconnect_0_M00_AXI_BRESP : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal smartconnect_0_M00_AXI_BVALID : STD_LOGIC;
  signal smartconnect_0_M00_AXI_RDATA : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal smartconnect_0_M00_AXI_RLAST : STD_LOGIC;
  signal smartconnect_0_M00_AXI_RREADY : STD_LOGIC;
  signal smartconnect_0_M00_AXI_RRESP : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal smartconnect_0_M00_AXI_RVALID : STD_LOGIC;
  signal smartconnect_0_M00_AXI_WDATA : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal smartconnect_0_M00_AXI_WLAST : STD_LOGIC;
  signal smartconnect_0_M00_AXI_WREADY : STD_LOGIC;
  signal smartconnect_0_M00_AXI_WSTRB : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal smartconnect_0_M00_AXI_WVALID : STD_LOGIC;
  signal smartconnect_0_M01_AXI_ARADDR : STD_LOGIC_VECTOR ( 14 downto 0 );
  signal smartconnect_0_M01_AXI_ARBURST : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal smartconnect_0_M01_AXI_ARCACHE : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal smartconnect_0_M01_AXI_ARLEN : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal smartconnect_0_M01_AXI_ARLOCK : STD_LOGIC_VECTOR ( 0 to 0 );
  signal smartconnect_0_M01_AXI_ARPROT : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal smartconnect_0_M01_AXI_ARREADY : STD_LOGIC;
  signal smartconnect_0_M01_AXI_ARSIZE : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal smartconnect_0_M01_AXI_ARVALID : STD_LOGIC;
  signal smartconnect_0_M01_AXI_AWADDR : STD_LOGIC_VECTOR ( 14 downto 0 );
  signal smartconnect_0_M01_AXI_AWBURST : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal smartconnect_0_M01_AXI_AWCACHE : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal smartconnect_0_M01_AXI_AWLEN : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal smartconnect_0_M01_AXI_AWLOCK : STD_LOGIC_VECTOR ( 0 to 0 );
  signal smartconnect_0_M01_AXI_AWPROT : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal smartconnect_0_M01_AXI_AWREADY : STD_LOGIC;
  signal smartconnect_0_M01_AXI_AWSIZE : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal smartconnect_0_M01_AXI_AWVALID : STD_LOGIC;
  signal smartconnect_0_M01_AXI_BREADY : STD_LOGIC;
  signal smartconnect_0_M01_AXI_BRESP : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal smartconnect_0_M01_AXI_BVALID : STD_LOGIC;
  signal smartconnect_0_M01_AXI_RDATA : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal smartconnect_0_M01_AXI_RLAST : STD_LOGIC;
  signal smartconnect_0_M01_AXI_RREADY : STD_LOGIC;
  signal smartconnect_0_M01_AXI_RRESP : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal smartconnect_0_M01_AXI_RVALID : STD_LOGIC;
  signal smartconnect_0_M01_AXI_WDATA : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal smartconnect_0_M01_AXI_WLAST : STD_LOGIC;
  signal smartconnect_0_M01_AXI_WREADY : STD_LOGIC;
  signal smartconnect_0_M01_AXI_WSTRB : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal smartconnect_0_M01_AXI_WVALID : STD_LOGIC;
  signal smartconnect_0_M02_AXI_ARADDR : STD_LOGIC_VECTOR ( 8 downto 0 );
  signal smartconnect_0_M02_AXI_ARREADY : STD_LOGIC;
  signal smartconnect_0_M02_AXI_ARVALID : STD_LOGIC;
  signal smartconnect_0_M02_AXI_AWADDR : STD_LOGIC_VECTOR ( 8 downto 0 );
  signal smartconnect_0_M02_AXI_AWREADY : STD_LOGIC;
  signal smartconnect_0_M02_AXI_AWVALID : STD_LOGIC;
  signal smartconnect_0_M02_AXI_BREADY : STD_LOGIC;
  signal smartconnect_0_M02_AXI_BRESP : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal smartconnect_0_M02_AXI_BVALID : STD_LOGIC;
  signal smartconnect_0_M02_AXI_RDATA : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal smartconnect_0_M02_AXI_RREADY : STD_LOGIC;
  signal smartconnect_0_M02_AXI_RRESP : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal smartconnect_0_M02_AXI_RVALID : STD_LOGIC;
  signal smartconnect_0_M02_AXI_WDATA : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal smartconnect_0_M02_AXI_WREADY : STD_LOGIC;
  signal smartconnect_0_M02_AXI_WSTRB : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal smartconnect_0_M02_AXI_WVALID : STD_LOGIC;
  signal smartconnect_0_M03_AXI_ARADDR : STD_LOGIC_VECTOR ( 8 downto 0 );
  signal smartconnect_0_M03_AXI_ARREADY : STD_LOGIC;
  signal smartconnect_0_M03_AXI_ARVALID : STD_LOGIC;
  signal smartconnect_0_M03_AXI_AWADDR : STD_LOGIC_VECTOR ( 8 downto 0 );
  signal smartconnect_0_M03_AXI_AWREADY : STD_LOGIC;
  signal smartconnect_0_M03_AXI_AWVALID : STD_LOGIC;
  signal smartconnect_0_M03_AXI_BREADY : STD_LOGIC;
  signal smartconnect_0_M03_AXI_BRESP : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal smartconnect_0_M03_AXI_BVALID : STD_LOGIC;
  signal smartconnect_0_M03_AXI_RDATA : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal smartconnect_0_M03_AXI_RREADY : STD_LOGIC;
  signal smartconnect_0_M03_AXI_RRESP : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal smartconnect_0_M03_AXI_RVALID : STD_LOGIC;
  signal smartconnect_0_M03_AXI_WDATA : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal smartconnect_0_M03_AXI_WREADY : STD_LOGIC;
  signal smartconnect_0_M03_AXI_WSTRB : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal smartconnect_0_M03_AXI_WVALID : STD_LOGIC;
  signal NLW_axi_bram_ctrl_0_bram_we_a_UNCONNECTED : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal NLW_axi_bram_ctrl_0_bram_wrdata_a_UNCONNECTED : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal NLW_axi_bram_ctrl_0_bram_rsta_busy_UNCONNECTED : STD_LOGIC;
  signal NLW_axi_bram_ctrl_1_bram_rsta_busy_UNCONNECTED : STD_LOGIC;
  signal NLW_proc_sys_reset_0_bus_struct_reset_UNCONNECTED : STD_LOGIC_VECTOR ( 0 to 0 );
  signal NLW_proc_sys_reset_0_interconnect_aresetn_UNCONNECTED : STD_LOGIC_VECTOR ( 0 to 0 );
  signal NLW_proc_sys_reset_0_peripheral_reset_UNCONNECTED : STD_LOGIC_VECTOR ( 0 to 0 );
  signal NLW_smartconnect_0_M00_AXI_arqos_UNCONNECTED : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal NLW_smartconnect_0_M00_AXI_awqos_UNCONNECTED : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal NLW_smartconnect_0_M01_AXI_arqos_UNCONNECTED : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal NLW_smartconnect_0_M01_AXI_awqos_UNCONNECTED : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal NLW_smartconnect_0_M02_AXI_arprot_UNCONNECTED : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal NLW_smartconnect_0_M02_AXI_awprot_UNCONNECTED : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal NLW_smartconnect_0_M03_AXI_arprot_UNCONNECTED : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal NLW_smartconnect_0_M03_AXI_awprot_UNCONNECTED : STD_LOGIC_VECTOR ( 2 downto 0 );
  attribute X_INTERFACE_INFO : string;
  attribute X_INTERFACE_INFO of resetn : signal is "xilinx.com:signal:reset:1.0 RST.RESETN RST";
  attribute X_INTERFACE_PARAMETER : string;
  attribute X_INTERFACE_PARAMETER of resetn : signal is "XIL_INTERFACENAME RST.RESETN, INSERT_VIP 0, POLARITY ACTIVE_LOW";
  attribute X_INTERFACE_INFO of sys_clock : signal is "xilinx.com:signal:clock:1.0 CLK.SYS_CLOCK CLK";
  attribute X_INTERFACE_PARAMETER of sys_clock : signal is "XIL_INTERFACENAME CLK.SYS_CLOCK, CLK_DOMAIN RISC_V_block_sys_clock, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, INSERT_VIP 0, PHASE 0.0";
  attribute X_INTERFACE_INFO of dip_switches_16bits_tri_i : signal is "xilinx.com:interface:gpio:1.0 dip_switches_16bits TRI_I";
  attribute X_INTERFACE_MODE : string;
  attribute X_INTERFACE_MODE of dip_switches_16bits_tri_i : signal is "Master";
  attribute X_INTERFACE_INFO of led_16bits_tri_o : signal is "xilinx.com:interface:gpio:1.0 led_16bits TRI_O";
  attribute X_INTERFACE_MODE of led_16bits_tri_o : signal is "Master";
begin
RISC_V_0: component RISC_V_block_RISC_V_0_0
     port map (
      clk => clk_wiz_0_clk_out1,
      f_M_AXI_ARADDR(31 downto 0) => RISC_V_0_f_M_AXI_ARADDR(31 downto 0),
      f_M_AXI_ARBURST(1 downto 0) => RISC_V_0_f_M_AXI_ARBURST(1 downto 0),
      f_M_AXI_ARCACHE(3 downto 0) => RISC_V_0_f_M_AXI_ARCACHE(3 downto 0),
      f_M_AXI_ARID(0) => RISC_V_0_f_M_AXI_ARID(0),
      f_M_AXI_ARLEN(7 downto 0) => RISC_V_0_f_M_AXI_ARLEN(7 downto 0),
      f_M_AXI_ARLOCK => RISC_V_0_f_M_AXI_ARLOCK,
      f_M_AXI_ARPROT(2 downto 0) => RISC_V_0_f_M_AXI_ARPROT(2 downto 0),
      f_M_AXI_ARQOS(3 downto 0) => RISC_V_0_f_M_AXI_ARQOS(3 downto 0),
      f_M_AXI_ARREADY => RISC_V_0_f_M_AXI_ARREADY,
      f_M_AXI_ARSIZE(2 downto 0) => RISC_V_0_f_M_AXI_ARSIZE(2 downto 0),
      f_M_AXI_ARVALID => RISC_V_0_f_M_AXI_ARVALID,
      f_M_AXI_RDATA(31 downto 0) => RISC_V_0_f_M_AXI_RDATA(31 downto 0),
      f_M_AXI_RID(0) => RISC_V_0_f_M_AXI_RID(0),
      f_M_AXI_RLAST => RISC_V_0_f_M_AXI_RLAST,
      f_M_AXI_RREADY => RISC_V_0_f_M_AXI_RREADY,
      f_M_AXI_RRESP(1 downto 0) => RISC_V_0_f_M_AXI_RRESP(1 downto 0),
      f_M_AXI_RVALID => RISC_V_0_f_M_AXI_RVALID,
      ls_M_AXI_ARADDR(31 downto 0) => RISC_V_0_ls_M_AXI_ARADDR(31 downto 0),
      ls_M_AXI_ARBURST(1 downto 0) => RISC_V_0_ls_M_AXI_ARBURST(1 downto 0),
      ls_M_AXI_ARCACHE(3 downto 0) => RISC_V_0_ls_M_AXI_ARCACHE(3 downto 0),
      ls_M_AXI_ARID(0) => RISC_V_0_ls_M_AXI_ARID(0),
      ls_M_AXI_ARLEN(7 downto 0) => RISC_V_0_ls_M_AXI_ARLEN(7 downto 0),
      ls_M_AXI_ARLOCK => RISC_V_0_ls_M_AXI_ARLOCK,
      ls_M_AXI_ARPROT(2 downto 0) => RISC_V_0_ls_M_AXI_ARPROT(2 downto 0),
      ls_M_AXI_ARQOS(3 downto 0) => RISC_V_0_ls_M_AXI_ARQOS(3 downto 0),
      ls_M_AXI_ARREADY => RISC_V_0_ls_M_AXI_ARREADY,
      ls_M_AXI_ARSIZE(2 downto 0) => RISC_V_0_ls_M_AXI_ARSIZE(2 downto 0),
      ls_M_AXI_ARVALID => RISC_V_0_ls_M_AXI_ARVALID,
      ls_M_AXI_AWADDR(31 downto 0) => RISC_V_0_ls_M_AXI_AWADDR(31 downto 0),
      ls_M_AXI_AWBURST(1 downto 0) => RISC_V_0_ls_M_AXI_AWBURST(1 downto 0),
      ls_M_AXI_AWCACHE(3 downto 0) => RISC_V_0_ls_M_AXI_AWCACHE(3 downto 0),
      ls_M_AXI_AWID(0) => RISC_V_0_ls_M_AXI_AWID(0),
      ls_M_AXI_AWLEN(7 downto 0) => RISC_V_0_ls_M_AXI_AWLEN(7 downto 0),
      ls_M_AXI_AWLOCK => RISC_V_0_ls_M_AXI_AWLOCK,
      ls_M_AXI_AWPROT(2 downto 0) => RISC_V_0_ls_M_AXI_AWPROT(2 downto 0),
      ls_M_AXI_AWQOS(3 downto 0) => RISC_V_0_ls_M_AXI_AWQOS(3 downto 0),
      ls_M_AXI_AWREADY => RISC_V_0_ls_M_AXI_AWREADY,
      ls_M_AXI_AWSIZE(2 downto 0) => RISC_V_0_ls_M_AXI_AWSIZE(2 downto 0),
      ls_M_AXI_AWVALID => RISC_V_0_ls_M_AXI_AWVALID,
      ls_M_AXI_BID(0) => RISC_V_0_ls_M_AXI_BID(0),
      ls_M_AXI_BREADY => RISC_V_0_ls_M_AXI_BREADY,
      ls_M_AXI_BRESP(1 downto 0) => RISC_V_0_ls_M_AXI_BRESP(1 downto 0),
      ls_M_AXI_BVALID => RISC_V_0_ls_M_AXI_BVALID,
      ls_M_AXI_RDATA(31 downto 0) => RISC_V_0_ls_M_AXI_RDATA(31 downto 0),
      ls_M_AXI_RID(0) => RISC_V_0_ls_M_AXI_RID(0),
      ls_M_AXI_RLAST => RISC_V_0_ls_M_AXI_RLAST,
      ls_M_AXI_RREADY => RISC_V_0_ls_M_AXI_RREADY,
      ls_M_AXI_RRESP(1 downto 0) => RISC_V_0_ls_M_AXI_RRESP(1 downto 0),
      ls_M_AXI_RVALID => RISC_V_0_ls_M_AXI_RVALID,
      ls_M_AXI_WDATA(31 downto 0) => RISC_V_0_ls_M_AXI_WDATA(31 downto 0),
      ls_M_AXI_WLAST => RISC_V_0_ls_M_AXI_WLAST,
      ls_M_AXI_WREADY => RISC_V_0_ls_M_AXI_WREADY,
      ls_M_AXI_WSTRB(3 downto 0) => RISC_V_0_ls_M_AXI_WSTRB(3 downto 0),
      ls_M_AXI_WVALID => RISC_V_0_ls_M_AXI_WVALID,
      reset => proc_sys_reset_0_mb_reset
    );
axi_bram_ctrl_0: component RISC_V_block_axi_bram_ctrl_0_0
     port map (
      bram_addr_a(14 downto 0) => axi_bram_ctrl_0_BRAM_PORTA_ADDR(14 downto 0),
      bram_clk_a => axi_bram_ctrl_0_BRAM_PORTA_CLK,
      bram_en_a => axi_bram_ctrl_0_BRAM_PORTA_EN,
      bram_rddata_a(31 downto 0) => axi_bram_ctrl_0_BRAM_PORTA_DOUT(31 downto 0),
      bram_rst_a => axi_bram_ctrl_0_BRAM_PORTA_RST,
      bram_we_a(3 downto 0) => NLW_axi_bram_ctrl_0_bram_we_a_UNCONNECTED(3 downto 0),
      bram_wrdata_a(31 downto 0) => NLW_axi_bram_ctrl_0_bram_wrdata_a_UNCONNECTED(31 downto 0),
      s_axi_aclk => clk_wiz_0_clk_out1,
      s_axi_araddr(14 downto 0) => smartconnect_0_M00_AXI_ARADDR(14 downto 0),
      s_axi_arburst(1 downto 0) => smartconnect_0_M00_AXI_ARBURST(1 downto 0),
      s_axi_arcache(3 downto 0) => smartconnect_0_M00_AXI_ARCACHE(3 downto 0),
      s_axi_aresetn => proc_sys_reset_0_peripheral_aresetn(0),
      s_axi_arlen(7 downto 0) => smartconnect_0_M00_AXI_ARLEN(7 downto 0),
      s_axi_arlock => smartconnect_0_M00_AXI_ARLOCK(0),
      s_axi_arprot(2 downto 0) => smartconnect_0_M00_AXI_ARPROT(2 downto 0),
      s_axi_arready => smartconnect_0_M00_AXI_ARREADY,
      s_axi_arsize(2 downto 0) => smartconnect_0_M00_AXI_ARSIZE(2 downto 0),
      s_axi_arvalid => smartconnect_0_M00_AXI_ARVALID,
      s_axi_awaddr(14 downto 0) => smartconnect_0_M00_AXI_AWADDR(14 downto 0),
      s_axi_awburst(1 downto 0) => smartconnect_0_M00_AXI_AWBURST(1 downto 0),
      s_axi_awcache(3 downto 0) => smartconnect_0_M00_AXI_AWCACHE(3 downto 0),
      s_axi_awlen(7 downto 0) => smartconnect_0_M00_AXI_AWLEN(7 downto 0),
      s_axi_awlock => smartconnect_0_M00_AXI_AWLOCK(0),
      s_axi_awprot(2 downto 0) => smartconnect_0_M00_AXI_AWPROT(2 downto 0),
      s_axi_awready => smartconnect_0_M00_AXI_AWREADY,
      s_axi_awsize(2 downto 0) => smartconnect_0_M00_AXI_AWSIZE(2 downto 0),
      s_axi_awvalid => smartconnect_0_M00_AXI_AWVALID,
      s_axi_bready => smartconnect_0_M00_AXI_BREADY,
      s_axi_bresp(1 downto 0) => smartconnect_0_M00_AXI_BRESP(1 downto 0),
      s_axi_bvalid => smartconnect_0_M00_AXI_BVALID,
      s_axi_rdata(31 downto 0) => smartconnect_0_M00_AXI_RDATA(31 downto 0),
      s_axi_rlast => smartconnect_0_M00_AXI_RLAST,
      s_axi_rready => smartconnect_0_M00_AXI_RREADY,
      s_axi_rresp(1 downto 0) => smartconnect_0_M00_AXI_RRESP(1 downto 0),
      s_axi_rvalid => smartconnect_0_M00_AXI_RVALID,
      s_axi_wdata(31 downto 0) => smartconnect_0_M00_AXI_WDATA(31 downto 0),
      s_axi_wlast => smartconnect_0_M00_AXI_WLAST,
      s_axi_wready => smartconnect_0_M00_AXI_WREADY,
      s_axi_wstrb(3 downto 0) => smartconnect_0_M00_AXI_WSTRB(3 downto 0),
      s_axi_wvalid => smartconnect_0_M00_AXI_WVALID
    );
axi_bram_ctrl_0_bram: component RISC_V_block_axi_bram_ctrl_0_bram_0
     port map (
      addra(31 downto 15) => B"00000000000000000",
      addra(14 downto 0) => axi_bram_ctrl_0_BRAM_PORTA_ADDR(14 downto 0),
      clka => axi_bram_ctrl_0_BRAM_PORTA_CLK,
      douta(31 downto 0) => axi_bram_ctrl_0_BRAM_PORTA_DOUT(31 downto 0),
      ena => axi_bram_ctrl_0_BRAM_PORTA_EN,
      rsta => axi_bram_ctrl_0_BRAM_PORTA_RST,
      rsta_busy => NLW_axi_bram_ctrl_0_bram_rsta_busy_UNCONNECTED
    );
axi_bram_ctrl_1: component RISC_V_block_axi_bram_ctrl_1_0
     port map (
      bram_addr_a(14 downto 0) => axi_bram_ctrl_1_BRAM_PORTA_ADDR(14 downto 0),
      bram_clk_a => axi_bram_ctrl_1_BRAM_PORTA_CLK,
      bram_en_a => axi_bram_ctrl_1_BRAM_PORTA_EN,
      bram_rddata_a(31 downto 0) => axi_bram_ctrl_1_BRAM_PORTA_DOUT(31 downto 0),
      bram_rst_a => axi_bram_ctrl_1_BRAM_PORTA_RST,
      bram_we_a(3 downto 0) => axi_bram_ctrl_1_BRAM_PORTA_WE(3 downto 0),
      bram_wrdata_a(31 downto 0) => axi_bram_ctrl_1_BRAM_PORTA_DIN(31 downto 0),
      s_axi_aclk => clk_wiz_0_clk_out1,
      s_axi_araddr(14 downto 0) => smartconnect_0_M01_AXI_ARADDR(14 downto 0),
      s_axi_arburst(1 downto 0) => smartconnect_0_M01_AXI_ARBURST(1 downto 0),
      s_axi_arcache(3 downto 0) => smartconnect_0_M01_AXI_ARCACHE(3 downto 0),
      s_axi_aresetn => proc_sys_reset_0_peripheral_aresetn(0),
      s_axi_arlen(7 downto 0) => smartconnect_0_M01_AXI_ARLEN(7 downto 0),
      s_axi_arlock => smartconnect_0_M01_AXI_ARLOCK(0),
      s_axi_arprot(2 downto 0) => smartconnect_0_M01_AXI_ARPROT(2 downto 0),
      s_axi_arready => smartconnect_0_M01_AXI_ARREADY,
      s_axi_arsize(2 downto 0) => smartconnect_0_M01_AXI_ARSIZE(2 downto 0),
      s_axi_arvalid => smartconnect_0_M01_AXI_ARVALID,
      s_axi_awaddr(14 downto 0) => smartconnect_0_M01_AXI_AWADDR(14 downto 0),
      s_axi_awburst(1 downto 0) => smartconnect_0_M01_AXI_AWBURST(1 downto 0),
      s_axi_awcache(3 downto 0) => smartconnect_0_M01_AXI_AWCACHE(3 downto 0),
      s_axi_awlen(7 downto 0) => smartconnect_0_M01_AXI_AWLEN(7 downto 0),
      s_axi_awlock => smartconnect_0_M01_AXI_AWLOCK(0),
      s_axi_awprot(2 downto 0) => smartconnect_0_M01_AXI_AWPROT(2 downto 0),
      s_axi_awready => smartconnect_0_M01_AXI_AWREADY,
      s_axi_awsize(2 downto 0) => smartconnect_0_M01_AXI_AWSIZE(2 downto 0),
      s_axi_awvalid => smartconnect_0_M01_AXI_AWVALID,
      s_axi_bready => smartconnect_0_M01_AXI_BREADY,
      s_axi_bresp(1 downto 0) => smartconnect_0_M01_AXI_BRESP(1 downto 0),
      s_axi_bvalid => smartconnect_0_M01_AXI_BVALID,
      s_axi_rdata(31 downto 0) => smartconnect_0_M01_AXI_RDATA(31 downto 0),
      s_axi_rlast => smartconnect_0_M01_AXI_RLAST,
      s_axi_rready => smartconnect_0_M01_AXI_RREADY,
      s_axi_rresp(1 downto 0) => smartconnect_0_M01_AXI_RRESP(1 downto 0),
      s_axi_rvalid => smartconnect_0_M01_AXI_RVALID,
      s_axi_wdata(31 downto 0) => smartconnect_0_M01_AXI_WDATA(31 downto 0),
      s_axi_wlast => smartconnect_0_M01_AXI_WLAST,
      s_axi_wready => smartconnect_0_M01_AXI_WREADY,
      s_axi_wstrb(3 downto 0) => smartconnect_0_M01_AXI_WSTRB(3 downto 0),
      s_axi_wvalid => smartconnect_0_M01_AXI_WVALID
    );
axi_bram_ctrl_1_bram: component RISC_V_block_axi_bram_ctrl_1_bram_0
     port map (
      addra(31 downto 15) => B"00000000000000000",
      addra(14 downto 0) => axi_bram_ctrl_1_BRAM_PORTA_ADDR(14 downto 0),
      clka => axi_bram_ctrl_1_BRAM_PORTA_CLK,
      dina(31 downto 0) => axi_bram_ctrl_1_BRAM_PORTA_DIN(31 downto 0),
      douta(31 downto 0) => axi_bram_ctrl_1_BRAM_PORTA_DOUT(31 downto 0),
      ena => axi_bram_ctrl_1_BRAM_PORTA_EN,
      rsta => axi_bram_ctrl_1_BRAM_PORTA_RST,
      rsta_busy => NLW_axi_bram_ctrl_1_bram_rsta_busy_UNCONNECTED,
      wea(3 downto 0) => axi_bram_ctrl_1_BRAM_PORTA_WE(3 downto 0)
    );
axi_gpio_0: component RISC_V_block_axi_gpio_0_0
     port map (
      gpio_io_i(15 downto 0) => dip_switches_16bits_tri_i(15 downto 0),
      s_axi_aclk => clk_wiz_0_clk_out1,
      s_axi_araddr(8 downto 0) => smartconnect_0_M02_AXI_ARADDR(8 downto 0),
      s_axi_aresetn => proc_sys_reset_0_peripheral_aresetn(0),
      s_axi_arready => smartconnect_0_M02_AXI_ARREADY,
      s_axi_arvalid => smartconnect_0_M02_AXI_ARVALID,
      s_axi_awaddr(8 downto 0) => smartconnect_0_M02_AXI_AWADDR(8 downto 0),
      s_axi_awready => smartconnect_0_M02_AXI_AWREADY,
      s_axi_awvalid => smartconnect_0_M02_AXI_AWVALID,
      s_axi_bready => smartconnect_0_M02_AXI_BREADY,
      s_axi_bresp(1 downto 0) => smartconnect_0_M02_AXI_BRESP(1 downto 0),
      s_axi_bvalid => smartconnect_0_M02_AXI_BVALID,
      s_axi_rdata(31 downto 0) => smartconnect_0_M02_AXI_RDATA(31 downto 0),
      s_axi_rready => smartconnect_0_M02_AXI_RREADY,
      s_axi_rresp(1 downto 0) => smartconnect_0_M02_AXI_RRESP(1 downto 0),
      s_axi_rvalid => smartconnect_0_M02_AXI_RVALID,
      s_axi_wdata(31 downto 0) => smartconnect_0_M02_AXI_WDATA(31 downto 0),
      s_axi_wready => smartconnect_0_M02_AXI_WREADY,
      s_axi_wstrb(3 downto 0) => smartconnect_0_M02_AXI_WSTRB(3 downto 0),
      s_axi_wvalid => smartconnect_0_M02_AXI_WVALID
    );
axi_gpio_1: component RISC_V_block_axi_gpio_1_0
     port map (
      gpio_io_o(15 downto 0) => led_16bits_tri_o(15 downto 0),
      s_axi_aclk => clk_wiz_0_clk_out1,
      s_axi_araddr(8 downto 0) => smartconnect_0_M03_AXI_ARADDR(8 downto 0),
      s_axi_aresetn => proc_sys_reset_0_peripheral_aresetn(0),
      s_axi_arready => smartconnect_0_M03_AXI_ARREADY,
      s_axi_arvalid => smartconnect_0_M03_AXI_ARVALID,
      s_axi_awaddr(8 downto 0) => smartconnect_0_M03_AXI_AWADDR(8 downto 0),
      s_axi_awready => smartconnect_0_M03_AXI_AWREADY,
      s_axi_awvalid => smartconnect_0_M03_AXI_AWVALID,
      s_axi_bready => smartconnect_0_M03_AXI_BREADY,
      s_axi_bresp(1 downto 0) => smartconnect_0_M03_AXI_BRESP(1 downto 0),
      s_axi_bvalid => smartconnect_0_M03_AXI_BVALID,
      s_axi_rdata(31 downto 0) => smartconnect_0_M03_AXI_RDATA(31 downto 0),
      s_axi_rready => smartconnect_0_M03_AXI_RREADY,
      s_axi_rresp(1 downto 0) => smartconnect_0_M03_AXI_RRESP(1 downto 0),
      s_axi_rvalid => smartconnect_0_M03_AXI_RVALID,
      s_axi_wdata(31 downto 0) => smartconnect_0_M03_AXI_WDATA(31 downto 0),
      s_axi_wready => smartconnect_0_M03_AXI_WREADY,
      s_axi_wstrb(3 downto 0) => smartconnect_0_M03_AXI_WSTRB(3 downto 0),
      s_axi_wvalid => smartconnect_0_M03_AXI_WVALID
    );
clk_wiz_0: component RISC_V_block_clk_wiz_0_0
     port map (
      clk_in1 => sys_clock,
      clk_out1 => clk_wiz_0_clk_out1,
      locked => clk_wiz_0_locked,
      resetn => resetn
    );
  ilconstant_0_dout <= B"1";
  ilconstant_1_dout <= B"0";
proc_sys_reset_0: component RISC_V_block_proc_sys_reset_0_0
     port map (
      aux_reset_in => ilconstant_0_dout(0),
      bus_struct_reset(0) => NLW_proc_sys_reset_0_bus_struct_reset_UNCONNECTED(0),
      dcm_locked => clk_wiz_0_locked,
      ext_reset_in => resetn,
      interconnect_aresetn(0) => NLW_proc_sys_reset_0_interconnect_aresetn_UNCONNECTED(0),
      mb_debug_sys_rst => ilconstant_1_dout(0),
      mb_reset => proc_sys_reset_0_mb_reset,
      peripheral_aresetn(0) => proc_sys_reset_0_peripheral_aresetn(0),
      peripheral_reset(0) => NLW_proc_sys_reset_0_peripheral_reset_UNCONNECTED(0),
      slowest_sync_clk => clk_wiz_0_clk_out1
    );
smartconnect_0: component RISC_V_block_smartconnect_0_0
     port map (
      M00_AXI_araddr(14 downto 0) => smartconnect_0_M00_AXI_ARADDR(14 downto 0),
      M00_AXI_arburst(1 downto 0) => smartconnect_0_M00_AXI_ARBURST(1 downto 0),
      M00_AXI_arcache(3 downto 0) => smartconnect_0_M00_AXI_ARCACHE(3 downto 0),
      M00_AXI_arlen(7 downto 0) => smartconnect_0_M00_AXI_ARLEN(7 downto 0),
      M00_AXI_arlock(0) => smartconnect_0_M00_AXI_ARLOCK(0),
      M00_AXI_arprot(2 downto 0) => smartconnect_0_M00_AXI_ARPROT(2 downto 0),
      M00_AXI_arqos(3 downto 0) => NLW_smartconnect_0_M00_AXI_arqos_UNCONNECTED(3 downto 0),
      M00_AXI_arready => smartconnect_0_M00_AXI_ARREADY,
      M00_AXI_arsize(2 downto 0) => smartconnect_0_M00_AXI_ARSIZE(2 downto 0),
      M00_AXI_arvalid => smartconnect_0_M00_AXI_ARVALID,
      M00_AXI_awaddr(14 downto 0) => smartconnect_0_M00_AXI_AWADDR(14 downto 0),
      M00_AXI_awburst(1 downto 0) => smartconnect_0_M00_AXI_AWBURST(1 downto 0),
      M00_AXI_awcache(3 downto 0) => smartconnect_0_M00_AXI_AWCACHE(3 downto 0),
      M00_AXI_awlen(7 downto 0) => smartconnect_0_M00_AXI_AWLEN(7 downto 0),
      M00_AXI_awlock(0) => smartconnect_0_M00_AXI_AWLOCK(0),
      M00_AXI_awprot(2 downto 0) => smartconnect_0_M00_AXI_AWPROT(2 downto 0),
      M00_AXI_awqos(3 downto 0) => NLW_smartconnect_0_M00_AXI_awqos_UNCONNECTED(3 downto 0),
      M00_AXI_awready => smartconnect_0_M00_AXI_AWREADY,
      M00_AXI_awsize(2 downto 0) => smartconnect_0_M00_AXI_AWSIZE(2 downto 0),
      M00_AXI_awvalid => smartconnect_0_M00_AXI_AWVALID,
      M00_AXI_bready => smartconnect_0_M00_AXI_BREADY,
      M00_AXI_bresp(1 downto 0) => smartconnect_0_M00_AXI_BRESP(1 downto 0),
      M00_AXI_bvalid => smartconnect_0_M00_AXI_BVALID,
      M00_AXI_rdata(31 downto 0) => smartconnect_0_M00_AXI_RDATA(31 downto 0),
      M00_AXI_rlast => smartconnect_0_M00_AXI_RLAST,
      M00_AXI_rready => smartconnect_0_M00_AXI_RREADY,
      M00_AXI_rresp(1 downto 0) => smartconnect_0_M00_AXI_RRESP(1 downto 0),
      M00_AXI_rvalid => smartconnect_0_M00_AXI_RVALID,
      M00_AXI_wdata(31 downto 0) => smartconnect_0_M00_AXI_WDATA(31 downto 0),
      M00_AXI_wlast => smartconnect_0_M00_AXI_WLAST,
      M00_AXI_wready => smartconnect_0_M00_AXI_WREADY,
      M00_AXI_wstrb(3 downto 0) => smartconnect_0_M00_AXI_WSTRB(3 downto 0),
      M00_AXI_wvalid => smartconnect_0_M00_AXI_WVALID,
      M01_AXI_araddr(14 downto 0) => smartconnect_0_M01_AXI_ARADDR(14 downto 0),
      M01_AXI_arburst(1 downto 0) => smartconnect_0_M01_AXI_ARBURST(1 downto 0),
      M01_AXI_arcache(3 downto 0) => smartconnect_0_M01_AXI_ARCACHE(3 downto 0),
      M01_AXI_arlen(7 downto 0) => smartconnect_0_M01_AXI_ARLEN(7 downto 0),
      M01_AXI_arlock(0) => smartconnect_0_M01_AXI_ARLOCK(0),
      M01_AXI_arprot(2 downto 0) => smartconnect_0_M01_AXI_ARPROT(2 downto 0),
      M01_AXI_arqos(3 downto 0) => NLW_smartconnect_0_M01_AXI_arqos_UNCONNECTED(3 downto 0),
      M01_AXI_arready => smartconnect_0_M01_AXI_ARREADY,
      M01_AXI_arsize(2 downto 0) => smartconnect_0_M01_AXI_ARSIZE(2 downto 0),
      M01_AXI_arvalid => smartconnect_0_M01_AXI_ARVALID,
      M01_AXI_awaddr(14 downto 0) => smartconnect_0_M01_AXI_AWADDR(14 downto 0),
      M01_AXI_awburst(1 downto 0) => smartconnect_0_M01_AXI_AWBURST(1 downto 0),
      M01_AXI_awcache(3 downto 0) => smartconnect_0_M01_AXI_AWCACHE(3 downto 0),
      M01_AXI_awlen(7 downto 0) => smartconnect_0_M01_AXI_AWLEN(7 downto 0),
      M01_AXI_awlock(0) => smartconnect_0_M01_AXI_AWLOCK(0),
      M01_AXI_awprot(2 downto 0) => smartconnect_0_M01_AXI_AWPROT(2 downto 0),
      M01_AXI_awqos(3 downto 0) => NLW_smartconnect_0_M01_AXI_awqos_UNCONNECTED(3 downto 0),
      M01_AXI_awready => smartconnect_0_M01_AXI_AWREADY,
      M01_AXI_awsize(2 downto 0) => smartconnect_0_M01_AXI_AWSIZE(2 downto 0),
      M01_AXI_awvalid => smartconnect_0_M01_AXI_AWVALID,
      M01_AXI_bready => smartconnect_0_M01_AXI_BREADY,
      M01_AXI_bresp(1 downto 0) => smartconnect_0_M01_AXI_BRESP(1 downto 0),
      M01_AXI_bvalid => smartconnect_0_M01_AXI_BVALID,
      M01_AXI_rdata(31 downto 0) => smartconnect_0_M01_AXI_RDATA(31 downto 0),
      M01_AXI_rlast => smartconnect_0_M01_AXI_RLAST,
      M01_AXI_rready => smartconnect_0_M01_AXI_RREADY,
      M01_AXI_rresp(1 downto 0) => smartconnect_0_M01_AXI_RRESP(1 downto 0),
      M01_AXI_rvalid => smartconnect_0_M01_AXI_RVALID,
      M01_AXI_wdata(31 downto 0) => smartconnect_0_M01_AXI_WDATA(31 downto 0),
      M01_AXI_wlast => smartconnect_0_M01_AXI_WLAST,
      M01_AXI_wready => smartconnect_0_M01_AXI_WREADY,
      M01_AXI_wstrb(3 downto 0) => smartconnect_0_M01_AXI_WSTRB(3 downto 0),
      M01_AXI_wvalid => smartconnect_0_M01_AXI_WVALID,
      M02_AXI_araddr(8 downto 0) => smartconnect_0_M02_AXI_ARADDR(8 downto 0),
      M02_AXI_arprot(2 downto 0) => NLW_smartconnect_0_M02_AXI_arprot_UNCONNECTED(2 downto 0),
      M02_AXI_arready => smartconnect_0_M02_AXI_ARREADY,
      M02_AXI_arvalid => smartconnect_0_M02_AXI_ARVALID,
      M02_AXI_awaddr(8 downto 0) => smartconnect_0_M02_AXI_AWADDR(8 downto 0),
      M02_AXI_awprot(2 downto 0) => NLW_smartconnect_0_M02_AXI_awprot_UNCONNECTED(2 downto 0),
      M02_AXI_awready => smartconnect_0_M02_AXI_AWREADY,
      M02_AXI_awvalid => smartconnect_0_M02_AXI_AWVALID,
      M02_AXI_bready => smartconnect_0_M02_AXI_BREADY,
      M02_AXI_bresp(1 downto 0) => smartconnect_0_M02_AXI_BRESP(1 downto 0),
      M02_AXI_bvalid => smartconnect_0_M02_AXI_BVALID,
      M02_AXI_rdata(31 downto 0) => smartconnect_0_M02_AXI_RDATA(31 downto 0),
      M02_AXI_rready => smartconnect_0_M02_AXI_RREADY,
      M02_AXI_rresp(1 downto 0) => smartconnect_0_M02_AXI_RRESP(1 downto 0),
      M02_AXI_rvalid => smartconnect_0_M02_AXI_RVALID,
      M02_AXI_wdata(31 downto 0) => smartconnect_0_M02_AXI_WDATA(31 downto 0),
      M02_AXI_wready => smartconnect_0_M02_AXI_WREADY,
      M02_AXI_wstrb(3 downto 0) => smartconnect_0_M02_AXI_WSTRB(3 downto 0),
      M02_AXI_wvalid => smartconnect_0_M02_AXI_WVALID,
      M03_AXI_araddr(8 downto 0) => smartconnect_0_M03_AXI_ARADDR(8 downto 0),
      M03_AXI_arprot(2 downto 0) => NLW_smartconnect_0_M03_AXI_arprot_UNCONNECTED(2 downto 0),
      M03_AXI_arready => smartconnect_0_M03_AXI_ARREADY,
      M03_AXI_arvalid => smartconnect_0_M03_AXI_ARVALID,
      M03_AXI_awaddr(8 downto 0) => smartconnect_0_M03_AXI_AWADDR(8 downto 0),
      M03_AXI_awprot(2 downto 0) => NLW_smartconnect_0_M03_AXI_awprot_UNCONNECTED(2 downto 0),
      M03_AXI_awready => smartconnect_0_M03_AXI_AWREADY,
      M03_AXI_awvalid => smartconnect_0_M03_AXI_AWVALID,
      M03_AXI_bready => smartconnect_0_M03_AXI_BREADY,
      M03_AXI_bresp(1 downto 0) => smartconnect_0_M03_AXI_BRESP(1 downto 0),
      M03_AXI_bvalid => smartconnect_0_M03_AXI_BVALID,
      M03_AXI_rdata(31 downto 0) => smartconnect_0_M03_AXI_RDATA(31 downto 0),
      M03_AXI_rready => smartconnect_0_M03_AXI_RREADY,
      M03_AXI_rresp(1 downto 0) => smartconnect_0_M03_AXI_RRESP(1 downto 0),
      M03_AXI_rvalid => smartconnect_0_M03_AXI_RVALID,
      M03_AXI_wdata(31 downto 0) => smartconnect_0_M03_AXI_WDATA(31 downto 0),
      M03_AXI_wready => smartconnect_0_M03_AXI_WREADY,
      M03_AXI_wstrb(3 downto 0) => smartconnect_0_M03_AXI_WSTRB(3 downto 0),
      M03_AXI_wvalid => smartconnect_0_M03_AXI_WVALID,
      S00_AXI_araddr(31 downto 0) => RISC_V_0_f_M_AXI_ARADDR(31 downto 0),
      S00_AXI_arburst(1 downto 0) => RISC_V_0_f_M_AXI_ARBURST(1 downto 0),
      S00_AXI_arcache(3 downto 0) => RISC_V_0_f_M_AXI_ARCACHE(3 downto 0),
      S00_AXI_arid(0) => RISC_V_0_f_M_AXI_ARID(0),
      S00_AXI_arlen(7 downto 0) => RISC_V_0_f_M_AXI_ARLEN(7 downto 0),
      S00_AXI_arlock(0) => RISC_V_0_f_M_AXI_ARLOCK,
      S00_AXI_arprot(2 downto 0) => RISC_V_0_f_M_AXI_ARPROT(2 downto 0),
      S00_AXI_arqos(3 downto 0) => RISC_V_0_f_M_AXI_ARQOS(3 downto 0),
      S00_AXI_arready => RISC_V_0_f_M_AXI_ARREADY,
      S00_AXI_arsize(2 downto 0) => RISC_V_0_f_M_AXI_ARSIZE(2 downto 0),
      S00_AXI_arvalid => RISC_V_0_f_M_AXI_ARVALID,
      S00_AXI_rdata(31 downto 0) => RISC_V_0_f_M_AXI_RDATA(31 downto 0),
      S00_AXI_rid(0) => RISC_V_0_f_M_AXI_RID(0),
      S00_AXI_rlast => RISC_V_0_f_M_AXI_RLAST,
      S00_AXI_rready => RISC_V_0_f_M_AXI_RREADY,
      S00_AXI_rresp(1 downto 0) => RISC_V_0_f_M_AXI_RRESP(1 downto 0),
      S00_AXI_rvalid => RISC_V_0_f_M_AXI_RVALID,
      S01_AXI_araddr(31 downto 0) => RISC_V_0_ls_M_AXI_ARADDR(31 downto 0),
      S01_AXI_arburst(1 downto 0) => RISC_V_0_ls_M_AXI_ARBURST(1 downto 0),
      S01_AXI_arcache(3 downto 0) => RISC_V_0_ls_M_AXI_ARCACHE(3 downto 0),
      S01_AXI_arid(0) => RISC_V_0_ls_M_AXI_ARID(0),
      S01_AXI_arlen(7 downto 0) => RISC_V_0_ls_M_AXI_ARLEN(7 downto 0),
      S01_AXI_arlock(0) => RISC_V_0_ls_M_AXI_ARLOCK,
      S01_AXI_arprot(2 downto 0) => RISC_V_0_ls_M_AXI_ARPROT(2 downto 0),
      S01_AXI_arqos(3 downto 0) => RISC_V_0_ls_M_AXI_ARQOS(3 downto 0),
      S01_AXI_arready => RISC_V_0_ls_M_AXI_ARREADY,
      S01_AXI_arsize(2 downto 0) => RISC_V_0_ls_M_AXI_ARSIZE(2 downto 0),
      S01_AXI_arvalid => RISC_V_0_ls_M_AXI_ARVALID,
      S01_AXI_awaddr(31 downto 0) => RISC_V_0_ls_M_AXI_AWADDR(31 downto 0),
      S01_AXI_awburst(1 downto 0) => RISC_V_0_ls_M_AXI_AWBURST(1 downto 0),
      S01_AXI_awcache(3 downto 0) => RISC_V_0_ls_M_AXI_AWCACHE(3 downto 0),
      S01_AXI_awid(0) => RISC_V_0_ls_M_AXI_AWID(0),
      S01_AXI_awlen(7 downto 0) => RISC_V_0_ls_M_AXI_AWLEN(7 downto 0),
      S01_AXI_awlock(0) => RISC_V_0_ls_M_AXI_AWLOCK,
      S01_AXI_awprot(2 downto 0) => RISC_V_0_ls_M_AXI_AWPROT(2 downto 0),
      S01_AXI_awqos(3 downto 0) => RISC_V_0_ls_M_AXI_AWQOS(3 downto 0),
      S01_AXI_awready => RISC_V_0_ls_M_AXI_AWREADY,
      S01_AXI_awsize(2 downto 0) => RISC_V_0_ls_M_AXI_AWSIZE(2 downto 0),
      S01_AXI_awvalid => RISC_V_0_ls_M_AXI_AWVALID,
      S01_AXI_bid(0) => RISC_V_0_ls_M_AXI_BID(0),
      S01_AXI_bready => RISC_V_0_ls_M_AXI_BREADY,
      S01_AXI_bresp(1 downto 0) => RISC_V_0_ls_M_AXI_BRESP(1 downto 0),
      S01_AXI_bvalid => RISC_V_0_ls_M_AXI_BVALID,
      S01_AXI_rdata(31 downto 0) => RISC_V_0_ls_M_AXI_RDATA(31 downto 0),
      S01_AXI_rid(0) => RISC_V_0_ls_M_AXI_RID(0),
      S01_AXI_rlast => RISC_V_0_ls_M_AXI_RLAST,
      S01_AXI_rready => RISC_V_0_ls_M_AXI_RREADY,
      S01_AXI_rresp(1 downto 0) => RISC_V_0_ls_M_AXI_RRESP(1 downto 0),
      S01_AXI_rvalid => RISC_V_0_ls_M_AXI_RVALID,
      S01_AXI_wdata(31 downto 0) => RISC_V_0_ls_M_AXI_WDATA(31 downto 0),
      S01_AXI_wlast => RISC_V_0_ls_M_AXI_WLAST,
      S01_AXI_wready => RISC_V_0_ls_M_AXI_WREADY,
      S01_AXI_wstrb(3 downto 0) => RISC_V_0_ls_M_AXI_WSTRB(3 downto 0),
      S01_AXI_wvalid => RISC_V_0_ls_M_AXI_WVALID,
      aclk => clk_wiz_0_clk_out1,
      aresetn => proc_sys_reset_0_peripheral_aresetn(0)
    );
end STRUCTURE;
