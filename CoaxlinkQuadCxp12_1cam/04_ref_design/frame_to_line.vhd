--------------------------------------------------------------------------------
-- Project: CustomLogic
--------------------------------------------------------------------------------
--  Module: frame_to_line
--    File: frame_to_line.vhd
--    Date: 2018-01-26
--     Rev: 0.1
--  Author: PP
--------------------------------------------------------------------------------
-- Reference Design: Frame to Line converter
--   This module outputs one line from each input frame. The line index increments
--   for each input frame. The size of the resulting frame is equivalent to the
--   size of the input frame.
--------------------------------------------------------------------------------
-- 0.1, 2018-01-26, PP, Initial release
--------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.CustomLogicPkg.all;


entity frame_to_line is
	generic (
		DATA_WIDTH 				: natural := 256
	);
	port (
        -- Control
		PipelineClear			: in  std_logic;
		Frame2Line_bypass		: in  std_logic;
        -- AXI Stream Interface
		axis_aclk	 			: in  std_logic;
		axis_areset 			: in  std_logic;
		axis_tvalid_in			: in  std_logic;
		axis_tready_in			: out std_logic;
		axis_tdata_in			: in  std_logic_vector(DATA_WIDTH - 1 downto 0);
		axis_tuser_in			: in  std_logic_vector(  3 downto 0);
		axis_tvalid_out			: out std_logic;
		axis_tready_out			: in  std_logic;
		axis_tdata_out			: out std_logic_vector(DATA_WIDTH - 1 downto 0);
		axis_tuser_out			: out std_logic_vector(  3 downto 0);
        -- Image Header and Metadata
		Metadata_in				: in  Metadata_rec;
		Metadata_out			: out Metadata_rec
	);
end entity frame_to_line;

architecture behav of frame_to_line is

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
    -- Global Reset
	signal reset				: std_logic;
	
    -- TUSER decoding
	signal axis_tuser_in_sof	: std_logic;
	signal axis_tuser_in_sol	: std_logic;
	signal axis_tuser_in_eol	: std_logic;
	signal axis_tuser_in_eof	: std_logic;
	
	-- Frame and Line Counters
	signal input_line_cnt		: std_logic_vector(23 downto 0);
	signal input_frame_cnt		: std_logic_vector(31 downto 0);
	signal output_frame_cnt		: std_logic_vector(23 downto 0);

	---- Pipeline Stage 0 ------------------------------------------------------
	-- Video Stream Pipeline
	signal s0_axis_tvalid		: std_logic;
	signal s0_axis_tdata		: std_logic_vector(DATA_WIDTH - 1 downto 0);
	signal s0_axis_tuser		: std_logic_vector(  3 downto 0);
	signal s0_axis_tuser_sol	: std_logic;
	signal s0_axis_tuser_eol	: std_logic;
	signal s0_Metadata			: Metadata_rec;

	-- Line Selector
	signal s0_output_line_en	: std_logic;

	-- Output Frame Flags
	signal s0_output_sof		: std_logic;
	signal s0_output_eof		: std_logic;
	
	---- Pipeline Stage 1 ------------------------------------------------------
	-- Video Stream Pipeline
	signal s1_axis_tvalid		: std_logic;
	signal s1_axis_tdata		: std_logic_vector(DATA_WIDTH - 1 downto 0);
	signal s1_axis_tuser		: std_logic_vector(  3 downto 0);
	signal s1_Metadata			: Metadata_rec;

	----------------------------------------------------------------------------
	-- Debug
	----------------------------------------------------------------------------
    -- attribute mark_debug : string;
    -- attribute mark_debug of axis_tuser_in_sof	: signal is "true";
    -- attribute mark_debug of axis_tuser_in_eof	: signal is "true";
   
    
