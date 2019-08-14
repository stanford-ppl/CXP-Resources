--------------------------------------------------------------------------------
-- Project: CustomLogic (Coaxlink CXP-12)
--------------------------------------------------------------------------------
--  Module: CustomLogicTop
--    File: CustomLogicTop.vhd
--    Date: 2018-11-19
--     Rev: 0.1
--  Author: PP
--------------------------------------------------------------------------------
-- Top level
--------------------------------------------------------------------------------
-- 0.1, 2018-11-19, PP, Initial release
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- NOTE: THIS FILE SHALL NOT BE MODIFIED.
--------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.CustomLogicPkg.all;


entity CustomLogicTop is
	port (
		-- Oscillator
		osc_125M_p  	   	: in    std_logic;		-- 125MHz
        osc_125M_n          : in    std_logic;		
		-- PCIe GEN3x8
		perst_n     		: in    std_logic; 		-- PCI Express slot PERST# reset signal
		wake_n				: inout	std_logic;
		pcie_clk_p			: in    std_logic; 		-- 100MHz PCIe Reference Clock Input
		pcie_clk_n			: in    std_logic; 		
		tx_p				: out   std_logic_vector(  7 downto 0);	-- PCIe differential transmit 
		tx_n				: out   std_logic_vector(  7 downto 0);
		rx_p				: in    std_logic_vector(  7 downto 0);	-- PCIe differential receive 
		rx_n				: in    std_logic_vector(  7 downto 0); 
		-- DDR4
		c0_sys_clk_p 		: in    std_logic;
		c0_sys_clk_n 		: in    std_logic;
		c0_ddr4_act_n 		: out   std_logic;
		c0_ddr4_adr 		: out   std_logic_vector( 16 downto 0);
		c0_ddr4_ba 			: out   std_logic_vector(  1 downto 0);
		c0_ddr4_bg 			: out   std_logic_vector(  0     to 0);
		c0_ddr4_cke 		: out   std_logic_vector(  0     to 0);
		c0_ddr4_odt 		: out   std_logic_vector(  0     to 0);
		c0_ddr4_cs_n 		: out   std_logic_vector(  0     to 0);
		c0_ddr4_ck_t 		: out   std_logic_vector(  0     to 0);
		c0_ddr4_ck_c 		: out   std_logic_vector(  0     to 0);
		c0_ddr4_reset_n 	: out   std_logic;
		c0_ddr4_dm_dbi_n 	: inout std_logic_vector(  7 downto 0);
		c0_ddr4_dq 			: inout std_logic_vector( 63 downto 0);
		c0_ddr4_dqs_c 		: inout std_logic_vector(  7 downto 0);
		c0_ddr4_dqs_t 		: inout std_logic_vector(  7 downto 0);
		-- CoaXPress
		cxph_gth_clk_p 		: in    std_logic;		-- 250MHz
		cxph_gth_clk_n 		: in    std_logic;
		cxph_rx_p      		: in    std_logic_vector(  3 downto 0);	-- Downlink high-speed(3:0)
		cxph_rx_n      		: in    std_logic_vector(  3 downto 0);  
		cxph_tx_p      		: out   std_logic_vector(  3 downto 0);	-- Uplink low-speed(3:0)
		cxph_tx_n      		: out   std_logic_vector(  3 downto 0);
		dr_sclk             : out   std_logic;
		dr_csn              : out   std_logic_vector(  3 downto 0);
		dr_si               : out   std_logic;
		dr_so               : in    std_logic;
		eq_sclk             : out   std_logic;
        eq_csn              : out   std_logic_vector(  3 downto 0);
        eq_si               : out   std_logic;
        eq_so               : in    std_logic;
		-- Board Config/Status
		cfg_sda				: inout	std_logic;
		cfg_scl				: inout	std_logic;
		cfg_wp_n			: out   std_logic;
		cfg_clkout			: out   std_logic;
		cfg_data			: inout std_logic_vector( 15 downto 4);		
		cfg_fcs_n		    : out   std_logic;
		lastbootbank		: in    std_logic;
		fanspeed			: in 	std_logic;
		fanpwm		      	: out	std_logic;
		force_re_prog_n		: out	std_logic;
		pmaid				: in    std_logic_vector(  1     to 3 );
		status_ledg			: out   std_logic;
		status_ledr			: out   std_logic;
		-- I/Os
		csync				: inout	std_logic_vector(  1     to 3 );
		iout1				: out	std_logic_vector(  1     to 2 );
		ttlio1_data			: inout	std_logic_vector(  1     to 2 );
		ttlio1_dir			: out	std_logic_vector(  1     to 2 );
		din1				: in 	std_logic_vector(  1     to 2 );
		iin1				: in 	std_logic_vector(  1     to 4 );
		iout2				: out	std_logic_vector(  1     to 2 );
		ttlio2_data			: inout	std_logic_vector(  1     to 2 );
		ttlio2_dir			: out	std_logic_vector(  1     to 2 );
		din2				: in 	std_logic_vector(  1     to 2 );
		iin2				: in 	std_logic_vector(  1     to 4 );
		io_ext1_1wire		: inout std_logic;
        io_ext1     		: inout std_logic_vector(  1     to 12);
		pocled_sda			: inout std_logic;
		pocled_scl			: inout std_logic;
		-- Power over CoaXPress
		poc_sda				: inout std_logic;
		poc_scl				: inout std_logic;
		poc_alert			: in 	std_logic;
        peg_prst_12v		: in    std_logic;
		vps24_pg			: in	std_logic;
		en_vps24			: out	std_logic
	);
