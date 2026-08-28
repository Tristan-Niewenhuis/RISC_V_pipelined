transcript off
onbreak {quit -force}
onerror {quit -force}
transcript on

vlib work
vlib activehdl/xil_defaultlib
vlib activehdl/axi_bram_ctrl_v4_1_14
vlib activehdl/blk_mem_gen_v8_4_13
vlib activehdl/axi_lite_ipif_v3_1_0
vlib activehdl/interrupt_control_v3_2_0
vlib activehdl/axi_gpio_v2_0_38
vlib activehdl/generic_baseblocks_v2_1_2
vlib activehdl/axi_infrastructure_v1_1_0
vlib activehdl/axi_register_slice_v2_1_37
vlib activehdl/fifo_generator_v13_2_15
vlib activehdl/axi_data_fifo_v2_1_37
vlib activehdl/axi_crossbar_v2_1_39
vlib activehdl/proc_sys_reset_v5_0_17
vlib activehdl/axi_protocol_converter_v2_1_38

vmap xil_defaultlib activehdl/xil_defaultlib
vmap axi_bram_ctrl_v4_1_14 activehdl/axi_bram_ctrl_v4_1_14
vmap blk_mem_gen_v8_4_13 activehdl/blk_mem_gen_v8_4_13
vmap axi_lite_ipif_v3_1_0 activehdl/axi_lite_ipif_v3_1_0
vmap interrupt_control_v3_2_0 activehdl/interrupt_control_v3_2_0
vmap axi_gpio_v2_0_38 activehdl/axi_gpio_v2_0_38
vmap generic_baseblocks_v2_1_2 activehdl/generic_baseblocks_v2_1_2
vmap axi_infrastructure_v1_1_0 activehdl/axi_infrastructure_v1_1_0
vmap axi_register_slice_v2_1_37 activehdl/axi_register_slice_v2_1_37
vmap fifo_generator_v13_2_15 activehdl/fifo_generator_v13_2_15
vmap axi_data_fifo_v2_1_37 activehdl/axi_data_fifo_v2_1_37
vmap axi_crossbar_v2_1_39 activehdl/axi_crossbar_v2_1_39
vmap proc_sys_reset_v5_0_17 activehdl/proc_sys_reset_v5_0_17
vmap axi_protocol_converter_v2_1_38 activehdl/axi_protocol_converter_v2_1_38

vcom -work xil_defaultlib -93  \
"../../../bd/RISC_V_block/ip/RISC_V_block_RISC_V_0_0/sim/RISC_V_block_RISC_V_0_0.vhd" \

vcom -work axi_bram_ctrl_v4_1_14 -93  \
"../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/02d4/hdl/axi_bram_ctrl_v4_1_rfs.vhd" \

vcom -work xil_defaultlib -93  \
"../../../bd/RISC_V_block/ip/RISC_V_block_axi_bram_ctrl_0_0/sim/RISC_V_block_axi_bram_ctrl_0_0.vhd" \

vlog -work blk_mem_gen_v8_4_13  -v2k5 "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/ec67/hdl" "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/ee6d" "+incdir+../../../../../../AMDDesignTools/2026.1/Vivado/data/rsb/busdef" -l xil_defaultlib -l axi_bram_ctrl_v4_1_14 -l blk_mem_gen_v8_4_13 -l axi_lite_ipif_v3_1_0 -l interrupt_control_v3_2_0 -l axi_gpio_v2_0_38 -l generic_baseblocks_v2_1_2 -l axi_infrastructure_v1_1_0 -l axi_register_slice_v2_1_37 -l fifo_generator_v13_2_15 -l axi_data_fifo_v2_1_37 -l axi_crossbar_v2_1_39 -l proc_sys_reset_v5_0_17 -l axi_protocol_converter_v2_1_38 \
"../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/59f9/simulation/blk_mem_gen_v8_4.v" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/ec67/hdl" "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/ee6d" "+incdir+../../../../../../AMDDesignTools/2026.1/Vivado/data/rsb/busdef" -l xil_defaultlib -l axi_bram_ctrl_v4_1_14 -l blk_mem_gen_v8_4_13 -l axi_lite_ipif_v3_1_0 -l interrupt_control_v3_2_0 -l axi_gpio_v2_0_38 -l generic_baseblocks_v2_1_2 -l axi_infrastructure_v1_1_0 -l axi_register_slice_v2_1_37 -l fifo_generator_v13_2_15 -l axi_data_fifo_v2_1_37 -l axi_crossbar_v2_1_39 -l proc_sys_reset_v5_0_17 -l axi_protocol_converter_v2_1_38 \
"../../../bd/RISC_V_block/ip/RISC_V_block_axi_bram_ctrl_0_bram_0/sim/RISC_V_block_axi_bram_ctrl_0_bram_0.v" \

