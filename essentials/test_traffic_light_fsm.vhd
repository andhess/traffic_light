--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY test_traffic_controller_4way IS
END test_traffic_controller_4way;
 
ARCHITECTURE behavior OF test_traffic_controller_4way IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT traffic_controller_4way is
	generic (
		clk_period : integer := 100000000
	);
    PORT(
		clk   			:		 in STD_LOGIC;
		reset				:      in STD_LOGIC; 
		button 			:		 in STD_LOGIC_VECTOR( 3 downto 0 );
		led 				: 	    out STD_LOGIC_VECTOR( 7 downto 0 ); -- not used
		night_mode 		:		 in STD_LOGIC; 
		EW_red 			:		 out STD_LOGIC;
		EW_green 		:		 out STD_LOGIC; 
		EW_yellow 		:		 out STD_LOGIC;
		EW_walk 			:		 out STD_LOGIC;
		EW_dontwalk 	:		 out STD_LOGIC;
		EW_walkrequest :		 in STD_LOGIC;
		NS_red 			:		 out STD_LOGIC;
		NS_green 		:		 out STD_LOGIC;
		NS_yellow 		:		 out STD_LOGIC;
		NS_walk 			:		 out STD_LOGIC; 
		NS_dontwalk 	:		 out STD_LOGIC; 
		NS_walkrequest :		 in STD_LOGIC
      );
    END COMPONENT;

   --Inputs
   signal clk 				 : 	std_logic := '0';
   signal button 			 : 	std_logic_vector(3 downto 0) := (others => '0');
	signal reset		    :    STD_LOGIC; 
	signal night_mode 	 :		STD_LOGIC;
	signal EW_walkrequest :		STD_LOGIC;
	signal NS_walkrequest :		STD_LOGIC;

 	--Outputs
   signal led 				: std_logic_vector(7 downto 0);
	signal NS_red 			:	 	STD_LOGIC;
	signal NS_green 		:		STD_LOGIC;
	signal NS_yellow 		:		STD_LOGIC;
	signal NS_walk 		:		STD_LOGIC; 
	signal NS_dontwalk 	:		STD_LOGIC;
	signal EW_red 			:		STD_LOGIC;
	signal EW_green 		:		STD_LOGIC; 
	signal EW_yellow 		:		STD_LOGIC;
	signal EW_walk 		:		STD_LOGIC;
	signal EW_dontwalk 	:		STD_LOGIC;

   -- Clock period definitions
   constant clk_period : integer:= 5000;
 
	-- Parameter for the button debouncer:
	constant dbounce_clks : positive := 5;
	
	-- How long in time we need to wait for the debouncer output to change:
	--constant dbounce_period : time := clk_period*(dbounce_clks + 3);
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: traffic_controller_4way generic map (clk_period => clk_period) 
	PORT MAP (
		clk   			=>		clk,
		reset				=>		reset,
		button 			=>		button,
		led 				=>		led,
		night_mode 		=>		night_mode,
		EW_red 			=>		EW_red,
		EW_green 		=>		EW_green,
		EW_yellow 		=>		EW_yellow,
		EW_walk 			=>		EW_walk,
		EW_dontwalk 	=>		EW_dontwalk,
		EW_walkrequest =>		EW_walkrequest,
		NS_red 			=>		NS_red,
		NS_green 		=>		NS_green,
		NS_yellow 		=>		NS_yellow,
		NS_walk 			=>		NS_walk,
		NS_dontwalk 	=>		NS_dontwalk,
		NS_walkrequest =>		NS_walkrequest
      );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for 100 ns ;
		clk <= '1';
		wait for 100 ns;
   end process;
 

   -- Stimulus process
   stimulus_proc: process
   begin
	
	     reset <= '1';
        night_mode <= '0';
        EW_walkrequest <= '0';
        NS_walkrequest <= '0';
 
        wait for 200 ns;
        reset <= '0';
        wait for 10000000 ns;
        --report "Simulation Finished" severity failure;
--			wait
--		--nothing pressed, to start:
--		button <= "1111";
--
--      wait for dbounce_period;
--		
--		--press reset button:
--      button(0) <= '0';
--		
--		--wait until debouncer register's the button changes, then 1 more clock cycle for the state machine to update
--		wait for dbounce_period + clk_period;
--		
--		--make sure LEDs are all off:
--		-- the assert command checks a condition: if it is *false* it will report a message with a particular severity.
--		--  possible severities include: note, warning, error, failure
--		--  only failures will make the simulation stop.
--		assert led(2 downto 0) = b"111" report "Lights didn't reset" severity error; -- i.e. if led(2 downto 0) is not 111, report the error message and keep simulating
--		
--		--release reset button:
--		button(0) <= '1';
--		
--		wait for dbounce_period;
--		
--		--press state-change button
--		button(1) <= '0';
--		
--		wait for dbounce_period + clk_period;
--		
--		--only red light should be on:
--		assert led(2 downto 0) = b"011" report "Red light didn't turn on" severity error;
--		
--		--release button
--		button(1) <= '1';
--		
--		wait for dbounce_period;
--		
--		button(1) <= '0';
--		
--		wait for dbounce_period + clk_period;
--		
--		--only green light should be on:
--		assert led(2 downto 0) = b"110" report "Green light didn't turn on" severity error;
--		
--		button(1) <= '1';
--		
--		wait for dbounce_period;
--		
--		button(1) <= '0';
--		
--		wait for dbounce_period + clk_period;
--		
--		-- yellow light:
--		assert led(2 downto 0) = b"101" report "Yellow light didn't turn on" severity error;
--		
--		button(1) <= '1';
--		
--		wait for dbounce_period;
--		
--		button(1) <= '0';
--		
--		wait for dbounce_period + clk_period;
--		
--		--red again:
--		assert led(2 downto 0) = b"011" report "Red light didn't turn on (second time)" severity error;
--		
--		--reset this time:
--		button(0) <= '0';
--		
--		wait for dbounce_period + clk_period;
--		
--		--everything should be off again:
--		assert led(2 downto 0)  = b"111" report "Failed to reset" severity error;
--		
--		wait for clk_period*10;
--		
--		-- we can't just use "wait;" because the clock process (lines 81-87) will keep the simulator
--		--  running. Instead we report a "failure" message which will end the simulation:
		report "Simulation Finished" severity failure;
	end process;

END;
