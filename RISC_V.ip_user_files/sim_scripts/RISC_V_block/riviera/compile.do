transcript off
onbreak {quit -force}
onerror {quit -force}
transcript on

vlib work
vlib riviera/xilinx_vip
vlib riviera/xil_defaultlib
vlib riviera/axi_bram_ctrl_v4_1_14
vlib riviera/blk_mem_gen_v8_4_13
vlib riviera/axi_lite_ipif_v3_1_0
vlib riviera/interrupt_control_v3_2_0
vlib riviera/axi_gpio_v2_0_38
vlib riviera/proc_sys_reset_v5_0_17
vlib riviera/smartconnect_v1_0
vlib riviera/axi_infrastructure_v1_1_0
vlib riviera/axi_register_slice_v2_1_37
vlib riviera/axi_vip_v1_1_23

vmap xilinx_vip riviera/xilinx_vip
vmap xil_defaultlib riviera/xil_defaultlib
vmap axi_bram_ctrl_v4_1_14 riviera/axi_bram_ctrl_v4_1_14
vmap blk_mem_gen_v8_4_13 riviera/blk_mem_gen_v8_4_13
vmap axi_lite_ipif_v3_1_0 riviera/axi_lite_ipif_v3_1_0
vmap interrupt_control_v3_2_0 riviera/interrupt_control_v3_2_0
vmap axi_gpio_v2_0_38 riviera/axi_gpio_v2_0_38
vmap proc_sys_reset_v5_0_17 riviera/proc_sys_reset_v5_0_17
vmap smartconnect_v1_0 riviera/smartconnect_v1_0
vmap axi_infrastructure_v1_1_0 riviera/axi_infrastructure_v1_1_0
vmap axi_register_slice_v2_1_37 riviera/axi_register_slice_v2_1_37
vmap axi_vip_v1_1_23 riviera/axi_vip_v1_1_23

vlog -work xilinx_vip  -incr "+incdir+C:/AMDDesignTools/2026.1/Vivado/data/xilinx_vip/include" -l xilinx_vip -l xil_defaultlib -l axi_bram_ctrl_v4_1_14 -l blk_mem_gen_v8_4_13 -l axi_lite_ipif_v3_1_0 -l interrupt_control_v3_2_0 -l axi_gpio_v2_0_38 -l proc_sys_reset_v5_0_17 -l smartconnect_v1_0 -l axi_infrastructure_v1_1_0 -l axi_register_slice_v2_1_37 -l axi_vip_v1_1_23 \
"C:/AMDDesignTools/2026.1/Vivado/data/xilinx_vip/hdl/axi4stream_vip_axi4streampc.sv" \
"C:/AMDDesignTools/2026.1/Vivado/data/xilinx_vip/hdl/axi_vip_axi4pc.sv" \
"C:/AMDDesignTools/2026.1/Vivado/data/xilinx_vip/hdl/xil_common_vip_pkg.sv" \
"C:/AMDDesignTools/2026.1/Vivado/data/xilinx_vip/hdl/axi4stream_vip_pkg.sv" \
"C:/AMDDesignTools/2026.1/Vivado/data/xilinx_vip/hdl/axi_vip_pkg.sv" \
"C:/AMDDesignTools/2026.1/Vivado/data/xilinx_vip/hdl/axi4stream_vip_if.sv" \
"C:/AMDDesignTools/2026.1/Vivado/data/xilinx_vip/hdl/axi_vip_if.sv" \
"C:/AMDDesignTools/2026.1/Vivado/data/xilinx_vip/hdl/clk_vip_if.sv" \
"C:/AMDDesignTools/2026.1/Vivado/data/xilinx_vip/hdl/rst_vip_if.sv" \

vcom -work xil_defaultlib -93  -incr \
"../../../bd/RISC_V_block/ip/RISC_V_block_RISC_V_0_0/sim/RISC_V_block_RISC_V_0_0.vhd" \

vcom -work axi_bram_ctrl_v4_1_14 -93  -incr \
"../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/02d4/hdl/axi_bram_ctrl_v4_1_rfs.vhd" \

vcom -work xil_defaultlib -93  -incr \
"../../../bd/RISC_V_block/ip/RISC_V_block_axi_bram_ctrl_0_0/sim/RISC_V_block_axi_bram_ctrl_0_0.vhd" \

vlog -work blk_mem_gen_v8_4_13  -incr -v2k5 "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/ee6d" "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/f0b6/hdl/verilog" "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/00fe/hdl/verilog" "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/ec67/hdl" "+incdir+../../../../../../AMDDesignTools/2026.1/Vivado/data/rsb/busdef" "+incdir+C:/AMDDesignTools/2026.1/Vivado/data/xilinx_vip/include" -l xilinx_vip -l xil_defaultlib -l axi_bram_ctrl_v4_1_14 -l blk_mem_gen_v8_4_13 -l axi_lite_ipif_v3_1_0 -l interrupt_control_v3_2_0 -l axi_gpio_v2_0_38 -l proc_sys_reset_v5_0_17 -l smartconnect_v1_0 -l axi_infrastructure_v1_1_0 -l axi_register_slice_v2_1_37 -l axi_vip_v1_1_23 \
"../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/59f9/simulation/blk_mem_gen_v8_4.v" \

