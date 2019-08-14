--------------------------------------------------------------------------------
-- Project: CustomLogic
--------------------------------------------------------------------------------
--  Module: control_registers
--    File: control_registers.vhd
--    Date: 2018-06-04
--     Rev: 0.1
--  Author: PP
--------------------------------------------------------------------------------
-- Reference Design: Control Registers decoder
--   This module shows how to use the CustomLogic Control Interface as a register
--   map decoder.
--------------------------------------------------------------------------------
-- 0.1, 2018-06-04, PP, Initial release
--------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity control_registers is
	port (
		-- Clock / Reset
		clk							: in  std_logic;
		srst						: in  std_logic;
        -- Control Interface
		CustomLogic_ctrl_addr		: in  std_logic_vector(15 downto 0);
		CustomLogic_ctrl_data_in_ce	: in  std_logic;
		CustomLogic_ctrl_data_in	: in  std_logic_vector(31 downto 0);
		CustomLogic_ctrl_data_out	: out std_logic_vector(31 downto 0);
        -- Registers
		Frame2Line_bypass			: out std_logic;
		MemTrafficGen_en			: out std_logic;
		MementoEvent_en				: out std_logic;
		MementoEvent_arg0			: out std_logic_vector(31 downto 0);
		PixelLut_bypass				: out std_logic;
		PixelLut_coef_start			: out std_logic;
		PixelLut_coef_vld			: out std_logic;
		PixelLut_coef				: out std_logic_vector( 7 downto 0);
		PixelLut_coef_done			: in  std_logic;
		PixelThreshold_bypass		: out std_logic;
		PixelThreshold_level		: out std_logic_vector( 7 downto 0)
	);
end entity control_registers;

architecture behav of control_registers is

	----------------------------------------------------------------------------
	-- Constants
	----------------------------------------------------------------------------
	constant ADDR_SCRATCHPAD		: std_logic_vector(15 downto 0) := x"0000";
	constant ADDR_FRAME2LINE		: std_logic_vector(15 downto 0) := x"0001";
	constant ADDR_MEMTRAFFICGEN		: std_logic_vector(15 downto 0) := x"0002";
	constant ADDR_MEMENTOEVENT		: std_logic_vector(15 downto 0) := x"0003";
	constant ADDR_PIXELLUT		    : std_logic_vector(15 downto 0) := x"0004";
	constant ADDR_PIXELLUTCOEF		: std_logic_vector(15 downto 0) := x"0005";
	constant ADDR_PIXELTHRESHOLD	: std_logic_vector(15 downto 0) := x"0006";

    
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
	
    -- Registers
	signal scratchpad_reg			: std_logic_vector(31 downto 0);
	signal frame2line_bypass_reg	: std_logic;
	signal memtrafficgen_reg		: std_logic;
	signal mementoevent_reg			: std_logic_vector(31 downto 0);
	signal pixellut_bypass_reg		: std_logic;
	signal pixellut_coef_reg		: std_logic_vector( 7 downto 0);
	signal hls_pixth_bypass_reg		: std_logic;
	signal hls_pixth_level_reg		: std_logic_vector( 7 downto 0);
	

	----------------------------------------------------------------------------
	-- Debug
	----------------------------------------------------------------------------
    -- attribute mark_debug : string;
    -- attribute mark_debug of Frame2Line_bypass	: signal is "true";
    -- attribute mark_debug of MemTrafficGen_en		: signal is "true";
   
    
