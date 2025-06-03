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
	-- --
	--
	-- -- Zegarowy bufor przyciskow (w celu wykrycia zdarzen)
	signal left_button_buffer: std_logic := '0';
	signal right_button_buffer: std_logic := '0';
	signal confirm_button_buffer: std_logic := '0';
	-- --
	--
	-- -- Flagi zdarzen przyciskow
	signal left_button_event: std_logic := '0';
	signal right_button_event: std_logic := '0';
	signal confirm_button_event: std_logic := '0';
	-- --
	--
	-- -- Aktualna tura oraz stan planszy
	signal game_turn: GAME_t := 'X';
	signal game_reg: GAME_t_Vector := "---------";
	-- --
	--
	-- -- Aktualna pozycja kursora
	signal cursor_pos: unsigned (3 downto 0) := (others => '0');
	
	
	
begin
	-- Stworzenie komponentow
	--
	-- -- DEBOUNCER
	left_debouncer: DEBOUNCER port map (Clock100MHz => Clock100MHz, button_in => Button(3), button_out => left_button);
	right_debouncer: DEBOUNCER port map (Clock100MHz => Clock100MHz, button_in => Button(2), button_out => right_button);
	confirm_debouncer: DEBOUNCER port map (Clock100MHz => Clock100MHz, button_in => Button(0), button_out => confirm_button);
	-- --
	--
	-- -- VGA
	
	-- --
	--
	-- -- Buzzer
	
	-- --
	--
	
	-- Stworzenie procesow
	--
	-- -- Sekwencyjne buforowanie przyciskow
	-- --
	-- -- -- Odczyt:
	-- -- -- -- Clock100MHz: std_logic
	-- -- -- -- left_button: std_logic
	-- -- -- -- right_button: std_logic
	-- -- -- -- confirm_button: std_logic
	-- --
	-- -- -- Zapis:
	-- -- -- -- left_button_buffer: std_logic
	-- -- -- -- right_button_buffer: std_logic
	-- -- -- -- confirm_button_buffer: std_logic
	-- --
	BUUFER_BUTTONS: process(Clock100MHz, left_button, right_button, confirm_button)
	begin
		if (falling_edge(Clock100MHz)) then
			left_button_buffer <= left_button;
			right_button_buffer <= right_button;
			confirm_button_buffer <= confirm_button;
		end if;
	end process BUFFER_BUTTONS;
	-- --
	--
	-- -- Kombinacyjne ustawienie flag zdarzen przyciskow
	--
	-- -- -- Odczyt:
	-- -- -- -- left_button: std_logic
	-- -- -- -- right_button: std_logic
	-- -- -- -- confirm_button: std_logic
	-- -- -- -- left_button_buffer: std_logic
	-- -- -- -- right_button_buffer: std_logic
	-- -- -- -- confirm_button_buffer: std_logic
	-- -- -- --
	-- --
	-- -- -- Zapis:
	-- -- -- -- left_button_event: std_logic
	-- -- -- -- right_button_event: std_logic
	-- -- -- -- confirm_button_event: std_logic
	-- --
	SET_BUTTON_EVENT_FLAGS: process(left_button, right_button, confirm_button, left_button_buffer, right_button_buffer, confirm_button_buffer)
	begin
		left_button_event <= '1' when (left_button = '1' AND left_button_buffer = '0') else '0';
		right_button_event <= '1' when (right_button = '1' AND right_button_buffer = '0') else '0';
		confirm_button_event <= '1' when (confirm_button = '1' AND confirm_button_buffer = '0') else '0';
	end process SET_BUTTON_EVENT_FLAGS;
	-- --
	--
	-- -- Sekwencyjne ustawienie pozycji kursora
	--
	-- -- -- Odczyt:
	-- -- -- -- Clock100MHz: std_logic
	-- -- -- -- left_button_event: std_logic
	-- -- -- -- right_button_event: std_logic
	-- -- -- -- confirm_button_event: std_logic
	-- -- -- -- cursor_pos: unsigned (3 downto 0)
	-- --
	-- -- -- Zapis:
	-- -- -- -- cursor_pos: unsigned (3 downto 0)
	-- --
	SET_CURSOR_POSITION: process(Clock100MHz, left_button_event, right_button_event, confirm_button_event, cursor_pos)
	begin
		if (rising_edge(Clock100MHz)) then
			if (left_button_event = '1') then
				if NOT(cursor_pos = "0000") then
					cursor_pos <= cursor_pos - 1;
				end if;
			end if;
			
			if (right_button_event = '1') then
				if NOT(cursor_pos = "1000") then
					cursor_pos <= cursor_pos + 1;
				end if;
			end if;
		end if;
	end process SET_CURSOR_POSITION;
	



end top_arch;