vlog -work xil_defaultlib  -incr -v2k5 "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/ee6d" "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/f0b6/hdl/verilog" "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/00fe/hdl/verilog" "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/ec67/hdl" "+incdir+../../../../../../AMDDesignTools/2026.1/Vivado/data/rsb/busdef" "+incdir+C:/AMDDesignTools/2026.1/Vivado/data/xilinx_vip/include" -l xilinx_vip -l xil_defaultlib -l axi_bram_ctrl_v4_1_14 -l blk_mem_gen_v8_4_13 -l axi_lite_ipif_v3_1_0 -l interrupt_control_v3_2_0 -l axi_gpio_v2_0_38 -l proc_sys_reset_v5_0_17 -l smartconnect_v1_0 -l axi_infrastructure_v1_1_0 -l axi_register_slice_v2_1_37 -l axi_vip_v1_1_23 \
"../../../bd/RISC_V_block/ip/RISC_V_block_axi_bram_ctrl_0_bram_0/sim/RISC_V_block_axi_bram_ctrl_0_bram_0.v" \

vcom -work xil_defaultlib -93  -incr \
"../../../bd/RISC_V_block/ip/RISC_V_block_axi_bram_ctrl_1_0/sim/RISC_V_block_axi_bram_ctrl_1_0.vhd" \

vlog -work xil_defaultlib  -incr -v2k5 "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/ee6d" "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/f0b6/hdl/verilog" "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/00fe/hdl/verilog" "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/ec67/hdl" "+incdir+../../../../../../AMDDesignTools/2026.1/Vivado/data/rsb/busdef" "+incdir+C:/AMDDesignTools/2026.1/Vivado/data/xilinx_vip/include" -l xilinx_vip -l xil_defaultlib -l axi_bram_ctrl_v4_1_14 -l blk_mem_gen_v8_4_13 -l axi_lite_ipif_v3_1_0 -l interrupt_control_v3_2_0 -l axi_gpio_v2_0_38 -l proc_sys_reset_v5_0_17 -l smartconnect_v1_0 -l axi_infrastructure_v1_1_0 -l axi_register_slice_v2_1_37 -l axi_vip_v1_1_23 \
"../../../bd/RISC_V_block/ip/RISC_V_block_axi_bram_ctrl_1_bram_0/sim/RISC_V_block_axi_bram_ctrl_1_bram_0.v" \

vcom -work axi_lite_ipif_v3_1_0 -93  -incr \
"../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/de33/hdl/axi_lite_ipif_v3_1_rfs.vhd" \

vcom -work interrupt_control_v3_2_0 -93  -incr \
"../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/e2ca/hdl/interrupt_control_v3_2_rfs.vhd" \

vcom -work axi_gpio_v2_0_38 -93  -incr \
"../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/6ccd/hdl/axi_gpio_v2_0_rfs.vhd" \

vcom -work xil_defaultlib -93  -incr \
"../../../bd/RISC_V_block/ip/RISC_V_block_axi_gpio_0_0/sim/RISC_V_block_axi_gpio_0_0.vhd" \
"../../../bd/RISC_V_block/ip/RISC_V_block_axi_gpio_1_0/sim/RISC_V_block_axi_gpio_1_0.vhd" \

vlog -work xil_defaultlib  -incr -v2k5 "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/ee6d" "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/f0b6/hdl/verilog" "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/00fe/hdl/verilog" "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/ec67/hdl" "+incdir+../../../../../../AMDDesignTools/2026.1/Vivado/data/rsb/busdef" "+incdir+C:/AMDDesignTools/2026.1/Vivado/data/xilinx_vip/include" -l xilinx_vip -l xil_defaultlib -l axi_bram_ctrl_v4_1_14 -l blk_mem_gen_v8_4_13 -l axi_lite_ipif_v3_1_0 -l interrupt_control_v3_2_0 -l axi_gpio_v2_0_38 -l proc_sys_reset_v5_0_17 -l smartconnect_v1_0 -l axi_infrastructure_v1_1_0 -l axi_register_slice_v2_1_37 -l axi_vip_v1_1_23 \
"../../../bd/RISC_V_block/ip/RISC_V_block_clk_wiz_0_0/RISC_V_block_clk_wiz_0_0_clk_wiz.v" \
"../../../bd/RISC_V_block/ip/RISC_V_block_clk_wiz_0_0/RISC_V_block_clk_wiz_0_0.v" \

vcom -work proc_sys_reset_v5_0_17 -93  -incr \
"../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/9438/hdl/proc_sys_reset_v5_0_rfs.vhd" \