end entity CustomLogicTop;

architecture behav of CustomLogicTop is

	----------------------------------------------------------------------------
	-- Constants
	----------------------------------------------------------------------------
	constant DATA_WIDTH			: natural := 256;

	----------------------------------------------------------------------------
	-- Types
	----------------------------------------------------------------------------


	----------------------------------------------------------------------------
	-- Components
	----------------------------------------------------------------------------


	----------------------------------------------------------------------------
	-- Signals
	----------------------------------------------------------------------------

	---- Clock/Reset -----------------------------------------------------------
	signal clk250				: std_logic;
	signal srst250				: std_logic;
	
	---- CoaxlinkCore ----------------------------------------------------------
	signal cxl_pipeline_clear	: std_logic;
	signal cxl_axis_tvalid		: std_logic;
	signal cxl_axis_tready		: std_logic;
	signal cxl_axis_tdata		: std_logic_vector(DATA_WIDTH - 1 downto 0);
	signal cxl_axis_tuser		: std_logic_vector(  3 downto 0);
	signal cxl_metadata			: Metadata_rec;
	
	---- CustomLogic -----------------------------------------------------------
	signal cl_axis_tvalid		: std_logic;
	signal cl_axis_tready		: std_logic;
	signal cl_axis_tdata		: std_logic_vector(DATA_WIDTH - 1 downto 0);
	signal cl_axis_tuser		: std_logic_vector(  3 downto 0);
	signal cl_metadata			: Metadata_rec;
	signal cl_mm_event			: std_logic;
	signal cl_mm_event_arg0		: std_logic_vector( 31 downto 0);
	signal cl_mm_event_arg1		: std_logic_vector( 31 downto 0);
	signal cl_ctrl_addr			: std_logic_vector( 15 downto 0);
	signal cl_ctrl_data_in		: std_logic_vector( 32 downto 0);
	signal cl_ctrl_data_out		: std_logic_vector( 31 downto 0);
	signal cl_axi_awaddr 		: std_logic_vector( 31 downto 0);
	signal cl_axi_awlen 		: std_logic_vector(  7 downto 0);
	signal cl_axi_awsize 		: std_logic_vector(  2 downto 0);
	signal cl_axi_awburst 		: std_logic_vector(  1 downto 0);
	signal cl_axi_awlock 		: std_logic;
	signal cl_axi_awcache 		: std_logic_vector(  3 downto 0);
	signal cl_axi_awprot 		: std_logic_vector(  2 downto 0);
	signal cl_axi_awqos 		: std_logic_vector(  3 downto 0);
	signal cl_axi_awvalid 		: std_logic;
	signal cl_axi_awready 		: std_logic;
	signal cl_axi_wdata 		: std_logic_vector(DATA_WIDTH   - 1 downto 0);
	signal cl_axi_wstrb 		: std_logic_vector(DATA_WIDTH/8 - 1 downto 0);
	signal cl_axi_wlast 		: std_logic;
	signal cl_axi_wvalid 		: std_logic;
	signal cl_axi_wready 		: std_logic;
	signal cl_axi_bresp 		: std_logic_vector(  1 downto 0);
	signal cl_axi_bvalid 		: std_logic;
	signal cl_axi_bready 		: std_logic;
	signal cl_axi_araddr 		: std_logic_vector( 31 downto 0);
	signal cl_axi_arlen 		: std_logic_vector(  7 downto 0);
	signal cl_axi_arsize 		: std_logic_vector(  2 downto 0);
	signal cl_axi_arburst 		: std_logic_vector(  1 downto 0);
	signal cl_axi_arlock 		: std_logic;
	signal cl_axi_arcache 		: std_logic_vector(  3 downto 0);
	signal cl_axi_arprot 		: std_logic_vector(  2 downto 0);
	signal cl_axi_arqos 		: std_logic_vector(  3 downto 0);
	signal cl_axi_arvalid 		: std_logic;
	signal cl_axi_arready 		: std_logic;
	signal cl_axi_rdata 		: std_logic_vector(DATA_WIDTH - 1 downto 0);
	signal cl_axi_rresp 		: std_logic_vector(  1 downto 0);
	signal cl_axi_rlast 		: std_logic;
	signal cl_axi_rvalid 		: std_logic;
	signal cl_axi_rready 		: std_logic;

	
    ----------------------------------------------------------------------------
    -- Debug
    ----------------------------------------------------------------------------

	