vcom -work xil_defaultlib -93  \
"../../../bd/RISC_V_block/ip/RISC_V_block_axi_bram_ctrl_1_0/sim/RISC_V_block_axi_bram_ctrl_1_0.vhd" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/ec67/hdl" "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/ee6d" "+incdir+../../../../../../AMDDesignTools/2026.1/Vivado/data/rsb/busdef" -l xil_defaultlib -l axi_bram_ctrl_v4_1_14 -l blk_mem_gen_v8_4_13 -l axi_lite_ipif_v3_1_0 -l interrupt_control_v3_2_0 -l axi_gpio_v2_0_38 -l generic_baseblocks_v2_1_2 -l axi_infrastructure_v1_1_0 -l axi_register_slice_v2_1_37 -l fifo_generator_v13_2_15 -l axi_data_fifo_v2_1_37 -l axi_crossbar_v2_1_39 -l proc_sys_reset_v5_0_17 -l axi_protocol_converter_v2_1_38 \
"../../../bd/RISC_V_block/ip/RISC_V_block_axi_bram_ctrl_1_bram_0/sim/RISC_V_block_axi_bram_ctrl_1_bram_0.v" \

vcom -work axi_lite_ipif_v3_1_0 -93  \
"../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/de33/hdl/axi_lite_ipif_v3_1_rfs.vhd" \

vcom -work interrupt_control_v3_2_0 -93  \
"../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/e2ca/hdl/interrupt_control_v3_2_rfs.vhd" \

vcom -work axi_gpio_v2_0_38 -93  \
"../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/6ccd/hdl/axi_gpio_v2_0_rfs.vhd" \

vcom -work xil_defaultlib -93  \
"../../../bd/RISC_V_block/ip/RISC_V_block_axi_gpio_0_0/sim/RISC_V_block_axi_gpio_0_0.vhd" \
"../../../bd/RISC_V_block/ip/RISC_V_block_axi_gpio_1_0/sim/RISC_V_block_axi_gpio_1_0.vhd" \

vlog -work generic_baseblocks_v2_1_2  -v2k5 "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/ec67/hdl" "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/ee6d" "+incdir+../../../../../../AMDDesignTools/2026.1/Vivado/data/rsb/busdef" -l xil_defaultlib -l axi_bram_ctrl_v4_1_14 -l blk_mem_gen_v8_4_13 -l axi_lite_ipif_v3_1_0 -l interrupt_control_v3_2_0 -l axi_gpio_v2_0_38 -l generic_baseblocks_v2_1_2 -l axi_infrastructure_v1_1_0 -l axi_register_slice_v2_1_37 -l fifo_generator_v13_2_15 -l axi_data_fifo_v2_1_37 -l axi_crossbar_v2_1_39 -l proc_sys_reset_v5_0_17 -l axi_protocol_converter_v2_1_38 \
"../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/0c28/hdl/generic_baseblocks_v2_1_rfs.v" \

vlog -work axi_infrastructure_v1_1_0  -v2k5 "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/ec67/hdl" "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/ee6d" "+incdir+../../../../../../AMDDesignTools/2026.1/Vivado/data/rsb/busdef" -l xil_defaultlib -l axi_bram_ctrl_v4_1_14 -l blk_mem_gen_v8_4_13 -l axi_lite_ipif_v3_1_0 -l interrupt_control_v3_2_0 -l axi_gpio_v2_0_38 -l generic_baseblocks_v2_1_2 -l axi_infrastructure_v1_1_0 -l axi_register_slice_v2_1_37 -l fifo_generator_v13_2_15 -l axi_data_fifo_v2_1_37 -l axi_crossbar_v2_1_39 -l proc_sys_reset_v5_0_17 -l axi_protocol_converter_v2_1_38 \
"../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/ec67/hdl/axi_infrastructure_v1_1_vl_rfs.v" \