vcom -work xil_defaultlib -93  -incr \
"../../../bd/RISC_V_block/ip/RISC_V_block_proc_sys_reset_0_0/sim/RISC_V_block_proc_sys_reset_0_0.vhd" \
"../../../bd/RISC_V_block/sim/RISC_V_block.vhd" \
"../../../bd/RISC_V_block/ip/RISC_V_block_smartconnect_0_0/bd_0/ip/ip_1/sim/bd_7a1f_psr_aclk_0.vhd" \

vlog -work smartconnect_v1_0  -incr "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/ee6d" "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/f0b6/hdl/verilog" "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/00fe/hdl/verilog" "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/ec67/hdl" "+incdir+../../../../../../AMDDesignTools/2026.1/Vivado/data/rsb/busdef" "+incdir+C:/AMDDesignTools/2026.1/Vivado/data/xilinx_vip/include" -l xilinx_vip -l xil_defaultlib -l axi_bram_ctrl_v4_1_14 -l blk_mem_gen_v8_4_13 -l axi_lite_ipif_v3_1_0 -l interrupt_control_v3_2_0 -l axi_gpio_v2_0_38 -l proc_sys_reset_v5_0_17 -l smartconnect_v1_0 -l axi_infrastructure_v1_1_0 -l axi_register_slice_v2_1_37 -l axi_vip_v1_1_23 \
"../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/f0b6/hdl/sc_util_v1_0_vl_rfs.sv" \
"../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/0848/hdl/sc_switchboard_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib  -incr "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/ee6d" "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/f0b6/hdl/verilog" "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/00fe/hdl/verilog" "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/ec67/hdl" "+incdir+../../../../../../AMDDesignTools/2026.1/Vivado/data/rsb/busdef" "+incdir+C:/AMDDesignTools/2026.1/Vivado/data/xilinx_vip/include" -l xilinx_vip -l xil_defaultlib -l axi_bram_ctrl_v4_1_14 -l blk_mem_gen_v8_4_13 -l axi_lite_ipif_v3_1_0 -l interrupt_control_v3_2_0 -l axi_gpio_v2_0_38 -l proc_sys_reset_v5_0_17 -l smartconnect_v1_0 -l axi_infrastructure_v1_1_0 -l axi_register_slice_v2_1_37 -l axi_vip_v1_1_23 \
"../../../bd/RISC_V_block/ip/RISC_V_block_smartconnect_0_0/bd_0/ip/ip_2/sim/bd_7a1f_arsw_0.sv" \
"../../../bd/RISC_V_block/ip/RISC_V_block_smartconnect_0_0/bd_0/ip/ip_3/sim/bd_7a1f_rsw_0.sv" \
"../../../bd/RISC_V_block/ip/RISC_V_block_smartconnect_0_0/bd_0/ip/ip_4/sim/bd_7a1f_awsw_0.sv" \
"../../../bd/RISC_V_block/ip/RISC_V_block_smartconnect_0_0/bd_0/ip/ip_5/sim/bd_7a1f_wsw_0.sv" \
"../../../bd/RISC_V_block/ip/RISC_V_block_smartconnect_0_0/bd_0/ip/ip_6/sim/bd_7a1f_bsw_0.sv" \

vlog -work smartconnect_v1_0  -incr "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/ee6d" "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/f0b6/hdl/verilog" "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/00fe/hdl/verilog" "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/ec67/hdl" "+incdir+../../../../../../AMDDesignTools/2026.1/Vivado/data/rsb/busdef" "+incdir+C:/AMDDesignTools/2026.1/Vivado/data/xilinx_vip/include" -l xilinx_vip -l xil_defaultlib -l axi_bram_ctrl_v4_1_14 -l blk_mem_gen_v8_4_13 -l axi_lite_ipif_v3_1_0 -l interrupt_control_v3_2_0 -l axi_gpio_v2_0_38 -l proc_sys_reset_v5_0_17 -l smartconnect_v1_0 -l axi_infrastructure_v1_1_0 -l axi_register_slice_v2_1_37 -l axi_vip_v1_1_23 \
"../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/3d9a/hdl/sc_mmu_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib  -incr "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/ee6d" "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/f0b6/hdl/verilog" "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/00fe/hdl/verilog" "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/ec67/hdl" "+incdir+../../../../../../AMDDesignTools/2026.1/Vivado/data/rsb/busdef" "+incdir+C:/AMDDesignTools/2026.1/Vivado/data/xilinx_vip/include" -l xilinx_vip -l xil_defaultlib -l axi_bram_ctrl_v4_1_14 -l blk_mem_gen_v8_4_13 -l axi_lite_ipif_v3_1_0 -l interrupt_control_v3_2_0 -l axi_gpio_v2_0_38 -l proc_sys_reset_v5_0_17 -l smartconnect_v1_0 -l axi_infrastructure_v1_1_0 -l axi_register_slice_v2_1_37 -l axi_vip_v1_1_23 \
"../../../bd/RISC_V_block/ip/RISC_V_block_smartconnect_0_0/bd_0/ip/ip_7/sim/bd_7a1f_s00mmu_0.sv" \

