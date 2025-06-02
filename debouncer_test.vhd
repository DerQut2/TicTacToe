----------------------------------------------------------------------------------
-- Autor: 			Marcel Cholodecki
-- Numer albumu: 	275818
-- Projekt:			Gra kolko i krzyzyk
--
-- Modul:			debouncer_test.vhd
-- Opis:				Testbench debouncera do obslugi przycisku
----------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
ENTITY debouncer_test IS
END debouncer_test;
 
ARCHITECTURE behavior OF debouncer_test IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT debouncer
    PORT(
         Clock100MHz : IN  std_logic;
         button_in : IN  std_logic;
         button_out : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal Clock100MHz : std_logic := '0';
   signal button_in : std_logic := '0';

 	--Outputs
   signal button_out : std_logic;

   -- Clock period definitions
   constant Clock100MHz_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: debouncer PORT MAP (
          Clock100MHz => Clock100MHz,
          button_in => button_in,
          button_out => button_out
        );

   -- Clock process definitions
   Clock100MHz_process :process
   begin
		Clock100MHz <= '0';
		wait for Clock100MHz_period/2;
		Clock100MHz <= '1';
		wait for Clock100MHz_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin	
		
		wait for 10 ms;
		button_in <= '1';
		wait for 5 ms;
		button_in <= '0';
		
		wait for 50 ms;
		button_in <= '1';
		wait for 200 ms;
		button_in <= '0';
		
		wait for 2100 ms;

      assert false severity failure;
   end process;

END;
