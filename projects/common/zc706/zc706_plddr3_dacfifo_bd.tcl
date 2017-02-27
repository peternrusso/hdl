
# pl ddr3 (use only when dma is not capable of keeping up).
# generic fifo interface - existence is oblivious to software.

create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 axi_rstgen
create_bd_cell -type ip -vlnv xilinx.com:ip:mig_7series:4.0 axi_ddr_cntrl

file copy -force $ad_hdl_dir/projects/common/zc706/zc706_plddr3_mig.prj [get_property IP_DIR \
  [get_ips [get_property CONFIG.Component_Name [get_bd_cells axi_ddr_cntrl]]]]
set_property CONFIG.XML_INPUT_FILE {zc706_plddr3_mig.prj} [get_bd_cells axi_ddr_cntrl]

create_bd_port -dir I -type rst sys_rst
set_property CONFIG.POLARITY ACTIVE_HIGH [get_bd_ports sys_rst]

create_bd_intf_port -mode Master -vlnv xilinx.com:interface:ddrx_rtl:1.0 ddr3
create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 sys_clk

ad_connect  sys_rst axi_ddr_cntrl/sys_rst
ad_connect  sys_clk axi_ddr_cntrl/SYS_CLK
ad_connect  ddr3 axi_ddr_cntrl/DDR3

create_bd_cell -type ip -vlnv analog.com:user:axi_dacfifo:1.0 $dac_fifo_name
set_property CONFIG.DAC_DATA_WIDTH $dac_data_width [get_bd_cells $dac_fifo_name]
set_property CONFIG.DMA_DATA_WIDTH $dac_dma_data_width [get_bd_cells $dac_fifo_name]
set_property CONFIG.AXI_DATA_WIDTH {512} [get_bd_cells $dac_fifo_name]
set_property CONFIG.AXI_SIZE {6} [get_bd_cells $dac_fifo_name]
set_property CONFIG.AXI_LENGTH {15} [get_bd_cells $dac_fifo_name]
set_property CONFIG.AXI_ADDRESS {0x80000000} [get_bd_cells $dac_fifo_name]
set_property CONFIG.AXI_ADDRESS_LIMIT {0xa0000000} [get_bd_cells $dac_fifo_name]

ad_connect  axi_ddr_cntrl/S_AXI $dac_fifo_name/axi
ad_connect  axi_ddr_cntrl/ui_clk $dac_fifo_name/axi_clk
ad_connect  axi_ddr_cntrl/ui_clk axi_rstgen/slowest_sync_clk
ad_connect  sys_cpu_resetn axi_rstgen/ext_reset_in
ad_connect  axi_rstgen/peripheral_aresetn $dac_fifo_name/axi_resetn
ad_connect  axi_rstgen/peripheral_aresetn axi_ddr_cntrl/aresetn
ad_connect  axi_ddr_cntrl/device_temp_i GND

assign_bd_address [get_bd_addr_segs -of_objects [get_bd_cells axi_ddr_cntrl]]