vlog -work smartconnect_v1_0  -incr "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/ee6d" "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/f0b6/hdl/verilog" "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/00fe/hdl/verilog" "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/ec67/hdl" "+incdir+../../../../../../AMDDesignTools/2026.1/Vivado/data/rsb/busdef" "+incdir+C:/AMDDesignTools/2026.1/Vivado/data/xilinx_vip/include" -l xilinx_vip -l xil_defaultlib -l axi_bram_ctrl_v4_1_14 -l blk_mem_gen_v8_4_13 -l axi_lite_ipif_v3_1_0 -l interrupt_control_v3_2_0 -l axi_gpio_v2_0_38 -l proc_sys_reset_v5_0_17 -l smartconnect_v1_0 -l axi_infrastructure_v1_1_0 -l axi_register_slice_v2_1_37 -l axi_vip_v1_1_23 \
"../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/7785/hdl/sc_transaction_regulator_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib  -incr "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/ee6d" "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/f0b6/hdl/verilog" "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/00fe/hdl/verilog" "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/ec67/hdl" "+incdir+../../../../../../AMDDesignTools/2026.1/Vivado/data/rsb/busdef" "+incdir+C:/AMDDesignTools/2026.1/Vivado/data/xilinx_vip/include" -l xilinx_vip -l xil_defaultlib -l axi_bram_ctrl_v4_1_14 -l blk_mem_gen_v8_4_13 -l axi_lite_ipif_v3_1_0 -l interrupt_control_v3_2_0 -l axi_gpio_v2_0_38 -l proc_sys_reset_v5_0_17 -l smartconnect_v1_0 -l axi_infrastructure_v1_1_0 -l axi_register_slice_v2_1_37 -l axi_vip_v1_1_23 \
"../../../bd/RISC_V_block/ip/RISC_V_block_smartconnect_0_0/bd_0/ip/ip_8/sim/bd_7a1f_s00tr_0.sv" \

vlog -work smartconnect_v1_0  -incr "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/ee6d" "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/f0b6/hdl/verilog" "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/00fe/hdl/verilog" "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/ec67/hdl" "+incdir+../../../../../../AMDDesignTools/2026.1/Vivado/data/rsb/busdef" "+incdir+C:/AMDDesignTools/2026.1/Vivado/data/xilinx_vip/include" -l xilinx_vip -l xil_defaultlib -l axi_bram_ctrl_v4_1_14 -l blk_mem_gen_v8_4_13 -l axi_lite_ipif_v3_1_0 -l interrupt_control_v3_2_0 -l axi_gpio_v2_0_38 -l proc_sys_reset_v5_0_17 -l smartconnect_v1_0 -l axi_infrastructure_v1_1_0 -l axi_register_slice_v2_1_37 -l axi_vip_v1_1_23 \
"../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/3051/hdl/sc_si_converter_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib  -incr "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/ee6d" "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/f0b6/hdl/verilog" "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/00fe/hdl/verilog" "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/ec67/hdl" "+incdir+../../../../../../AMDDesignTools/2026.1/Vivado/data/rsb/busdef" "+incdir+C:/AMDDesignTools/2026.1/Vivado/data/xilinx_vip/include" -l xilinx_vip -l xil_defaultlib -l axi_bram_ctrl_v4_1_14 -l blk_mem_gen_v8_4_13 -l axi_lite_ipif_v3_1_0 -l interrupt_control_v3_2_0 -l axi_gpio_v2_0_38 -l proc_sys_reset_v5_0_17 -l smartconnect_v1_0 -l axi_infrastructure_v1_1_0 -l axi_register_slice_v2_1_37 -l axi_vip_v1_1_23 \
"../../../bd/RISC_V_block/ip/RISC_V_block_smartconnect_0_0/bd_0/ip/ip_9/sim/bd_7a1f_s00sic_0.sv" \