begin
    
    ---- Write decoding --------------------------------------------------------
    pWrite : process(clk) is
	begin
		if rising_edge(clk) then
			MementoEvent_en 	<= '0';
			PixelLut_coef_start	<= '0';
			PixelLut_coef_vld	<= '0';
			if CustomLogic_ctrl_data_in_ce = '1' then
				case CustomLogic_ctrl_addr is
					when ADDR_SCRATCHPAD =>
						scratchpad_reg <= CustomLogic_ctrl_data_in;
					when ADDR_FRAME2LINE =>
						frame2line_bypass_reg <= CustomLogic_ctrl_data_in(0);
					when ADDR_MEMTRAFFICGEN =>
						memtrafficgen_reg <= CustomLogic_ctrl_data_in(0);
					when ADDR_MEMENTOEVENT =>
						MementoEvent_en 	<= '1';
						mementoevent_reg 	<= CustomLogic_ctrl_data_in;
					when ADDR_PIXELLUT =>
						PixelLut_coef_start <= CustomLogic_ctrl_data_in(0);
						case CustomLogic_ctrl_data_in(9 downto 8) is
							when "01" => pixellut_bypass_reg <= '1';
							when "10" => pixellut_bypass_reg <= '0';
							when others =>
						end case;
					when ADDR_PIXELLUTCOEF =>
						PixelLut_coef_vld 	<= '1';
						pixellut_coef_reg	<= CustomLogic_ctrl_data_in(7 downto 0);
					when ADDR_PIXELTHRESHOLD =>
						if CustomLogic_ctrl_data_in(7 downto 0) /= x"00" then
							hls_pixth_level_reg <= CustomLogic_ctrl_data_in(7 downto 0);
						end if;
						case CustomLogic_ctrl_data_in(9 downto 8) is
							when "01" => hls_pixth_bypass_reg <= '1';
							when "10" => hls_pixth_bypass_reg <= '0';
							when others =>
						end case;
					when others =>
				end case;
			end if;
			if srst = '1' then
				scratchpad_reg			<= (others=>'0');
				frame2line_bypass_reg 	<= '1';
				memtrafficgen_reg 		<= '0';
				mementoevent_reg 		<= (others=>'0');
				pixellut_coef_reg		<= (others=>'0');
				pixellut_bypass_reg		<= '1';
				hls_pixth_bypass_reg	<= '1';
				hls_pixth_level_reg		<= x"01";
			end if;
		end if;
	end process;
	
    ---- Read decoding ---------------------------------------------------------
    pRead : process(clk) is
	begin
		if rising_edge(clk) then
			CustomLogic_ctrl_data_out <= (others=>'0');
			case CustomLogic_ctrl_addr is
				when ADDR_SCRATCHPAD =>
					CustomLogic_ctrl_data_out <= scratchpad_reg;
				when ADDR_FRAME2LINE =>
					CustomLogic_ctrl_data_out(0) <= frame2line_bypass_reg;
				when ADDR_MEMTRAFFICGEN =>
					CustomLogic_ctrl_data_out(0) <= memtrafficgen_reg;
				when ADDR_MEMENTOEVENT =>
					CustomLogic_ctrl_data_out <= mementoevent_reg;
				when ADDR_PIXELLUT =>
					CustomLogic_ctrl_data_out(4) <= PixelLut_coef_done;
					case pixellut_bypass_reg is
						when '1' => CustomLogic_ctrl_data_out(9 downto 8) <= "01";
						when '0' => CustomLogic_ctrl_data_out(9 downto 8) <= "10";
						when others =>
					end case;
				when ADDR_PIXELTHRESHOLD =>
					CustomLogic_ctrl_data_out(7 downto 0) <= hls_pixth_level_reg;
					case hls_pixth_bypass_reg is
						when '1' => CustomLogic_ctrl_data_out(9 downto 8) <= "01";
						when '0' => CustomLogic_ctrl_data_out(9 downto 8) <= "10";
						when others =>
					end case;
				when others =>
			end case;
		end if;
	end process;
	
	---- Output Register Mapping -----------------------------------------------
	Frame2Line_bypass	    <= frame2line_bypass_reg;
	MemTrafficGen_en 	    <= memtrafficgen_reg;
	MementoEvent_arg0	    <= mementoevent_reg;
	PixelLut_bypass		    <= pixellut_bypass_reg;
	PixelLut_coef		    <= pixellut_coef_reg;
	PixelThreshold_bypass	<= hls_pixth_bypass_reg;
	PixelThreshold_level	<= hls_pixth_level_reg;
	
    
end behav; 
