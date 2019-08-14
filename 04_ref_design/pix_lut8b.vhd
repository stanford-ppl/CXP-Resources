--------------------------------------------------------------------------------
-- Project: CustomLogic
--------------------------------------------------------------------------------
--  Module: pix_lut8b
--    File: pix_lut8b.vhd
--    Date: 2019-03-06
--     Rev: 0.1
--  Author: PP
--------------------------------------------------------------------------------
-- Reference Design: Pixel LUT 8-bit
--   This module provides lookup table capabilities to compute gamma correction,
--   thresholding, inversion, etc. 
--------------------------------------------------------------------------------
-- 0.1, 2019-03-06, PP, Initial release
--------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.CustomLogicPkg.all;


entity pix_lut8b is
	generic (
		DATA_WIDTH 				: natural := 256
	);
	port (
        -- Control
		PipelineClear			: in  std_logic;
		PixelLut_bypass			: in  std_logic;
		PixelLut_coef_start		: in  std_logic;
		PixelLut_coef			: in  std_logic_vector(7 downto 0);
		PixelLut_coef_vld		: in  std_logic;
		PixelLut_coef_done		: out std_logic;
        -- Clock/Reset
		axis_aclk	 			: in  std_logic;
		axis_areset 			: in  std_logic;
		-- AXI Stream Input Interface
		axis_tvalid_in			: in  std_logic;
		axis_tready_in			: out std_logic;
		axis_tdata_in			: in  std_logic_vector(DATA_WIDTH - 1 downto 0);
		axis_tuser_in			: in  std_logic_vector(3 downto 0);
		-- Image Header and Metadata Input
		Metadata_in				: in  Metadata_rec;
		-- AXI Stream Output Interface
		axis_tvalid_out			: out std_logic;
		axis_tready_out			: in  std_logic;
		axis_tdata_out			: out std_logic_vector(DATA_WIDTH - 1 downto 0);
		axis_tuser_out			: out std_logic_vector(3 downto 0);
        -- Image Header and Metadata Output
		Metadata_out			: out Metadata_rec
	);
end entity pix_lut8b;

architecture behav of pix_lut8b is

	----------------------------------------------------------------------------
	-- Constants
	----------------------------------------------------------------------------
	constant PIXEL_WIDTH 	: natural := 8;
	constant NB_OF_PIXELS 	: natural := DATA_WIDTH / PIXEL_WIDTH;

    
	----------------------------------------------------------------------------
	-- Types
	----------------------------------------------------------------------------
	type pixel_a_type is array (natural range <>) of std_logic_vector(PIXEL_WIDTH - 1 downto 0);

	----------------------------------------------------------------------------
	-- Functions
	----------------------------------------------------------------------------

    
	----------------------------------------------------------------------------
	-- Components
	----------------------------------------------------------------------------
	COMPONENT lut_bram_8x256
		PORT (
			clka 	: IN  STD_LOGIC;
			wea 	: IN  STD_LOGIC_VECTOR(0 downto 0);
			addra 	: IN  STD_LOGIC_VECTOR(PIXEL_WIDTH - 1 downto 0);
			dina 	: IN  STD_LOGIC_VECTOR(PIXEL_WIDTH - 1 downto 0);
			clkb 	: IN  STD_LOGIC;
			enb 	: IN  STD_LOGIC;
			addrb 	: IN  STD_LOGIC_VECTOR(PIXEL_WIDTH - 1 downto 0);
			doutb 	: OUT STD_LOGIC_VECTOR(PIXEL_WIDTH - 1 downto 0)
		);
	END COMPONENT;
	
	
	----------------------------------------------------------------------------
	-- Signals
	----------------------------------------------------------------------------
	
    -- Global Reset
	signal reset				: std_logic;
	
	-- Lookup Table
	signal lut_bram_wea			: std_logic_vector(0 downto 0);
	signal lut_bram_addra		: std_logic_vector(PIXEL_WIDTH - 1 downto 0);
	signal lut_bram_dina		: std_logic_vector(PIXEL_WIDTH - 1 downto 0);
	signal lut_bram_enb			: std_logic;
	signal lut_bram_addrb		: pixel_a_type(NB_OF_PIXELS - 1 downto 0);
	signal lut_bram_doutb		: pixel_a_type(NB_OF_PIXELS - 1 downto 0);
	signal lut_bram_ready		: std_logic;
	signal lut_bram_done		: std_logic;
    
	-- Vector to Array
	signal axis_tdata_in_a		: pixel_a_type(NB_OF_PIXELS - 1 downto 0);
	
	-- Video Stream Pipeline (compensate BRAM latency)
	signal s0_axis_tvalid		: std_logic;
	signal s0_axis_tuser		: std_logic_vector(3 downto 0);
	signal s0_Metadata			: Metadata_rec;
	signal s1_axis_tvalid		: std_logic;
	signal s1_axis_tdata		: std_logic_vector(DATA_WIDTH - 1 downto 0);
	signal s1_axis_tuser		: std_logic_vector(3 downto 0);
	signal s1_Metadata			: Metadata_rec;
	
	-- Video Stream Pipeline (bypass)
	signal s2_axis_tvalid		: std_logic;
	signal s2_axis_tdata		: std_logic_vector(DATA_WIDTH - 1 downto 0);
	signal s2_axis_tuser		: std_logic_vector(3 downto 0);
	signal s2_Metadata			: Metadata_rec;
	

	----------------------------------------------------------------------------
	-- Debug
	----------------------------------------------------------------------------
    -- attribute mark_debug : string;
    -- attribute mark_debug of lut_bram_ready	: signal is "true";
    -- attribute mark_debug of lut_bram_done	: signal is "true";
   
    
