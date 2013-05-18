-- 
-- Create Date:    16:16:52 03/20/2013 
-- Module Name:    timer_fsm - Behavioral 
-- Author: Meenal Kulkarni
-- CSE260M

----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity timer_fsm is

	port(
		clk_t     : in   STD_LOGIC; -- 100 MHz system clock
		reset_t	: in   STD_LOGIC;
		delta	 : out  STD_LOGIC
	);

end timer_fsm;

architecture archi of timer_fsm is
		signal current_count, next_count : integer range 0 to 512; -- makes a signal with the appropriate number of bits for the range
		
		type state_t is (long_state, short_state); -- declare state type
		signal current_state, next_state : state_t; -- declare states of type state_t
begin


registers: process (clk_t) begin
			if(rising_edge(clk_t)) then            
				if(reset_t = '1') then
					current_state <= long_state;
					current_count <= 0; -- reset the count
				else
					current_state <= next_state;
					current_count <= next_count;
				end if;
			end if;
	end process;


next_state_process: process (current_state, current_count) begin 
		-- by default:
		next_state <= current_state; -- don't change state
		case(current_state) is 
			when long_state =>
				if(current_count = 0) then -- change states when the counter hits 0
					next_state <= short_state;
				end if;
			when short_state =>	
				next_state <= long_state; 
		end case;
	end process;

next_count_process: process (current_state, next_state, current_count) begin
		-- by default:
		next_count <= current_count; -- don't change the counter
		if(next_state /= current_state) then -- we're changing states, we should reset the counter
			case(next_state) is --and reset the counter based on what state we're entering
				when long_state =>
					next_count <= 500; -- we'll be in long_state for 14 clock cycles
				when others =>
					next_count <= current_count; -- we don't care about the counter in any other states
			end case;
		elsif(current_count /= 0) then -- we're not changing states, decrement the counter if it's not 0
			next_count <= current_count - 1;
		end if;
		
	end process;

outputs: process (current_state) begin
		-- Begin by setting defaults:
		--led(2 downto 0) <= (others => '1'); -- default to off
		-- assign outputs based on current state:
			case(current_state) is
				when long_state =>
					delta <= '0'; -- turn on an LED
				when short_state =>
					delta <= '1'; -- turn on a different LED
				when others => --do nothing	
			end case;
	end process;
	


end archi;


