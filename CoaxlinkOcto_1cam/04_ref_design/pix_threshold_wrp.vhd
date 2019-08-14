--------------------------------------------------------------------------------
-- Project: CustomLogic
--------------------------------------------------------------------------------
--  Module: pix_threshold_wrp
--    File: pix_threshold_wrp.vhd
--    Date: 2019-03-06
--     Rev: 0.1
--  Author: XC
--------------------------------------------------------------------------------
-- Reference Design: HLS Threshold
--   This module computes a threshold for all input pixels based on the threshold
--   level value.
--------------------------------------------------------------------------------
-- 0.1, 2019-03-06, XC, Initial release
-- 0.2, 2019-04-02, PP, Integrated into CustomLogic release package
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.CustomLogicPkg.all;


entity pix_threshold_wrp is
	generic (
		DATA_WIDTH 				: natural := 256
	);
    port (
        -- Control
		PipelineClear			: in  std_logic;	-- Asserted after a DSStopAcquisition
		HlsThreshold_bypass		: in  std_logic;	-- Bypass data and control
		HlsThreshold_level		: in  std_logic_vector(7 downto 0);	-- Threshold level
        -- Clock/Reset
		axis_aclk				: in  std_logic;	-- Clock 250 MHz
		axis_areset				: in  std_logic; 	-- Synchronous Reset (PCIe reset)
        -- AXI Stream Input Interface
		axis_tvalid_in			: in  std_logic;
		axis_tready_in			: out std_logic;
		axis_tdata_in			: in  std_logic_vector(DATA_WIDTH - 1 downto 0);
		axis_tuser_in			: in  std_logic_vector(  3 downto 0);
        -- Image Header and Metadata Input
		Metadata_in				: in  Metadata_rec;
        -- AXI Stream Output Interface
		axis_tvalid_out			: out std_logic;
		axis_tready_out			: in  std_logic;
		axis_tdata_out			: out std_logic_vector(DATA_WIDTH - 1 downto 0);
		axis_tuser_out			: out std_logic_vector(  3 downto 0);
        -- Image Header and Metadata Output
		Metadata_out			: out Metadata_rec
    );
end entity pix_threshold_wrp;

architecture behav of pix_threshold_wrp is

	----------------------------------------------------------------------------
	-- Constants
	----------------------------------------------------------------------------

    
	----------------------------------------------------------------------------
	-- Types
	----------------------------------------------------------------------------

	
	----------------------------------------------------------------------------
	-- Functions
	----------------------------------------------------------------------------

    
	----------------------------------------------------------------------------
	-- Components
	----------------------------------------------------------------------------
	
	
	----------------------------------------------------------------------------
	-- Signals
	----------------------------------------------------------------------------
	signal reset_n				: std_logic;
    signal reset_n_s   			: std_logic_vector(5 downto 0) := (others => '0');
	
	signal axis_tready_in_int	: std_logic;

    signal pixth_start   		: std_logic;
	signal pixth_tvalid_out		: std_logic;
	signal pixth_tready_out		: std_logic;
	signal pixth_tdata_out		: std_logic_vector(DATA_WIDTH - 1 downto 0);
	signal pixth_tuser_out		: std_logic_vector(  3 downto 0);
	signal pixth_Metadata_out	: Metadata_rec;

	
	----------------------------------------------------------------------------
	-- Debug
	----------------------------------------------------------------------------
    -- attribute mark_debug : string;
    -- attribute mark_debug of HlsThreshold_level	: signal is "true";
    -- attribute mark_debug of pixth_tvalid_out		: signal is "true";


