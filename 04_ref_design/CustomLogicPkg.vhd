--------------------------------------------------------------------------------
-- Project: CustomLogic
--------------------------------------------------------------------------------
--  Module: CustomLogicPkg
--    File: CustomLogicPkg.vhd
--    Date: 2018-01-12
--     Rev: 0.1
--  Author: PP
--------------------------------------------------------------------------------
-- CustomLogic Package
--------------------------------------------------------------------------------
-- 0.1, 2018-01-12, PP, Initial release
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package CustomLogicPkg is

    -- CoaXPress Image Header / Metadata record --
    type Metadata_rec is
	record
        StreamId			: std_logic_vector(  7 downto 0);
        SourceTag			: std_logic_vector( 15 downto 0);
        Xsize				: std_logic_vector( 23 downto 0);
        Xoffs				: std_logic_vector( 23 downto 0);
        Ysize				: std_logic_vector( 23 downto 0);
        Yoffs				: std_logic_vector( 23 downto 0);
        DsizeL				: std_logic_vector( 23 downto 0);
        PixelF				: std_logic_vector( 15 downto 0);
        TapG				: std_logic_vector( 15 downto 0);
        Flags				: std_logic_vector(  7 downto 0);
		Timestamp			: std_logic_vector( 31 downto 0);
        PixProcessingFlgs	: std_logic_vector(  7 downto 0);
		Status				: std_logic_vector( 31 downto 0);
	end record;

end CustomLogicPkg;

package body CustomLogicPkg is
end CustomLogicPkg; 