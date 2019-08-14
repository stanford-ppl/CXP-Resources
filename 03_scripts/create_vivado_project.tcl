# --------------------------------------------------------------------------------
# -- CustomLogic - Create Vivado Project
# --------------------------------------------------------------------------------
# -- Procedures : customLogicCreateProject
# --        File: create_vivado_project.tcl
# --        Date: 2018-10-19
# --         Rev: 0.1
# --      Author: PP
# --------------------------------------------------------------------------------
# -- 0.1, 2018-10-19, PP, Initial release
# --------------------------------------------------------------------------------

proc customLogicCreateProject {} {
	puts  " "
	puts  "EURESYS_INFO: Creating the CustomLogic Vivado project..."
	puts  " "

	# Set the reference directory for source file relative paths (by default the value is script directory path)
	set origin_dir [file dirname [file normalize [info script]]]

	# Set Project name
	set projectName CustomLogic

	# Create project
	create_project $projectName $origin_dir/../07_vivado_project/ -part xcku035-fbva676-2-e

	# Deactivate automatic order
	set_property source_mgmt_mode DisplayOnly [current_project]

	# Activate XPM_LIBRARIES
	set_property XPM_LIBRARIES {XPM_CDC XPM_MEMORY XPM_FIFO} [current_project]

	# Create 'sources_1' fileset (if not found)
	if {[string equal [get_filesets -quiet sources_1] ""]} {
		create_fileset -srcset sources_1
	}

	# Set 'sources_1' fileset object
	set obj [get_filesets sources_1]
	set files [list \
		"[file normalize "$origin_dir/../02_coaxlink/hdl_enc/CustomLogicPkt.vp"]"\
		"[file normalize "$origin_dir/../02_coaxlink/hdl_enc/DmaBackEndPkt.vp"]"\
		"[file normalize "$origin_dir/../02_coaxlink/hdl_enc/CustomLogicPkt.vhdp"]"\
		"[file normalize "$origin_dir/../02_coaxlink/netlist/axi_dwidth_clk_converter_S128_M512.dcp"]"\
		"[file normalize "$origin_dir/../02_coaxlink/netlist/axi_dwidth_clk_converter_S256_M512.dcp"]"\
		"[file normalize "$origin_dir/../02_coaxlink/netlist/axi_interconnect_3xS512_M512.dcp"]"\
		"[file normalize "$origin_dir/../02_coaxlink/netlist/axi_lite_clock_converter.dcp"]"\
		"[file normalize "$origin_dir/../02_coaxlink/netlist/axis_data_fifo_256b.dcp"]"\
		"[file normalize "$origin_dir/../02_coaxlink/netlist/clk_wiz_cxp12.dcp"]"\
		"[file normalize "$origin_dir/../02_coaxlink/netlist/CounterDsp.dcp"]"\
		"[file normalize "$origin_dir/../02_coaxlink/netlist/EventSignalingBram.dcp"]"\
		"[file normalize "$origin_dir/../02_coaxlink/netlist/EventSignalingFifo_ku.dcp"]"\
		"[file normalize "$origin_dir/../02_coaxlink/netlist/fifo_async_148bx512.dcp"]"\
		"[file normalize "$origin_dir/../02_coaxlink/netlist/fifo_memento.dcp"]"\
		"[file normalize "$origin_dir/../02_coaxlink/netlist/FrameSizeDwDsp.dcp"]"\
		"[file normalize "$origin_dir/../02_coaxlink/netlist/gth_cxp_low_cxp12.dcp"]"\
		"[file normalize "$origin_dir/../02_coaxlink/netlist/LUT12x8.dcp"]"\
		"[file normalize "$origin_dir/../02_coaxlink/netlist/MultiplierDsp.dcp"]"\
		"[file normalize "$origin_dir/../02_coaxlink/netlist/PEGBram.dcp"]"\
		"[file normalize "$origin_dir/../02_coaxlink/netlist/PEGFifo_ku.dcp"]"\
		"[file normalize "$origin_dir/../02_coaxlink/netlist/PIXO_FIFO_259x1024.dcp"]"\
		"[file normalize "$origin_dir/../02_coaxlink/netlist/reg2mem_rddwc.dcp"]"\
		"[file normalize "$origin_dir/../02_coaxlink/netlist/reg2mem_rdfifo.dcp"]"\
		"[file normalize "$origin_dir/../02_coaxlink/netlist/reg2mem_wrdwc.dcp"]"\
		"[file normalize "$origin_dir/../02_coaxlink/netlist/reg2mem_wrfifo.dcp"]"\
		"[file normalize "$origin_dir/../02_coaxlink/netlist/sout_fifo_wr128_rd256.dcp"]"\
		"[file normalize "$origin_dir/../02_coaxlink/netlist/WrAxiAddrFifo.dcp"]"\
		"[file normalize "$origin_dir/../02_coaxlink/netlist/ExtIOConfigBram.dcp"]"\
		"[file normalize "$origin_dir/../02_coaxlink/ip/PoCXP_uBlaze/PoCXP_uBlaze.elf"]"\
		"[file normalize "$origin_dir/../04_ref_design/CustomLogicPkg.vhd"]"\
		"[file normalize "$origin_dir/../04_ref_design/frame_to_line.vhd"]"\
		"[file normalize "$origin_dir/../04_ref_design/mem_traffic_gen.vhd"]"\
		"[file normalize "$origin_dir/../04_ref_design/control_registers.vhd"]"\
		"[file normalize "$origin_dir/../04_ref_design/pix_lut8b.vhd"]"\
		"[file normalize "$origin_dir/../04_ref_design/pix_threshold.vhd"]"\
		"[file normalize "$origin_dir/../04_ref_design/pix_threshold_wrp.vhd"]"\
		"[file normalize "$origin_dir/../04_ref_design/CustomLogic.vhd"]"\
		"[file normalize "$origin_dir/../04_ref_design/CustomLogicTop.vhd"]"\
	]
	add_files -norecurse -fileset $obj $files

	# Set 'sources_1' fileset properties
	set obj [get_filesets sources_1]
	set_property "top" "CustomLogicTop" $obj

	# Create 'constrs_1' fileset (if not found)
	if {[string equal [get_filesets -quiet constrs_1] ""]} {
		create_fileset -constrset constrs_1
	}

	# Set 'constrs_1' fileset object
	set obj [get_filesets constrs_1]
	set files [list \
		"[file normalize "$origin_dir/../02_coaxlink/constr/CxlCxp12_loc_common.xdc"]"\
		"[file normalize "$origin_dir/../02_coaxlink/constr/CxlCxp12_xil_x8_gen3.xdc"]"\
		"[file normalize "$origin_dir/../02_coaxlink/constr/CxlCxp12_timing_common.xdc"]"\
		"[file normalize "$origin_dir/../02_coaxlink/constr/Bitstream_settings.xdc"]"\
		"[file normalize "$origin_dir/../04_ref_design/CustomLogic.xdc"]"\
	]
	add_files -norecurse -fileset $obj $files

	# Set 'constrs_1' fileset properties
	set obj [get_filesets constrs_1]
	set_property "target_constrs_file" "[file normalize "$origin_dir/../04_ref_design/CustomLogic.xdc"]" $obj
	
	# Set 'sources_1' fileset object
	set obj [get_filesets sources_1]
	set files [list \
		"[file normalize "$origin_dir/../02_coaxlink/ip/mem_if/mem_if.xci"]"\
		"[file normalize "$origin_dir/../02_coaxlink/ip/PoCXP_uBlaze/PoCXP_uBlaze.xci"]"\
		"[file normalize "$origin_dir/../04_ref_design/ip/lut_bram_8x256/lut_bram_8x256.xci"]"\
	]
	add_files -norecurse -fileset $obj $files
	
	# Generate IPs
	generate_target all [get_files $files]

	# Associate ELF file
	set_property SCOPED_TO_REF PoCXP_uBlaze [get_files -all -of_objects [get_fileset sources_1] {PoCXP_uBlaze.elf}]
	set_property SCOPED_TO_CELLS { inst/microblaze_I } [get_files -all -of_objects [get_fileset sources_1] {PoCXP_uBlaze.elf}]

	# Set Implementation strategy
	set_property strategy Performance_Explore [get_runs impl_1]
	set_property STEPS.PLACE_DESIGN.ARGS.DIRECTIVE WLDrivenBlockPlacement [get_runs impl_1]
	
	puts  " "
	puts  "EURESYS_INFO: Creating the CustomLogic Vivado project... done"
	puts  " "
}

customLogicCreateProject