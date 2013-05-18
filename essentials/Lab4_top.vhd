----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    00:13:48 03/29/2013 
-- Design Name: 
-- Module Name:    Lab4_top - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_misc.all;
use IEEE.std_logic_unsigned.all;
use work.FRONTPANEL.all;


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Lab4_top is
	port(
		clk1	: in	STD_LOGIC;
		button	: in	STD_LOGIC_VECTOR(3 downto 0);
		led		: out	STD_LOGIC_VECTOR(7 downto 0);
		
		hi_in 	: in STD_LOGIC_VECTOR(7 downto 0);
		hi_out 	: out STD_LOGIC_VECTOR(1 downto 0);
		hi_inout : inout STD_LOGIC_VECTOR(15 downto 0);
		hi_aa		: inout STD_LOGIC;		
		
		hi_muxsel: out STD_LOGIC
		
	);
	
end Lab4_top;

architecture Behavioral of Lab4_top is
	    COMPONENT traffic_controller_4way is
	generic (
		clk_period : integer := 100000000
	);
    PORT(
		clk    			:		 in STD_LOGIC;
		reset			:        in STD_LOGIC; 
		button 			:		 in STD_LOGIC_VECTOR( 3 downto 0 );
		led 			: 	     out STD_LOGIC_VECTOR( 7 downto 0 ); -- not used
		night_mode 		:		 in STD_LOGIC; 
		EW_red 			:		 out STD_LOGIC;
		EW_green 		:		 out STD_LOGIC; 
		EW_yellow 		:		 out STD_LOGIC;
		EW_walk 		:		 out STD_LOGIC;
		EW_dontwalk 	:		 out STD_LOGIC;
		EW_walkrequest  :		 in STD_LOGIC;
		NS_red 			:		 out STD_LOGIC;
		NS_green 		:		 out STD_LOGIC;
		NS_yellow 		:		 out STD_LOGIC;
		NS_walk 		:		 out STD_LOGIC; 
		NS_dontwalk 	:		 out STD_LOGIC; 
		NS_walkrequest  :		 in STD_LOGIC
      );
    END COMPONENT;


		signal ok1      : 	STD_LOGIC_VECTOR(30 downto 0);
		signal ok2      : 	STD_LOGIC_VECTOR(16 downto 0);
		signal ok2s     : 	STD_LOGIC_VECTOR(17*2-1 downto 0);

		signal ep00wire : STD_LOGIC_VECTOR(15 downto 0);
		signal reset			:         STD_LOGIC; 
		--signal button 		:		  STD_LOGIC_VECTOR( 3 downto 0 );		
		signal ti_clk 			: 		  STD_LOGIC;
		signal night_mode 		:		  STD_LOGIC; 
		signal EW_walkrequest	:	      STD_LOGIC;
		signal NS_walkrequest	:		  STD_LOGIC;
		
		signal ep20wire 		:		  STD_LOGIC_VECTOR(15 downto 0);
		signal ep21wire 		: 		  STD_LOGIC_VECTOR(15 downto 0);
		signal EW_red 			:		  STD_LOGIC;
		signal EW_green 		:		  STD_LOGIC; 
		signal EW_yellow 		:		  STD_LOGIC;
		signal EW_walk 			:		  STD_LOGIC;
		signal EW_dontwalk 		:	 	  STD_LOGIC;
		--signal EW_walkrequest :		  STD_LOGIC;
		signal NS_red 			:		  STD_LOGIC;
		signal NS_green 		:		  STD_LOGIC;
		signal NS_yellow 		:		  STD_LOGIC;
		signal NS_walk 			: 		  STD_LOGIC; 
		signal NS_dontwalk 		:		  STD_LOGIC; 
		--signal led 			: 	   	  STD_LOGIC_VECTOR( 7 downto 0 ); -- not used

		   -- Clock period definitions
		constant clk_period : integer:= 100000000;

	
begin
		
		hi_muxsel <= '0';

		-- Implement the logic (pretty simple for First).
		--button(3 downto 0) <= "0000";
		--led       <= "00000000";
		--ep20wire  <= ("0000000000000000");
		--ep21wire  <= ("000000000000000" & EW_red);
		--ep21wire(15 downto 0)  <= ("000000" & NS_dontwalk & NS_walk & NS_yellow & NS_green & NS_red & EW_dontwalk & EW_walk & EW_yellow & EW_green & EW_red);
		
		reset <= ep00wire(3);
		night_mode <= ep00wire(0);
		NS_walkrequest <= ep00wire(1);
		EW_walkrequest <= ep00wire(2);
		
			-- Instantiate the okHost and connect endpoints
		okHI : okHost port map (
				hi_in=>hi_in, hi_out=>hi_out, hi_inout=>hi_inout, hi_aa=>hi_aa,
				ti_clk=>ti_clk, ok1=>ok1, ok2=>ok2);

		-- Instantiate the okWireOR module
		okWO : okWireOR     generic map (N=>2) port map (ok2=>ok2, ok2s=>ok2s);

		-- Instantiate endpoints
		--ep00 : okWireIn     	port map (ok1=>ok1,                                  ep_addr=>x"00", ep_dataout=>ep00wire);
		ep00 : okWireIn     	port map (ok1=>ok1,                                  ep_addr=>x"00", ep_dataout=>ep00wire);
		--ep02 : okWireIn     	port map (ok1=>ok1,                                  ep_addr=>x"02", ep_dataout=>ep02wire);
		--ep03 : okWireIn     	port map (ok1=>ok1,                                  ep_addr=>x"03", ep_dataout=>ep03wire);
		--ep20 : okWireOut    	port map (ok1=>ok1, ok2=>ok2s( 1*17-1 downto 0*17 ), ep_addr=>x"20", ep_datain=>ep20wire);
		ep21 : okWireOut    	port map (ok1=>ok1, ok2=>ok2s( 2*17-1 downto 1*17 ), ep_addr=>x"21", ep_datain=>ep21wire);

	uut: traffic_controller_4way generic map (clk_period => clk_period) 
	PORT MAP (
		clk    				=>		clk1,
		reset				=>		reset,
		button 				=>		button,
		led 				=>		led,
		
		EW_red 				=>		ep21wire(0),
		EW_green 			=>		ep21wire(1),
		EW_yellow 			=>		ep21wire(2),
		EW_walk 			=>		ep21wire(3),
		EW_dontwalk 		=>		ep21wire(4),		
		NS_red 				=>		ep21wire(5),
		NS_green 			=>		ep21wire(6),
		NS_yellow 			=>		ep21wire(7),
		NS_walk 			=>		ep21wire(8),
		NS_dontwalk 		=>		ep21wire(9),
		
		night_mode 			=>		night_mode,
		NS_walkrequest 		=>		NS_walkrequest,
		EW_walkrequest 		=>		EW_walkrequest
      );
		
end Behavioral;