vlog -work smartconnect_v1_0  -incr "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/ee6d" "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/f0b6/hdl/verilog" "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/00fe/hdl/verilog" "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/ec67/hdl" "+incdir+../../../../../../AMDDesignTools/2026.1/Vivado/data/rsb/busdef" "+incdir+C:/AMDDesignTools/2026.1/Vivado/data/xilinx_vip/include" -l xilinx_vip -l xil_defaultlib -l axi_bram_ctrl_v4_1_14 -l blk_mem_gen_v8_4_13 -l axi_lite_ipif_v3_1_0 -l interrupt_control_v3_2_0 -l axi_gpio_v2_0_38 -l proc_sys_reset_v5_0_17 -l smartconnect_v1_0 -l axi_infrastructure_v1_1_0 -l axi_register_slice_v2_1_37 -l axi_vip_v1_1_23 \
"../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/852f/hdl/sc_axi2sc_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib  -incr "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/ee6d" "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/f0b6/hdl/verilog" "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/00fe/hdl/verilog" "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/ec67/hdl" "+incdir+../../../../../../AMDDesignTools/2026.1/Vivado/data/rsb/busdef" "+incdir+C:/AMDDesignTools/2026.1/Vivado/data/xilinx_vip/include" -l xilinx_vip -l xil_defaultlib -l axi_bram_ctrl_v4_1_14 -l blk_mem_gen_v8_4_13 -l axi_lite_ipif_v3_1_0 -l interrupt_control_v3_2_0 -l axi_gpio_v2_0_38 -l proc_sys_reset_v5_0_17 -l smartconnect_v1_0 -l axi_infrastructure_v1_1_0 -l axi_register_slice_v2_1_37 -l axi_vip_v1_1_23 \
"../../../bd/RISC_V_block/ip/RISC_V_block_smartconnect_0_0/bd_0/ip/ip_10/sim/bd_7a1f_s00a2s_0.sv" \

vlog -work smartconnect_v1_0  -incr "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/ee6d" "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/f0b6/hdl/verilog" "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/00fe/hdl/verilog" "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/ec67/hdl" "+incdir+../../../../../../AMDDesignTools/2026.1/Vivado/data/rsb/busdef" "+incdir+C:/AMDDesignTools/2026.1/Vivado/data/xilinx_vip/include" -l xilinx_vip -l xil_defaultlib -l axi_bram_ctrl_v4_1_14 -l blk_mem_gen_v8_4_13 -l axi_lite_ipif_v3_1_0 -l interrupt_control_v3_2_0 -l axi_gpio_v2_0_38 -l proc_sys_reset_v5_0_17 -l smartconnect_v1_0 -l axi_infrastructure_v1_1_0 -l axi_register_slice_v2_1_37 -l axi_vip_v1_1_23 \
"../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/00fe/hdl/sc_node_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib  -incr "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/ee6d" "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/f0b6/hdl/verilog" "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/00fe/hdl/verilog" "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/ec67/hdl" "+incdir+../../../../../../AMDDesignTools/2026.1/Vivado/data/rsb/busdef" "+incdir+C:/AMDDesignTools/2026.1/Vivado/data/xilinx_vip/include" -l xilinx_vip -l xil_defaultlib -l axi_bram_ctrl_v4_1_14 -l blk_mem_gen_v8_4_13 -l axi_lite_ipif_v3_1_0 -l interrupt_control_v3_2_0 -l axi_gpio_v2_0_38 -l proc_sys_reset_v5_0_17 -l smartconnect_v1_0 -l axi_infrastructure_v1_1_0 -l axi_register_slice_v2_1_37 -l axi_vip_v1_1_23 \
"../../../bd/RISC_V_block/ip/RISC_V_block_smartconnect_0_0/bd_0/ip/ip_11/sim/bd_7a1f_sarn_0.sv" \
"../../../bd/RISC_V_block/ip/RISC_V_block_smartconnect_0_0/bd_0/ip/ip_12/sim/bd_7a1f_srn_0.sv" \
"../../../bd/RISC_V_block/ip/RISC_V_block_smartconnect_0_0/bd_0/ip/ip_13/sim/bd_7a1f_s01mmu_0.sv" \
"../../../bd/RISC_V_block/ip/RISC_V_block_smartconnect_0_0/bd_0/ip/ip_14/sim/bd_7a1f_s01tr_0.sv" \
"../../../bd/RISC_V_block/ip/RISC_V_block_smartconnect_0_0/bd_0/ip/ip_15/sim/bd_7a1f_s01sic_0.sv" \
"../../../bd/RISC_V_block/ip/RISC_V_block_smartconnect_0_0/bd_0/ip/ip_16/sim/bd_7a1f_s01a2s_0.sv" \
"../../../bd/RISC_V_block/ip/RISC_V_block_smartconnect_0_0/bd_0/ip/ip_17/sim/bd_7a1f_sarn_1.sv" \
"../../../bd/RISC_V_block/ip/RISC_V_block_smartconnect_0_0/bd_0/ip/ip_18/sim/bd_7a1f_srn_1.sv" \
"../../../bd/RISC_V_block/ip/RISC_V_block_smartconnect_0_0/bd_0/ip/ip_19/sim/bd_7a1f_sawn_0.sv" \
"../../../bd/RISC_V_block/ip/RISC_V_block_smartconnect_0_0/bd_0/ip/ip_20/sim/bd_7a1f_swn_0.sv" \
"../../../bd/RISC_V_block/ip/RISC_V_block_smartconnect_0_0/bd_0/ip/ip_21/sim/bd_7a1f_sbn_0.sv" \