begin
    
    ---- Global Reset ----------------------------------------------------------
	reset <= axis_areset or PipelineClear;
	
    ---- Lookup Table Control --------------------------------------------------
    pLutBramWrite : process(axis_aclk) is
	begin
		if rising_edge(axis_aclk) then
			if PixelLut_coef_start = '1' then
				lut_bram_addra 	<= (others=>'0');
				lut_bram_ready	<= '1';
				lut_bram_done  	<= '0';
			end if;
			if lut_bram_ready='1' and PixelLut_coef_vld='1' then
				lut_bram_addra <= std_logic_vector(unsigned(lut_bram_addra) + 1);
				if lut_bram_addra = x"FF" then
					lut_bram_ready <= '0';
					lut_bram_done  <= '1';
				end if;
			end if;
			if reset = '1' then
				lut_bram_ready  <= '0';
				lut_bram_done  	<= '0';
			end if;
		end if;
	end process;	
	
	lut_bram_wea(0)		<= PixelLut_coef_vld and lut_bram_ready;
	lut_bram_dina		<= PixelLut_coef;
	PixelLut_coef_done	<= lut_bram_done;

    ---- Lookup Table BRAM -----------------------------------------------------
    pInputVector2Array : process(axis_tdata_in) is
	begin
		for n in 0 to NB_OF_PIXELS - 1 loop
			axis_tdata_in_a(n) <= axis_tdata_in(PIXEL_WIDTH*(n + 1) - 1 downto PIXEL_WIDTH * n);
		end loop;
	end process;
	
	lut_bram_enb	<= axis_tready_out;
	lut_bram_addrb 	<= axis_tdata_in_a;
	
	gLutBram : for n in 0 to NB_OF_PIXELS - 1 generate
		iLutBram : lut_bram_8x256
		port map (
			clka 	=> axis_aclk,
			wea 	=> lut_bram_wea,
			addra 	=> lut_bram_addra,
			dina 	=> lut_bram_dina,
			clkb 	=> axis_aclk,
			enb 	=> lut_bram_enb,
			addrb 	=> lut_bram_addrb(n),
			doutb 	=> lut_bram_doutb(n)
		);
	end generate;
	
    pOutputArray2Vector : process(lut_bram_doutb) is
	begin
		for n in 0 to NB_OF_PIXELS - 1 loop
			s1_axis_tdata(PIXEL_WIDTH*(n + 1) - 1 downto PIXEL_WIDTH * n) <= lut_bram_doutb(n);
		end loop;
	end process;
	
	-- Compensate BRAM latency
    pLutBramLatency : process(axis_aclk) is
	begin
		if rising_edge(axis_aclk) then
			if axis_tready_out = '1' then
				s0_axis_tvalid 	<= axis_tvalid_in;
				s0_axis_tuser	<= axis_tuser_in;
				s0_Metadata  	<= Metadata_in;
				s1_axis_tvalid 	<= s0_axis_tvalid;
				s1_axis_tuser	<= s0_axis_tuser;
				s1_Metadata  	<= s0_Metadata;
			end if;
			if reset = '1' then
				s0_axis_tvalid  <= '0';
				s1_axis_tvalid 	<= '0';
			end if;
		end if;
	end process;
	
	-- Bypass
    pLutBramBypass : process(axis_aclk) is
	begin
		if rising_edge(axis_aclk) then
			if axis_tready_out = '1' then
				s2_axis_tvalid 	<= s1_axis_tvalid;
				s2_axis_tdata	<= s1_axis_tdata;
				s2_axis_tuser	<= s1_axis_tuser;
				s2_Metadata  	<= s1_Metadata;
				if PixelLut_bypass = '1' then
					s2_axis_tvalid 	<= axis_tvalid_in;
					s2_axis_tdata	<= axis_tdata_in;
					s2_axis_tuser	<= axis_tuser_in;
					s2_Metadata  	<= Metadata_in;
				end if;
			end if;
			if reset = '1' then
				s2_axis_tvalid  <= '0';
			end if;
		end if;
	end process;
	
	
	----------------------------------------------------------------------------
	-- Output Mapping
	----------------------------------------------------------------------------
	axis_tvalid_out	<= s2_axis_tvalid;
	axis_tready_in	<= axis_tready_out;
	axis_tdata_out	<= s2_axis_tdata;
	axis_tuser_out	<= s2_axis_tuser;
	Metadata_out	<= s2_Metadata;


end behav; 