begin
	
	iCoaxlinkCore : entity work.CoaxlinkCore
		port map (
			---- FPGA I/Os -----------------------------------------------------
			-- Oscillator
			osc_125M_p  	   			=> osc_125M_p,
			osc_125M_n          		=> osc_125M_n,
			-- PCIe GEN3x8
			perst_n     				=> perst_n,
			wake_n						=> wake_n,
			pcie_clk_p					=> pcie_clk_p,
			pcie_clk_n					=> pcie_clk_n,
			tx_p						=> tx_p,
			tx_n						=> tx_n,
			rx_p						=> rx_p,
			rx_n						=> rx_n,
			-- DDR4
			c0_sys_clk_p 				=> c0_sys_clk_p,
			c0_sys_clk_n 				=> c0_sys_clk_n,
			c0_ddr4_act_n 				=> c0_ddr4_act_n,
			c0_ddr4_adr 				=> c0_ddr4_adr,
			c0_ddr4_ba 					=> c0_ddr4_ba,
			c0_ddr4_bg 					=> c0_ddr4_bg,
			c0_ddr4_cke 				=> c0_ddr4_cke,
			c0_ddr4_odt 				=> c0_ddr4_odt,
			c0_ddr4_cs_n 				=> c0_ddr4_cs_n,
			c0_ddr4_ck_t 				=> c0_ddr4_ck_t,
			c0_ddr4_ck_c 				=> c0_ddr4_ck_c,
			c0_ddr4_reset_n 			=> c0_ddr4_reset_n,
			c0_ddr4_dm_dbi_n 			=> c0_ddr4_dm_dbi_n,
			c0_ddr4_dq 					=> c0_ddr4_dq,
			c0_ddr4_dqs_c 				=> c0_ddr4_dqs_c,
			c0_ddr4_dqs_t 				=> c0_ddr4_dqs_t,
			-- CoaXPress
			cxph_gth_clk_p 				=> cxph_gth_clk_p,
			cxph_gth_clk_n 				=> cxph_gth_clk_n,
			cxph_rx_p      				=> cxph_rx_p,
			cxph_rx_n      				=> cxph_rx_n,
			cxph_tx_p					=> cxph_tx_p,
			cxph_tx_n					=> cxph_tx_n,
			dr_sclk             		=> dr_sclk,
			dr_csn              		=> dr_csn,
			dr_si               		=> dr_si,
			dr_so               		=> dr_so,
			eq_sclk             		=> eq_sclk,
			eq_csn              		=> eq_csn,
			eq_si               		=> eq_si,
			eq_so               		=> eq_so,
			-- Board Config/Status
			cfg_sda						=> cfg_sda,
			cfg_scl						=> cfg_scl,
			cfg_wp_n					=> cfg_wp_n,
			cfg_clkout					=> cfg_clkout,
			cfg_data					=> cfg_data,
			cfg_fcs_n					=> cfg_fcs_n,
			lastbootbank				=> lastbootbank,
			fanspeed					=> fanspeed,
			fanpwm						=> fanpwm,
			force_re_prog_n				=> force_re_prog_n,
			pmaid						=> pmaid,
			status_ledg					=> status_ledg,
			status_ledr					=> status_ledr,
			-- I/Os
			csync						=> csync,
			iout1						=> iout1,
			ttlio1_data					=> ttlio1_data,
			ttlio1_dir					=> ttlio1_dir,
			din1						=> din1,
			iin1						=> iin1,
			iout2						=> iout2,
			ttlio2_data					=> ttlio2_data,
			ttlio2_dir					=> ttlio2_dir,
			din2						=> din2,
			iin2						=> iin2,
			io_ext1_1wire               => io_ext1_1wire,
            io_ext1                     => io_ext1,
			pocled_sda					=> pocled_sda,
			pocled_scl					=> pocled_scl,
			-- Power over CoaXPress
			poc_sda						=> poc_sda,
			poc_scl						=> poc_scl,
			poc_alert					=> poc_alert,
			peg_prst_12v				=> peg_prst_12v,
			vps24_pg					=> vps24_pg,
			en_vps24					=> en_vps24,
			---- CustomLogic Interface -----------------------------------------
			-- Clock/Reset/Ctrl 
			clk250						=> clk250,
			srst250						=> srst250,
			PipelineClear				=> cxl_pipeline_clear,
			-- AXI Stream Output Interface 
			axis_tvalid_out				=> cxl_axis_tvalid,
			axis_tready_out				=> cxl_axis_tready,
			axis_tdata_out				=> cxl_axis_tdata,
			axis_tuser_out				=> cxl_axis_tuser,
			-- Output Image Header and Metadata 
			md_StreamId_out				=> cxl_metadata.StreamId,
			md_SourceTag_out			=> cxl_metadata.SourceTag,
			md_Xsize_out				=> cxl_metadata.Xsize,
			md_Xoffs_out				=> cxl_metadata.Xoffs,
			md_Ysize_out				=> cxl_metadata.Ysize,
			md_Yoffs_out				=> cxl_metadata.Yoffs,
			md_DsizeL_out				=> cxl_metadata.DsizeL,
			md_PixelF_out				=> cxl_metadata.PixelF,
			md_TapG_out					=> cxl_metadata.TapG,
			md_Flags_out				=> cxl_metadata.Flags,
			md_Timestamp_out			=> cxl_metadata.Timestamp,
			md_PixProcFlgs_out			=> cxl_metadata.PixProcessingFlgs,
			md_Status_out				=> cxl_metadata.Status,
			-- AXI Stream Input Interface 
			axis_tvalid_in				=> cl_axis_tvalid,
			axis_tready_in				=> cl_axis_tready,
			axis_tdata_in				=> cl_axis_tdata,
			axis_tuser_in				=> cl_axis_tuser,
			-- Input Image Header and Metadata 
			md_StreamId_in				=> cl_metadata.StreamId,
			md_SourceTag_in				=> cl_metadata.SourceTag,
			md_Xsize_in					=> cl_metadata.Xsize,
			md_Xoffs_in					=> cl_metadata.Xoffs,
			md_Ysize_in					=> cl_metadata.Ysize,
			md_Yoffs_in					=> cl_metadata.Yoffs,
			md_DsizeL_in				=> cl_metadata.DsizeL,
			md_PixelF_in				=> cl_metadata.PixelF,
			md_TapG_in					=> cl_metadata.TapG,
			md_Flags_in					=> cl_metadata.Flags,
			md_Timestamp_in				=> cl_metadata.Timestamp,
			md_PixProcFlgs_in			=> cl_metadata.PixProcessingFlgs,
			md_Status_in				=> cl_metadata.Status,
			-- Memento Interface (CustomLogic Event)
			CustomLogic_event			=> cl_mm_event,
			CustomLogic_event_arg0		=> cl_mm_event_arg0,
			CustomLogic_event_arg1		=> cl_mm_event_arg1,
			-- Control Interface
			CustomLogic_ctrl_addr		=> cl_ctrl_addr,
			CustomLogic_ctrl_data_in	=> cl_ctrl_data_out,
			CustomLogic_ctrl_data_out	=> cl_ctrl_data_in,
			-- DDR4 Interface
			cl_axi_awaddr 				=> cl_axi_awaddr,
			cl_axi_awlen 				=> cl_axi_awlen,
			cl_axi_awsize 				=> cl_axi_awsize,
			cl_axi_awburst 				=> cl_axi_awburst,
			cl_axi_awlock 				=> cl_axi_awlock,
			cl_axi_awcache 				=> cl_axi_awcache,
			cl_axi_awprot 				=> cl_axi_awprot,
			cl_axi_awqos 				=> cl_axi_awqos,
			cl_axi_awvalid 				=> cl_axi_awvalid,
			cl_axi_awready 				=> cl_axi_awready,
			cl_axi_wdata 				=> cl_axi_wdata,
			cl_axi_wstrb 				=> cl_axi_wstrb,
			cl_axi_wlast 				=> cl_axi_wlast,
			cl_axi_wvalid 				=> cl_axi_wvalid,
			cl_axi_wready 				=> cl_axi_wready,
			cl_axi_bresp 				=> cl_axi_bresp,
			cl_axi_bvalid 				=> cl_axi_bvalid,
			cl_axi_bready 				=> cl_axi_bready,
			cl_axi_araddr 				=> cl_axi_araddr,
			cl_axi_arlen 				=> cl_axi_arlen,
			cl_axi_arsize 				=> cl_axi_arsize,
			cl_axi_arburst 				=> cl_axi_arburst,
			cl_axi_arlock 				=> cl_axi_arlock,
			cl_axi_arcache 				=> cl_axi_arcache,
			cl_axi_arprot 				=> cl_axi_arprot,
			cl_axi_arqos 				=> cl_axi_arqos,
			cl_axi_arvalid 				=> cl_axi_arvalid,
			cl_axi_arready 				=> cl_axi_arready,
			cl_axi_rdata 				=> cl_axi_rdata,
			cl_axi_rresp 				=> cl_axi_rresp,
			cl_axi_rlast 				=> cl_axi_rlast,
			cl_axi_rvalid 				=> cl_axi_rvalid,
			cl_axi_rready 				=> cl_axi_rready
		);
		
	iCustomLogic : entity work.CustomLogic
		generic map (
			DATA_WIDTH 					=> DATA_WIDTH
		)
		port map (
			-- Clock/Reset/Ctrl
			clk250						=> clk250,
			srst250						=> srst250,
			PipelineClear				=> cxl_pipeline_clear,
			-- AXI Stream Input Interface
			axis_tvalid_in				=> cxl_axis_tvalid,
			axis_tready_in				=> cxl_axis_tready,
			axis_tdata_in				=> cxl_axis_tdata,
			axis_tuser_in				=> cxl_axis_tuser,
			-- Input Image Header and Metadata
			Metadata_in					=> cxl_metadata,
			-- AXI Stream Output Interface
			axis_tvalid_out				=> cl_axis_tvalid,
			axis_tready_out				=> cl_axis_tready,
			axis_tdata_out				=> cl_axis_tdata,
			axis_tuser_out				=> cl_axis_tuser,
			-- Output Image Header and Metadata
			Metadata_out				=> cl_metadata,
			-- Memento Interface (CustomLogic Event)
			CustomLogic_event			=> cl_mm_event,
			CustomLogic_event_arg0		=> cl_mm_event_arg0,
			CustomLogic_event_arg1		=> cl_mm_event_arg1,
			-- Control Interface
			CustomLogic_ctrl_addr		=> cl_ctrl_addr,
			CustomLogic_ctrl_data_in_ce	=> cl_ctrl_data_in(32),
			CustomLogic_ctrl_data_in	=> cl_ctrl_data_in(31 downto 0),
			CustomLogic_ctrl_data_out	=> cl_ctrl_data_out,
			-- DDR4 Interface
			m_axi_awaddr 				=> cl_axi_awaddr,
			m_axi_awlen 				=> cl_axi_awlen,
			m_axi_awsize 				=> cl_axi_awsize,
			m_axi_awburst 				=> cl_axi_awburst,
			m_axi_awlock 				=> cl_axi_awlock,
			m_axi_awcache 				=> cl_axi_awcache,
			m_axi_awprot 				=> cl_axi_awprot,
			m_axi_awqos 				=> cl_axi_awqos,
			m_axi_awvalid 				=> cl_axi_awvalid,
			m_axi_awready 				=> cl_axi_awready,
			m_axi_wdata 				=> cl_axi_wdata,
			m_axi_wstrb 				=> cl_axi_wstrb,
			m_axi_wlast 				=> cl_axi_wlast,
			m_axi_wvalid 				=> cl_axi_wvalid,
			m_axi_wready 				=> cl_axi_wready,
			m_axi_bresp 				=> cl_axi_bresp,
			m_axi_bvalid 				=> cl_axi_bvalid,
			m_axi_bready 				=> cl_axi_bready,
			m_axi_araddr 				=> cl_axi_araddr,
			m_axi_arlen 				=> cl_axi_arlen,
			m_axi_arsize 				=> cl_axi_arsize,
			m_axi_arburst 				=> cl_axi_arburst,
			m_axi_arlock 				=> cl_axi_arlock,
			m_axi_arcache 				=> cl_axi_arcache,
			m_axi_arprot 				=> cl_axi_arprot,
			m_axi_arqos 				=> cl_axi_arqos,
			m_axi_arvalid 				=> cl_axi_arvalid,
			m_axi_arready 				=> cl_axi_arready,
			m_axi_rdata 				=> cl_axi_rdata,
			m_axi_rresp 				=> cl_axi_rresp,
			m_axi_rlast 				=> cl_axi_rlast,
			m_axi_rvalid 				=> cl_axi_rvalid,
			m_axi_rready 				=> cl_axi_rready
		);

end behav;