vlog -work smartconnect_v1_0  -incr "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/ee6d" "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/f0b6/hdl/verilog" "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/00fe/hdl/verilog" "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/ec67/hdl" "+incdir+../../../../../../AMDDesignTools/2026.1/Vivado/data/rsb/busdef" "+incdir+C:/AMDDesignTools/2026.1/Vivado/data/xilinx_vip/include" -l xilinx_vip -l xil_defaultlib -l axi_bram_ctrl_v4_1_14 -l blk_mem_gen_v8_4_13 -l axi_lite_ipif_v3_1_0 -l interrupt_control_v3_2_0 -l axi_gpio_v2_0_38 -l proc_sys_reset_v5_0_17 -l smartconnect_v1_0 -l axi_infrastructure_v1_1_0 -l axi_register_slice_v2_1_37 -l axi_vip_v1_1_23 \
"../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/fca9/hdl/sc_sc2axi_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib  -incr "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/ee6d" "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/f0b6/hdl/verilog" "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/00fe/hdl/verilog" "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/ec67/hdl" "+incdir+../../../../../../AMDDesignTools/2026.1/Vivado/data/rsb/busdef" "+incdir+C:/AMDDesignTools/2026.1/Vivado/data/xilinx_vip/include" -l xilinx_vip -l xil_defaultlib -l axi_bram_ctrl_v4_1_14 -l blk_mem_gen_v8_4_13 -l axi_lite_ipif_v3_1_0 -l interrupt_control_v3_2_0 -l axi_gpio_v2_0_38 -l proc_sys_reset_v5_0_17 -l smartconnect_v1_0 -l axi_infrastructure_v1_1_0 -l axi_register_slice_v2_1_37 -l axi_vip_v1_1_23 \
"../../../bd/RISC_V_block/ip/RISC_V_block_smartconnect_0_0/bd_0/ip/ip_22/sim/bd_7a1f_m00s2a_0.sv" \
"../../../bd/RISC_V_block/ip/RISC_V_block_smartconnect_0_0/bd_0/ip/ip_23/sim/bd_7a1f_m00arn_0.sv" \
"../../../bd/RISC_V_block/ip/RISC_V_block_smartconnect_0_0/bd_0/ip/ip_24/sim/bd_7a1f_m00rn_0.sv" \
"../../../bd/RISC_V_block/ip/RISC_V_block_smartconnect_0_0/bd_0/ip/ip_25/sim/bd_7a1f_m00awn_0.sv" \
"../../../bd/RISC_V_block/ip/RISC_V_block_smartconnect_0_0/bd_0/ip/ip_26/sim/bd_7a1f_m00wn_0.sv" \
"../../../bd/RISC_V_block/ip/RISC_V_block_smartconnect_0_0/bd_0/ip/ip_27/sim/bd_7a1f_m00bn_0.sv" \