begin
	
	-- HLS Generated IP
	iPixThreshold : entity work.pix_threshold
        port map (
            ap_clk   						=> axis_aclk,
            ap_rst_n 						=> reset_n,
            ap_start 						=> pixth_start,
            ap_done  						=> open,
            ap_idle  						=> open,
            ap_ready 						=> open,
            threshold_value_V 				=> HlsThreshold_level,
            VideoIn_TDATA  					=> axis_tdata_in,
            VideoIn_TVALID 					=> axis_tvalid_in,
            VideoIn_TREADY 					=> axis_tready_in_int,
            VideoIn_TUSER  					=> axis_tuser_in,
            MetaIn_StreamId  				=> Metadata_in.StreamId,
            MetaIn_StreamId_ap_vld 			=> axis_tvalid_in,
            MetaIn_SourceTag 				=> Metadata_in.SourceTag,
            MetaIn_SourceTag_ap_vld 		=> axis_tvalid_in,
            MetaIn_Xsize_V   				=> Metadata_in.Xsize,
            MetaIn_Xsize_V_ap_vld 			=> axis_tvalid_in,
            MetaIn_Xoffs_V   				=> Metadata_in.Xoffs,
            MetaIn_Xoffs_V_ap_vld 			=> axis_tvalid_in,
            MetaIn_Ysize_V   				=> Metadata_in.Ysize,
            MetaIn_Ysize_V_ap_vld 			=> axis_tvalid_in,
            MetaIn_Yoffs_V   				=> Metadata_in.Yoffs,
            MetaIn_Yoffs_V_ap_vld 			=> axis_tvalid_in,
            MetaIn_DsizeL_V  				=> Metadata_in.DsizeL,
            MetaIn_DsizeL_V_ap_vld 			=> axis_tvalid_in,
            MetaIn_PixelF    				=> Metadata_in.PixelF,
            MetaIn_PixelF_ap_vld 			=> axis_tvalid_in,
            MetaIn_TapG      				=> Metadata_in.TapG,
            MetaIn_TapG_ap_vld 				=> axis_tvalid_in,
            MetaIn_Flags     				=> Metadata_in.Flags,
            MetaIn_Flags_ap_vld	 			=> axis_tvalid_in,
            MetaIn_Timestamp 				=> Metadata_in.Timestamp,
            MetaIn_Timestamp_ap_vld 		=> axis_tvalid_in,
            MetaIn_PixProcessingFlgs 		=> Metadata_in.PixProcessingFlgs,
            MetaIn_PixProcessingFlgs_ap_vld => axis_tvalid_in,
            MetaIn_ModPixelF 				=> (others=>'0'),
            MetaIn_ModPixelF_ap_vld 		=> axis_tvalid_in,
            MetaIn_Status    				=> Metadata_in.Status,
            MetaIn_Status_ap_vld 			=> axis_tvalid_in,
            VideoOut_TDATA  				=> pixth_tdata_out,
            VideoOut_TVALID 				=> pixth_tvalid_out,
            VideoOut_TREADY 				=> pixth_tready_out,
            VideoOut_TUSER  				=> pixth_tuser_out,
            MetaOut_StreamId  				=> pixth_Metadata_out.StreamId,
            MetaOut_SourceTag 				=> pixth_Metadata_out.SourceTag,
            MetaOut_Xsize_V   				=> pixth_Metadata_out.Xsize,
            MetaOut_Xoffs_V   				=> pixth_Metadata_out.Xoffs,
            MetaOut_Ysize_V   				=> pixth_Metadata_out.Ysize,
            MetaOut_Yoffs_V   				=> pixth_Metadata_out.Yoffs,
            MetaOut_DsizeL_V  				=> pixth_Metadata_out.DsizeL,
            MetaOut_PixelF    				=> pixth_Metadata_out.PixelF,
            MetaOut_TapG      				=> pixth_Metadata_out.TapG,
            MetaOut_Flags     				=> pixth_Metadata_out.Flags,
            MetaOut_Timestamp 				=> pixth_Metadata_out.Timestamp,
            MetaOut_PixProcessingFlgs 		=> pixth_Metadata_out.PixProcessingFlgs,
            MetaOut_ModPixelF 				=> open,
            MetaOut_Status    				=> pixth_Metadata_out.Status
        );   

	axis_tready_in 		<= axis_tready_out when HlsThreshold_bypass = '1' else axis_tready_in_int;
	pixth_tready_out 	<= axis_tready_out;
	
	-- Reset generation
    pReset : process(axis_aclk)
	begin
		if rising_edge(axis_aclk) then
			reset_n_s 	<= reset_n_s(4 downto 0) & '1';
			pixth_start <= reset_n_s(5);
			if PipelineClear='1' or axis_areset='1' then
				reset_n_s 	<= (others=>'0');
				pixth_start <= '0';
			end if;
		end if;
	end process;
	reset_n <= reset_n_s(5);
	
	-- Output Bypass
    pBypass : process(axis_aclk)
	begin
		if rising_edge(axis_aclk) then
			if axis_tready_out = '1' then
				axis_tvalid_out	<= pixth_tvalid_out;
				axis_tdata_out	<= pixth_tdata_out;
				axis_tuser_out	<= pixth_tuser_out;
				Metadata_out    <= pixth_Metadata_out;
				if HlsThreshold_bypass = '1' then
					axis_tvalid_out	<= axis_tvalid_in;
					axis_tdata_out	<= axis_tdata_in;
					axis_tuser_out	<= axis_tuser_in;
					Metadata_out    <= Metadata_in;
				end if;
			end if;
			if reset_n = '0' then
				axis_tvalid_out	<= '0';
			end if;
		end if;
	end process;

end behav;
