----------------------------------------------------------------------------------
-- Autor: 			Marcel Cholodecki
-- Numer albumu: 	275818
-- Projekt:			Gra kolko i krzyzyk
--
-- Modul:			top.vhd
-- Opis:				Glowny plik kodu opisu sprzetu
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

library WORK;
use WORK.my_package.ALL;

entity top is
	Port(
		-- Glowne wejscia plytki rozwojowej
		Clock100MHz: in std_logic;
		Button: in std_logic_vector(3 downto 0);
		
		-- Wyjscie dzwieku (buzzer)
		Buzzer: out std_logic;
		
		-- Wyjscia VGA
		-- -- Linie koloru
		VGA_R: out std_logic;
		VGA_B: out std_logic;
		VGA_G: out std_logic;
		-- -- Linie synchronizacji
		VGA_HS: out std_logic;
		VGA_VS: out std_logic
	);
end top;

architecture top_arch of top is
	
	-- Deklaracja komponentow
	-- -- DEBOUNCER
	component DEBOUNCER is
		Port(
			-- Wejscie zegarowe
			Clock100MHz: in std_logic;
			
			-- Wejscie przycisku do obslugi
			button_in: in std_logic;
			
			-- Wyjscie obsluzonego przycisku
			button_out: out std_logic
		);
	end component;
	
	-- Deklaracja sygnalow
	-- -- Przyciski po przejsciu przez debouncer
	signal left_button: std_logic := '0';
	signal right_button: std_logic := '0';
	signal confirm_button: std_logic := '0';
	
	
begin
	-- Stworzenie komponentow
	-- -- DEBOUNCER
	left_debouncer: DEBOUNCER port map (Clock100MHz => Clock100MHz, button_in => Button(3), button_out => left_button);
	right_debouncer: DEBOUNCER port map (Clock100MHz => Clock100MHz, button_in => Button(2), button_out => right_button);
	confirm_debouncer: DEBOUNCER port map (Clock100MHz => Clock100MHz, button_in => Button(0), button_out => confirm_button);



end top_arch;