begin
    
    ---- Global Reset ----------------------------------------------------------
	reset <= axis_areset or PipelineClear;
	
    ---- TUSER decoding --------------------------------------------------------
	axis_tuser_in_sof <= axis_tuser_in(0);
	axis_tuser_in_sol <= axis_tuser_in(1);
	axis_tuser_in_eol <= axis_tuser_in(2);
	axis_tuser_in_eof <= axis_tuser_in(3);
	
	---- Frame and Line Counters -----------------------------------------------
    pCounters : process(axis_aclk) is
	begin
		if rising_edge(axis_aclk) then
			if axis_tready_out='1' and axis_tvalid_in='1' and axis_tuser_in_eol='1' then
				input_line_cnt <= std_logic_vector(unsigned(input_line_cnt) + 1);
			end if;
			if axis_tready_out='1' and axis_tvalid_in='1' and axis_tuser_in_eof='1' then
				input_line_cnt  	<= (others=>'0');
				input_frame_cnt		<= std_logic_vector(unsigned(input_frame_cnt) + 1);
				output_frame_cnt	<= std_logic_vector(unsigned(output_frame_cnt) + 1);
				if unsigned(output_frame_cnt) = unsigned(s0_Metadata.Ysize) - 1 then
					output_frame_cnt <= (others=>'0');
				end if;
			end if;
			if reset = '1' then
				input_line_cnt  	<= (others=>'0');
				input_frame_cnt		<= (others=>'0');
				output_frame_cnt 	<= (others=>'0');
			end if;
		end if;
	end process;
	
	----------------------------------------------------------------------------
	-- Pipeline Stage 0
	----------------------------------------------------------------------------
	---- Video Stream Pipeline -------------------------------------------------
	pStreamPipeline_s0 : process(axis_aclk) is
	begin
		if rising_edge(axis_aclk) then
			if axis_tready_out='1' then
				s0_axis_tvalid	<= axis_tvalid_in;
				s0_axis_tdata	<= axis_tdata_in;
				s0_axis_tuser	<= axis_tuser_in;
				-- Latch Image Header
				if axis_tvalid_in='1' and axis_tuser_in_sof='1' then
					s0_Metadata <= Metadata_in;
				end if;
			end if;
			if reset = '1' then
				s0_axis_tvalid <= '0';
			end if;
		end if;
	end process;
	
	---- Line Selector ---------------------------------------------------------
	pLineSelector_s0 : process(axis_aclk) is
	begin
		if rising_edge(axis_aclk) then
			if axis_tready_out='1' and s0_axis_tvalid='1' and s0_axis_tuser_eol='1' then
				s0_output_line_en <= '0';
			end if;
			if axis_tready_out='1' and axis_tvalid_in='1' and axis_tuser_in_sol='1' then
				if output_frame_cnt = input_line_cnt then
					s0_output_line_en <= '1';
				end if;
			end if;
			if reset = '1' then
				s0_output_line_en <= '0';
			end if;
		end if;
	end process;
	
	s0_axis_tuser_sol <= s0_axis_tuser(1);
	s0_axis_tuser_eol <= s0_axis_tuser(2);
	
	---- Output Frame Flags ----------------------------------------------------
	pOutputFrameFlags_s0 : Process(axis_aclk) is
	begin
		if rising_edge(axis_aclk) then
			if axis_tready_out='1' and s0_axis_tvalid='1' and s0_axis_tuser_sol='1' then
				if unsigned(output_frame_cnt) = 0 then
					s0_output_sof <= '0';
				end if;
			end if;
			if axis_tready_out='1' and axis_tvalid_in='1' and axis_tuser_in_eol='1' then
				if (unsigned(output_frame_cnt) = unsigned(s0_Metadata.Ysize) - 1) and
				   (unsigned(input_line_cnt)  = unsigned(s0_Metadata.Ysize) - 1) then
						s0_output_eof <= '1';
				end if;
			end if;
			if axis_tready_out='1' and s0_axis_tvalid='1' and s0_axis_tuser_eol='1' and s0_output_eof = '1' then
				s0_output_eof <= '0';
				s0_output_sof <= '1';
			end if;
			if reset = '1' then
				s0_output_sof <= '1';
				s0_output_eof <= '0';
			end if;
		end if;
	end process;
	
	----------------------------------------------------------------------------
	-- Pipeline Stage 1
	----------------------------------------------------------------------------
	---- Video Stream Pipeline -------------------------------------------------
	pStreamPipeline_s1 : process(axis_aclk) is
	begin
		if rising_edge(axis_aclk) then
			if axis_tready_out='1' then
				s1_axis_tvalid		<= s0_axis_tvalid and s0_output_line_en;
				s1_axis_tdata		<= s0_axis_tdata;
				s1_axis_tuser(0)	<= s0_output_sof;
				s1_axis_tuser(1)	<= s0_axis_tuser_sol;
				s1_axis_tuser(2)	<= s0_axis_tuser_eol;
				s1_axis_tuser(3)	<= s0_output_eof;
				s1_Metadata			<= s0_Metadata;
				s1_Metadata.Status	<= input_frame_cnt;
				if Frame2Line_bypass = '1' then
					s1_axis_tvalid 	<= s0_axis_tvalid;
					s1_axis_tuser	<= s0_axis_tuser;
				end if;
			end if;
			if reset = '1' then
				s1_axis_tvalid <= '0';
			end if;
		end if;
	end process;
	
	----------------------------------------------------------------------------
	-- Output Mapping
	----------------------------------------------------------------------------
	axis_tvalid_out			<= s1_axis_tvalid;
	axis_tready_in			<= axis_tready_out;
	axis_tdata_out			<= s1_axis_tdata;
	axis_tuser_out			<= s1_axis_tuser;
	Metadata_out			<= s1_Metadata;

end behav; 