vlog -work axi_register_slice_v2_1_37  -v2k5 "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/ec67/hdl" "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/ee6d" "+incdir+../../../../../../AMDDesignTools/2026.1/Vivado/data/rsb/busdef" -l xil_defaultlib -l axi_bram_ctrl_v4_1_14 -l blk_mem_gen_v8_4_13 -l axi_lite_ipif_v3_1_0 -l interrupt_control_v3_2_0 -l axi_gpio_v2_0_38 -l generic_baseblocks_v2_1_2 -l axi_infrastructure_v1_1_0 -l axi_register_slice_v2_1_37 -l fifo_generator_v13_2_15 -l axi_data_fifo_v2_1_37 -l axi_crossbar_v2_1_39 -l proc_sys_reset_v5_0_17 -l axi_protocol_converter_v2_1_38 \
"../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/8c55/hdl/axi_register_slice_v2_1_rfs.v" \

vlog -work fifo_generator_v13_2_15  -v2k5 "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/ec67/hdl" "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/ee6d" "+incdir+../../../../../../AMDDesignTools/2026.1/Vivado/data/rsb/busdef" -l xil_defaultlib -l axi_bram_ctrl_v4_1_14 -l blk_mem_gen_v8_4_13 -l axi_lite_ipif_v3_1_0 -l interrupt_control_v3_2_0 -l axi_gpio_v2_0_38 -l generic_baseblocks_v2_1_2 -l axi_infrastructure_v1_1_0 -l axi_register_slice_v2_1_37 -l fifo_generator_v13_2_15 -l axi_data_fifo_v2_1_37 -l axi_crossbar_v2_1_39 -l proc_sys_reset_v5_0_17 -l axi_protocol_converter_v2_1_38 \
"../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/084a/simulation/fifo_generator_vlog_beh.v" \

vcom -work fifo_generator_v13_2_15 -93  \
"../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/084a/hdl/fifo_generator_v13_2_vh_sim_rfs.vhd" \

vlog -work fifo_generator_v13_2_15  -v2k5 "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/ec67/hdl" "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/ee6d" "+incdir+../../../../../../AMDDesignTools/2026.1/Vivado/data/rsb/busdef" -l xil_defaultlib -l axi_bram_ctrl_v4_1_14 -l blk_mem_gen_v8_4_13 -l axi_lite_ipif_v3_1_0 -l interrupt_control_v3_2_0 -l axi_gpio_v2_0_38 -l generic_baseblocks_v2_1_2 -l axi_infrastructure_v1_1_0 -l axi_register_slice_v2_1_37 -l fifo_generator_v13_2_15 -l axi_data_fifo_v2_1_37 -l axi_crossbar_v2_1_39 -l proc_sys_reset_v5_0_17 -l axi_protocol_converter_v2_1_38 \
"../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/084a/hdl/fifo_generator_v13_2_vl_sim_rfs.v" \

vlog -work axi_data_fifo_v2_1_37  -v2k5 "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/ec67/hdl" "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/ee6d" "+incdir+../../../../../../AMDDesignTools/2026.1/Vivado/data/rsb/busdef" -l xil_defaultlib -l axi_bram_ctrl_v4_1_14 -l blk_mem_gen_v8_4_13 -l axi_lite_ipif_v3_1_0 -l interrupt_control_v3_2_0 -l axi_gpio_v2_0_38 -l generic_baseblocks_v2_1_2 -l axi_infrastructure_v1_1_0 -l axi_register_slice_v2_1_37 -l fifo_generator_v13_2_15 -l axi_data_fifo_v2_1_37 -l axi_crossbar_v2_1_39 -l proc_sys_reset_v5_0_17 -l axi_protocol_converter_v2_1_38 \
"../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/a62a/hdl/axi_data_fifo_v2_1_vl_rfs.v" \

