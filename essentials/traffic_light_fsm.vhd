-- CSE 260 Lab 4
-- Finite State Machine Example
-- Sam Powell, powells@seas.wustl.edu
--
-- Module one_traffic_light simulates a single traffic light that starts with all lights off,
--  then switches between "red", "yellow", and "green" lights when button(1) is pressed.
-- It can be reset back to the off state by pressing button(0).
-- It uses a button debouncer from opencores.org that has been slightly modified. See grp_debouncer.vhd

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity traffic_controller_4way is
	--generics are constants that can be set when the entity is instantiated
   -- see the instantiation of grp_debouncer below, and the instantiation of this
	-- module in test_traffic_light_fsm for examples.
	generic (
		clk_period : integer := 100000000
	);
	port(
		clk    				:		 in STD_LOGIC; --100 MHz system clock
		reset				:        in STD_LOGIC; -- trying this out
		button 				:		 in STD_LOGIC_VECTOR( 3 downto 0 );
		led 				: 	     out STD_LOGIC_VECTOR( 7 downto 0 ); -- not used
		night_mode 			:		 in STD_LOGIC; -- Select for flashing yellows
		EW_red 				:		 out STD_LOGIC; -- East/West red light
		EW_green 			:		 out STD_LOGIC; -- East/West green light
		EW_yellow 			:		 out STD_LOGIC; -- East/West yellow light
		EW_walk 			:		 out STD_LOGIC; -- East/West walk signal
		EW_dontwalk 		:		 out STD_LOGIC; -- East/West don't walk 
		EW_walkrequest 		:		 in STD_LOGIC; -- Crosswalk request
		NS_red 				:		 out STD_LOGIC; -- North/South red light
		NS_green 			:		 out STD_LOGIC; -- North/South green light
		NS_yellow 			:		 out STD_LOGIC; -- North/South yellow lightNS_walk : out STD_LOGIC; -- North/South walk signal
		NS_walk 			:		 out STD_LOGIC; -- North/South walk 		
		NS_dontwalk 		:		 out STD_LOGIC; -- North/South don't walk 
		NS_walkrequest 		:		 in STD_LOGIC -- Crosswalk request
	);
	
end traffic_controller_4way;

architecture behavioral of traffic_controller_4way is
	
	
	-- State machine states:
	-- this type definition is a convenient way of listing all of the possible states in our state machine.
	-- the simulator will show these names for the state signals (below) which makes debugging much easier.
	type state_t is (
			EW_green_state,
			EW_yellow_state,
			NS_green_state,
			NS_yellow_state,
			night_mode_yellow,
			night_mode_dark
	  );
	  
	-- State machine register:
	signal state, state_next : state_t;  	-- these signals can take the values defined by state_t above
	signal current_count : integer range 0 to clk_period; -- makes a signal with the appropriate number of bits for the range
	signal next_count : integer range 0 to clk_period;
	signal current_state, next_state : state_t; -- declare states of type state_t
	
	
begin
	
	-- We'll be using the Opal Kelly 100 MHz "clk1" as our system clock:
	--  There are also clk2 and clk3, but using multiple clocks is beyond the scope of this class.
	-- debounce the buttons:
	-- CNT_VAL = DBOUNCE_CLKS means that the button must be stable for DBOUNCE_CLKS clock periods before we register the change.