vlog -work smartconnect_v1_0  -incr "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/ee6d" "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/f0b6/hdl/verilog" "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/00fe/hdl/verilog" "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/ec67/hdl" "+incdir+../../../../../../AMDDesignTools/2026.1/Vivado/data/rsb/busdef" "+incdir+C:/AMDDesignTools/2026.1/Vivado/data/xilinx_vip/include" -l xilinx_vip -l xil_defaultlib -l axi_bram_ctrl_v4_1_14 -l blk_mem_gen_v8_4_13 -l axi_lite_ipif_v3_1_0 -l interrupt_control_v3_2_0 -l axi_gpio_v2_0_38 -l proc_sys_reset_v5_0_17 -l smartconnect_v1_0 -l axi_infrastructure_v1_1_0 -l axi_register_slice_v2_1_37 -l axi_vip_v1_1_23 \
"../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/c7d2/hdl/sc_exit_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib  -incr "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/ee6d" "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/f0b6/hdl/verilog" "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/00fe/hdl/verilog" "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/ec67/hdl" "+incdir+../../../../../../AMDDesignTools/2026.1/Vivado/data/rsb/busdef" "+incdir+C:/AMDDesignTools/2026.1/Vivado/data/xilinx_vip/include" -l xilinx_vip -l xil_defaultlib -l axi_bram_ctrl_v4_1_14 -l blk_mem_gen_v8_4_13 -l axi_lite_ipif_v3_1_0 -l interrupt_control_v3_2_0 -l axi_gpio_v2_0_38 -l proc_sys_reset_v5_0_17 -l smartconnect_v1_0 -l axi_infrastructure_v1_1_0 -l axi_register_slice_v2_1_37 -l axi_vip_v1_1_23 \
"../../../bd/RISC_V_block/ip/RISC_V_block_smartconnect_0_0/bd_0/ip/ip_28/sim/bd_7a1f_m00e_0.sv" \
"../../../bd/RISC_V_block/ip/RISC_V_block_smartconnect_0_0/bd_0/ip/ip_29/sim/bd_7a1f_m01s2a_0.sv" \
"../../../bd/RISC_V_block/ip/RISC_V_block_smartconnect_0_0/bd_0/ip/ip_30/sim/bd_7a1f_m01arn_0.sv" \
"../../../bd/RISC_V_block/ip/RISC_V_block_smartconnect_0_0/bd_0/ip/ip_31/sim/bd_7a1f_m01rn_0.sv" \
"../../../bd/RISC_V_block/ip/RISC_V_block_smartconnect_0_0/bd_0/ip/ip_32/sim/bd_7a1f_m01awn_0.sv" \
"../../../bd/RISC_V_block/ip/RISC_V_block_smartconnect_0_0/bd_0/ip/ip_33/sim/bd_7a1f_m01wn_0.sv" \
"../../../bd/RISC_V_block/ip/RISC_V_block_smartconnect_0_0/bd_0/ip/ip_34/sim/bd_7a1f_m01bn_0.sv" \
"../../../bd/RISC_V_block/ip/RISC_V_block_smartconnect_0_0/bd_0/ip/ip_35/sim/bd_7a1f_m01e_0.sv" \
"../../../bd/RISC_V_block/ip/RISC_V_block_smartconnect_0_0/bd_0/ip/ip_36/sim/bd_7a1f_m02s2a_0.sv" \
"../../../bd/RISC_V_block/ip/RISC_V_block_smartconnect_0_0/bd_0/ip/ip_37/sim/bd_7a1f_m02arn_0.sv" \
"../../../bd/RISC_V_block/ip/RISC_V_block_smartconnect_0_0/bd_0/ip/ip_38/sim/bd_7a1f_m02rn_0.sv" \
"../../../bd/RISC_V_block/ip/RISC_V_block_smartconnect_0_0/bd_0/ip/ip_39/sim/bd_7a1f_m02awn_0.sv" \
"../../../bd/RISC_V_block/ip/RISC_V_block_smartconnect_0_0/bd_0/ip/ip_40/sim/bd_7a1f_m02wn_0.sv" \
"../../../bd/RISC_V_block/ip/RISC_V_block_smartconnect_0_0/bd_0/ip/ip_41/sim/bd_7a1f_m02bn_0.sv" \
"../../../bd/RISC_V_block/ip/RISC_V_block_smartconnect_0_0/bd_0/ip/ip_42/sim/bd_7a1f_m02e_0.sv" \
"../../../bd/RISC_V_block/ip/RISC_V_block_smartconnect_0_0/bd_0/ip/ip_43/sim/bd_7a1f_m03s2a_0.sv" \
"../../../bd/RISC_V_block/ip/RISC_V_block_smartconnect_0_0/bd_0/ip/ip_44/sim/bd_7a1f_m03arn_0.sv" \
"../../../bd/RISC_V_block/ip/RISC_V_block_smartconnect_0_0/bd_0/ip/ip_45/sim/bd_7a1f_m03rn_0.sv" \
"../../../bd/RISC_V_block/ip/RISC_V_block_smartconnect_0_0/bd_0/ip/ip_46/sim/bd_7a1f_m03awn_0.sv" \
"../../../bd/RISC_V_block/ip/RISC_V_block_smartconnect_0_0/bd_0/ip/ip_47/sim/bd_7a1f_m03wn_0.sv" \
"../../../bd/RISC_V_block/ip/RISC_V_block_smartconnect_0_0/bd_0/ip/ip_48/sim/bd_7a1f_m03bn_0.sv" \
"../../../bd/RISC_V_block/ip/RISC_V_block_smartconnect_0_0/bd_0/ip/ip_49/sim/bd_7a1f_m03e_0.sv" \

vlog -work xil_defaultlib  -incr -v2k5 "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/ee6d" "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/f0b6/hdl/verilog" "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/00fe/hdl/verilog" "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/ec67/hdl" "+incdir+../../../../../../AMDDesignTools/2026.1/Vivado/data/rsb/busdef" "+incdir+C:/AMDDesignTools/2026.1/Vivado/data/xilinx_vip/include" -l xilinx_vip -l xil_defaultlib -l axi_bram_ctrl_v4_1_14 -l blk_mem_gen_v8_4_13 -l axi_lite_ipif_v3_1_0 -l interrupt_control_v3_2_0 -l axi_gpio_v2_0_38 -l proc_sys_reset_v5_0_17 -l smartconnect_v1_0 -l axi_infrastructure_v1_1_0 -l axi_register_slice_v2_1_37 -l axi_vip_v1_1_23 \
"../../../bd/RISC_V_block/ip/RISC_V_block_smartconnect_0_0/bd_0/sim/bd_7a1f.v" \

vcom -work smartconnect_v1_0 -93  -incr \
"../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/21d5/hdl/sc_ultralite_v1_0_rfs.vhd" \