vlog -work axi_crossbar_v2_1_39  -v2k5 "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/ec67/hdl" "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/ee6d" "+incdir+../../../../../../AMDDesignTools/2026.1/Vivado/data/rsb/busdef" -l xil_defaultlib -l axi_bram_ctrl_v4_1_14 -l blk_mem_gen_v8_4_13 -l axi_lite_ipif_v3_1_0 -l interrupt_control_v3_2_0 -l axi_gpio_v2_0_38 -l generic_baseblocks_v2_1_2 -l axi_infrastructure_v1_1_0 -l axi_register_slice_v2_1_37 -l fifo_generator_v13_2_15 -l axi_data_fifo_v2_1_37 -l axi_crossbar_v2_1_39 -l proc_sys_reset_v5_0_17 -l axi_protocol_converter_v2_1_38 \
"../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/eea9/hdl/axi_crossbar_v2_1_vl_rfs.v" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/ec67/hdl" "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/ee6d" "+incdir+../../../../../../AMDDesignTools/2026.1/Vivado/data/rsb/busdef" -l xil_defaultlib -l axi_bram_ctrl_v4_1_14 -l blk_mem_gen_v8_4_13 -l axi_lite_ipif_v3_1_0 -l interrupt_control_v3_2_0 -l axi_gpio_v2_0_38 -l generic_baseblocks_v2_1_2 -l axi_infrastructure_v1_1_0 -l axi_register_slice_v2_1_37 -l fifo_generator_v13_2_15 -l axi_data_fifo_v2_1_37 -l axi_crossbar_v2_1_39 -l proc_sys_reset_v5_0_17 -l axi_protocol_converter_v2_1_38 \
"../../../bd/RISC_V_block/ip/RISC_V_block_axi_interconnect_0_imp_xbar_0/sim/RISC_V_block_axi_interconnect_0_imp_xbar_0.v" \
"../../../bd/RISC_V_block/ip/RISC_V_block_clk_wiz_0_0/RISC_V_block_clk_wiz_0_0_clk_wiz.v" \
"../../../bd/RISC_V_block/ip/RISC_V_block_clk_wiz_0_0/RISC_V_block_clk_wiz_0_0.v" \

vcom -work proc_sys_reset_v5_0_17 -93  \
"../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/9438/hdl/proc_sys_reset_v5_0_rfs.vhd" \

vcom -work xil_defaultlib -93  \
"../../../bd/RISC_V_block/ip/RISC_V_block_proc_sys_reset_0_0/sim/RISC_V_block_proc_sys_reset_0_0.vhd" \
"../../../bd/RISC_V_block/sim/RISC_V_block.vhd" \

vlog -work axi_protocol_converter_v2_1_38  -v2k5 "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/ec67/hdl" "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/ee6d" "+incdir+../../../../../../AMDDesignTools/2026.1/Vivado/data/rsb/busdef" -l xil_defaultlib -l axi_bram_ctrl_v4_1_14 -l blk_mem_gen_v8_4_13 -l axi_lite_ipif_v3_1_0 -l interrupt_control_v3_2_0 -l axi_gpio_v2_0_38 -l generic_baseblocks_v2_1_2 -l axi_infrastructure_v1_1_0 -l axi_register_slice_v2_1_37 -l fifo_generator_v13_2_15 -l axi_data_fifo_v2_1_37 -l axi_crossbar_v2_1_39 -l proc_sys_reset_v5_0_17 -l axi_protocol_converter_v2_1_38 \
"../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/b706/hdl/axi_protocol_converter_v2_1_vl_rfs.v" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/ec67/hdl" "+incdir+../../../../RISC_V.gen/sources_1/bd/RISC_V_block/ipshared/ee6d" "+incdir+../../../../../../AMDDesignTools/2026.1/Vivado/data/rsb/busdef" -l xil_defaultlib -l axi_bram_ctrl_v4_1_14 -l blk_mem_gen_v8_4_13 -l axi_lite_ipif_v3_1_0 -l interrupt_control_v3_2_0 -l axi_gpio_v2_0_38 -l generic_baseblocks_v2_1_2 -l axi_infrastructure_v1_1_0 -l axi_register_slice_v2_1_37 -l fifo_generator_v13_2_15 -l axi_data_fifo_v2_1_37 -l axi_crossbar_v2_1_39 -l proc_sys_reset_v5_0_17 -l axi_protocol_converter_v2_1_38 \
"../../../bd/RISC_V_block/ip/RISC_V_block_axi_interconnect_0_imp_auto_pc_0/sim/RISC_V_block_axi_interconnect_0_imp_auto_pc_0.v" \
"../../../bd/RISC_V_block/ip/RISC_V_block_axi_interconnect_0_imp_auto_pc_1/sim/RISC_V_block_axi_interconnect_0_imp_auto_pc_1.v" \

vlog -work xil_defaultlib \
"glbl.v"