--	debouncer : grp_debouncer generic map (N => 4, CNT_VAL => DBOUNCE_CLKS)
--		port map (clk_i => clk, data_i => button, data_o => button_db, strb_o => button_st);
	
	-- we'll use the (debounced) button 0 as a reset signal:
	--reset <= reset; -- buttons are active-low, so invert it!
	
	-- we're only going to use the 1st 3 LEDs, so set the rest to off:
	led(7 downto 0) <= (others => '1'); -- assign all bits in vector to '1'
	
	-- Process to define registers' behavior:
	-- Processes have syntax "<name> : process (<sensitivity list>) begin ... end process;"
	-- They are used to define logic in a sequential manner. Processes are similar to a function
	--  in Java or C++, but they are never explicitly called. Rather, every time a signal in
	--  the sensitivity list changes the simulator will run the process to determine what changes happened.
	-- The synthesis tool will generate logic circuits that will produce the same behavior. (Most of the time)
	-- This process is only dependent on the clock, which means it will generate synchronous logic
	--  and we call it a "synchronous process"
	
	
	registers_process : process (clk) begin 
	--figures out the 'state' signal's behavior
		if( rising_edge( clk ) ) then -- old-style: "if(clk'event and clk = '1') then"
			if( reset = '1' ) then
				-- reset all of the registers to their default values:
					state <= EW_green_state;
					current_count <= clk_period; -- reset the count
					--timer <= 0 sec;
			elsif(current_count = 0) then -- change states when the counter hits 0
				report "changing state" severity warning;
				state <= state_next;
				case( state ) is
					when EW_green_state =>
						current_count <= clk_period/2; 
					when EW_yellow_state => 
						current_count <= clk_period; 
					when NS_green_state => 
						current_count <= clk_period/2; 
					when NS_yellow_state => 
						current_count <= clk_period; 
					when night_mode_yellow => 
						current_count <= clk_period/2; 
					when night_mode_dark => 
						current_count <= clk_period/2; 
				end case;
			else
				-- update all of the registers to their next values:
				--state <= state_next;
				--report "updating count" severity warning;
				current_count <= next_count;
			end if; -- reset
		end if; -- rising_edge(clk)
	end process;
	
	
	-- process to compute the next state, given the current state and the inputs
	-- This process is dependent on signals other than the clock, which means it will generate
	--  combinational logic, so we call it a "combinational process"
	next_state_process : process (state, current_count) begin
	
		-- Begin by listing default values for your flip-flop's D inputs (the "next" values)
		-- If you forget to list a default value, the synthesis tool may
		--  infer a latch instead of a flip-flop. This will generally simulate
		--  correctly, but make your design fail when it's on hardware.
		next_count <=current_count;
		state_next <= state; -- by default, remain the same
		
		--make decisions whenever button(1) is pressed:
		--if(state) then
		if (current_count = 0) then
		report "changing state" severity warning;
			if ( night_mode ='0' ) then
				case( state ) is
					when EW_green_state =>
						--if( button_db(1) = '0' ) then
							state_next <= EW_yellow_state;
						--end if;
					when EW_yellow_state => 
						--if( button_db(1) = '0' ) then
							state_next <= NS_green_state;
						--end if;
					when NS_green_state => 
						--if( button_db(1) = '0' ) then
							state_next <= NS_yellow_state;
						--end if;
					when NS_yellow_state => 
						--if( button_db(1) = '0' ) then
							state_next <= EW_green_state;
						--end if;
					when night_mode_yellow => 
						--if( button_db(1) = '0' ) then
							state_next <= EW_green_state;
						--end if;
					when night_mode_dark => 
						--if( button_db(1) = '0' ) then
							state_next <= EW_green_state;
						--end if;
				end case;
			else
				case( state ) is
					when EW_green_state =>
						--if( button_db(1) = '0' ) then
							state_next <= night_mode_dark;
						--end if;
					when EW_yellow_state => 
						--if( button_db(1) = '0' ) then
							state_next <= night_mode_dark;
						--end if;
					when NS_green_state => 
						--if( button_db(1) = '0' ) then
							state_next <= night_mode_dark;
						--end if;
					when NS_yellow_state => 
						--if( button_db(1) = '0' ) then
							state_next <= night_mode_dark;
						--end if;
					when night_mode_yellow => 
						--if( button_db(1) = '0' ) then
							state_next <= night_mode_dark;
						--end if;
					when night_mode_dark => 
						--if( button_db(1) = '0' ) then
							state_next <= night_mode_yellow;
						--end if;
				end case;
			end if; -- button_st = '1'	
			else
				next_count <= (current_count - 1);
				report "decrementing count" severity warning;
		end if; -- current count = 0
		end process;	
		
		-- process to determine outputs from current state: 
		-- This is another combinational process
		output_process : process ( state ) begin
			-- Begin by setting defaults:
			--led(2 downto 0) <= (others => '1'); -- default to off
			-- assign outputs based on current state:
			
			 EW_walk      <= '0';
			 EW_dontwalk  <= '1';
			 NS_walk      <= '0';
			 NS_dontwalk  <= '1';
		 
			 EW_red       <= '0';
			 EW_yellow    <= '0';
			 EW_green     <= '0';
			 NS_red       <= '0';
			 NS_yellow    <= '0';
			 NS_green     <= '0';
	--		 	case( state ) is
	--			 when EW_green_state =>
	--				  EW_green     <= '1';
	--				  --EW_walk 		<= '1';
	--				  --EW_dontwalk  <= '0';
	--				  NS_red       <= '1';
	--			 when EW_yellow_state =>
	--				  EW_yellow    <= '1';
	--				  --EW_walk 		<= '1';
	--				  --EW_dontwalk  <= '0';
	--				  NS_red       <= '1';
	--			 when NS_green_state =>
	--				  NS_green     <= '1';
	--				  EW_red       <= '1';
	--			 when NS_yellow_state =>
	--				  NS_yellow    <= '1';
	--				  EW_red       <= '1';
	--			when night_mode_yellow =>
	--				  --EW_walk 		<= '1';
	--				  --EW_dontwalk  <= '0';
	--				  NS_yellow    <= '1';
	--				  EW_yellow    <= '1';
	--			when night_mode_dark =>
	--				  --EW_walk 		<= '1';
	--				  --EW_dontwalk  <= '0';
	--			 end case;
			if (NS_walkrequest = '0' and EW_walkrequest = '1') then
				 case( state ) is
				 when EW_green_state =>
					  EW_green     <= '1';
					  EW_walk 		<= '1';
					  EW_dontwalk  <= '0';
					  NS_red       <= '1';
				 when EW_yellow_state =>
					  EW_yellow    <= '1';
					  EW_walk 		<= '1';
					  EW_dontwalk  <= '0';
					  NS_red       <= '1';
				 when NS_green_state =>
					  NS_green     <= '1';
					  EW_red       <= '1';
				 when NS_yellow_state =>
					  NS_yellow    <= '1';
					  EW_red       <= '1';
				when night_mode_yellow =>
					  EW_walk 		<= '1';
					  EW_dontwalk  <= '0';
					  NS_yellow    <= '1';
					  EW_yellow    <= '1';
				when night_mode_dark =>
					  EW_walk 		<= '1';
					  EW_dontwalk  <= '0';
				 end case;
			--end if;
			elsif (NS_walkrequest = '1' and EW_walkrequest = '0') then
				 case( state ) is
				 when EW_green_state =>
					  EW_green     <= '1';
					  NS_red       <= '1';
				 when EW_yellow_state =>
					  EW_yellow    <= '1';
					  NS_red       <= '1';
				 when NS_green_state =>
					  NS_green     <= '1';
					  NS_walk 		<= '1';
					  NS_dontwalk  <= '0';
					  EW_red       <= '1';
				 when NS_yellow_state =>
					  NS_yellow    <= '1';
					  NS_walk 		<= '1';
					  NS_dontwalk  <= '0';
					  EW_red       <= '1';
				when night_mode_yellow =>
					  NS_walk 		<= '1';
					  NS_dontwalk  <= '0';
					  NS_yellow    <= '1';
					  EW_yellow    <= '1';
				when night_mode_dark =>
					  NS_walk 		<= '1';
					  NS_dontwalk  <= '0';
				 end case;
			--end if;
			elsif (NS_walkrequest = '1' and EW_walkrequest = '1') then
				 case( state ) is
				 when EW_green_state =>
					  EW_green     <= '1';
					  EW_walk 		<= '1';
					  EW_dontwalk  <= '0';
					  NS_red       <= '1';
				 when EW_yellow_state =>
					  EW_walk 		<= '1';
					  EW_dontwalk  <= '0';
					  EW_yellow    <= '1';
					  NS_red       <= '1';
				 when NS_green_state =>
					  NS_green     <= '1';
					  NS_walk 		<= '1';
					  NS_dontwalk  <= '0';
					  EW_red       <= '1';
				 when NS_yellow_state =>
					  NS_yellow    <= '1';
					  NS_walk 		<= '1';
					  NS_dontwalk  <= '0';
					  EW_red       <= '1';
				when night_mode_yellow =>
					  NS_walk 		<= '1';
					  NS_dontwalk  <= '0';
					  NS_yellow    <= '1';
					  EW_yellow    <= '1';
				when night_mode_dark =>
					  NS_walk 		<= '1';
					  NS_dontwalk  <= '0';
				 end case;
			--end if;
			else --if (NS_walkrequest = '0' and EW_walkrequest = '0') then
				 case( state ) is
				 when EW_green_state =>
					  EW_green     <= '1';
					  NS_red       <= '1';
				 when EW_yellow_state =>
					  EW_yellow    <= '1';
					  NS_red       <= '1';
				 when NS_green_state =>
					  NS_green     <= '1';
					  EW_red       <= '1';
				 when NS_yellow_state =>
					  NS_yellow    <= '1';
					  EW_red       <= '1';
				when night_mode_yellow =>
					  NS_yellow    <= '1';
					  EW_yellow    <= '1';
				when night_mode_dark =>
				end case;		
			end if;
	end process;
	
end behavioral;