vlog -work smartconnect_v1_0  -incr "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/ee6d" "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/f0b6/hdl/verilog" "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/00fe/hdl/verilog" "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/ec67/hdl" "+incdir+../../../../../../AMDDesignTools/2026.1/Vivado/data/rsb/busdef" "+incdir+C:/AMDDesignTools/2026.1/Vivado/data/xilinx_vip/include" -l xilinx_vip -l xil_defaultlib -l axi_bram_ctrl_v4_1_14 -l blk_mem_gen_v8_4_13 -l axi_lite_ipif_v3_1_0 -l interrupt_control_v3_2_0 -l axi_gpio_v2_0_38 -l proc_sys_reset_v5_0_17 -l smartconnect_v1_0 -l axi_infrastructure_v1_1_0 -l axi_register_slice_v2_1_37 -l axi_vip_v1_1_23 \
"../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/21d5/hdl/sc_ultralite_v1_0_rfs.sv" \

vlog -work axi_infrastructure_v1_1_0  -incr -v2k5 "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/ee6d" "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/f0b6/hdl/verilog" "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/00fe/hdl/verilog" "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/ec67/hdl" "+incdir+../../../../../../AMDDesignTools/2026.1/Vivado/data/rsb/busdef" "+incdir+C:/AMDDesignTools/2026.1/Vivado/data/xilinx_vip/include" -l xilinx_vip -l xil_defaultlib -l axi_bram_ctrl_v4_1_14 -l blk_mem_gen_v8_4_13 -l axi_lite_ipif_v3_1_0 -l interrupt_control_v3_2_0 -l axi_gpio_v2_0_38 -l proc_sys_reset_v5_0_17 -l smartconnect_v1_0 -l axi_infrastructure_v1_1_0 -l axi_register_slice_v2_1_37 -l axi_vip_v1_1_23 \
"../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/ec67/hdl/axi_infrastructure_v1_1_vl_rfs.v" \

vlog -work axi_register_slice_v2_1_37  -incr -v2k5 "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/ee6d" "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/f0b6/hdl/verilog" "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/00fe/hdl/verilog" "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/ec67/hdl" "+incdir+../../../../../../AMDDesignTools/2026.1/Vivado/data/rsb/busdef" "+incdir+C:/AMDDesignTools/2026.1/Vivado/data/xilinx_vip/include" -l xilinx_vip -l xil_defaultlib -l axi_bram_ctrl_v4_1_14 -l blk_mem_gen_v8_4_13 -l axi_lite_ipif_v3_1_0 -l interrupt_control_v3_2_0 -l axi_gpio_v2_0_38 -l proc_sys_reset_v5_0_17 -l smartconnect_v1_0 -l axi_infrastructure_v1_1_0 -l axi_register_slice_v2_1_37 -l axi_vip_v1_1_23 \
"../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/8c55/hdl/axi_register_slice_v2_1_rfs.v" \

vlog -work axi_vip_v1_1_23  -incr "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/ee6d" "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/f0b6/hdl/verilog" "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/00fe/hdl/verilog" "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/ec67/hdl" "+incdir+../../../../../../AMDDesignTools/2026.1/Vivado/data/rsb/busdef" "+incdir+C:/AMDDesignTools/2026.1/Vivado/data/xilinx_vip/include" -l xilinx_vip -l xil_defaultlib -l axi_bram_ctrl_v4_1_14 -l blk_mem_gen_v8_4_13 -l axi_lite_ipif_v3_1_0 -l interrupt_control_v3_2_0 -l axi_gpio_v2_0_38 -l proc_sys_reset_v5_0_17 -l smartconnect_v1_0 -l axi_infrastructure_v1_1_0 -l axi_register_slice_v2_1_37 -l axi_vip_v1_1_23 \
"../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/4d28/hdl/axi_vip_v1_1_vl_rfs.sv" \

vlog -work xil_defaultlib  -incr "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/ee6d" "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/f0b6/hdl/verilog" "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/00fe/hdl/verilog" "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/ec67/hdl" "+incdir+../../../../../../AMDDesignTools/2026.1/Vivado/data/rsb/busdef" "+incdir+C:/AMDDesignTools/2026.1/Vivado/data/xilinx_vip/include" -l xilinx_vip -l xil_defaultlib -l axi_bram_ctrl_v4_1_14 -l blk_mem_gen_v8_4_13 -l axi_lite_ipif_v3_1_0 -l interrupt_control_v3_2_0 -l axi_gpio_v2_0_38 -l proc_sys_reset_v5_0_17 -l smartconnect_v1_0 -l axi_infrastructure_v1_1_0 -l axi_register_slice_v2_1_37 -l axi_vip_v1_1_23 \
"../../../bd/RISC_V_block/ip/RISC_V_block_smartconnect_0_0/sim/RISC_V_block_smartconnect_0_0.sv" \

vlog -work xil_defaultlib \
"glbl.v"

