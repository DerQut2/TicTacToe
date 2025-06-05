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
		
		-- Wyjscia LED
		LED: out std_logic_vector(3 downto 0);
		
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
	
	component vga_engine is
        Port (
            -- Sygnal zegarowy
            Clock100MHz: in std_logic;
            -- Obecny stan planszy
            game_reg: in GAME_t_Vector;
            -- Obecna pozycja kursora
            cursor_pos: in integer;
            -- Wyjscia VGA
            -- -- Linie koloru
            VGA_R: out std_logic;
            VGA_B: out std_logic;
            VGA_G: out std_logic;
            -- -- Linie synchronizacji
            VGA_HS: out std_logic;
            VGA_VS: out std_logic
        );
    end component vga_engine;
	
	-- Deklaracja sygnalow
	-- -- Przyciski po przejsciu przez debouncer
	signal left_button: std_logic := '0';
	signal right_button: std_logic := '0';
	signal confirm_button: std_logic := '0';
	signal reset_button: std_logic := '0';
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
	signal cursor_pos: integer := 0;
	-- --
	--
	-- -- Obsluga sygnalu reset
	signal reset: std_logic := '0';
	signal reset_counter: unsigned (26 downto 0) := (others => '0');
	
	
	
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
	vga_eng: VGA_ENGINE port map (
        -- Sygnal zegarowy
        Clock100MHz => Clock100MHz,
        -- Obecny stan planszy
        game_reg => game_reg,
        -- Obecna pozycja kursora
        cursor_pos => cursor_pos,
        -- Wyjscia VGA
        -- -- Linie koloru
        VGA_R => VGA_R,
        VGA_B => VGA_B,
        VGA_G => VGA_G,
        -- -- Linie synchronizacji
        VGA_HS => VGA_HS,
        VGA_VS => VGA_VS
    );
	-- --
	--
	-- -- Buzzer
	
	-- --
	--
	
	-- Stworzenie procesow
	--
	-- -- Sekwencyjna obsluga licznika reset (zliczanie do 1 sekundy)
	-- --
	-- -- -- Odczyt:
	-- -- -- -- Clock100MHz: std_logic
	-- -- -- -- reset_button: std_logic
	-- -- -- -- reset_counter: unsigned (26 downto 0)
	-- --
	-- -- -- Zapis:
	-- -- -- -- reset_counter: unsigned (26 downto 0)
	-- --
	SET_RESET_COUNTER: process(Clock100MHz, reset_button, reset_counter)
	begin
		if (rising_edge(Clock100MHz)) then
			if (reset_button = '1') then
				if NOT(reset_counter = "101111101011110000100000000") then
					reset_counter <= reset_counter + 1;
				end if;
			else
				reset_counter <= (others => '0');
			end if;
		end if;
	end process SET_RESET_COUNTER;
	-- --
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
	BUFFER_BUTTONS: process(Clock100MHz, left_button, right_button, confirm_button)
	begin
		if (rising_edge(Clock100MHz)) then
			left_button_buffer <= left_button;
			right_button_buffer <= right_button;
			confirm_button_buffer <= confirm_button;
		end if;
	end process BUFFER_BUTTONS;
	-- --
	--
	-- -- Sekwencyjne ustawienie pozycji kursora
	--
	-- -- -- Odczyt:
	-- -- -- -- Clock100MHz: std_logic
	-- -- -- -- reset: std_logic
	-- -- -- -- left_button_event: std_logic
	-- -- -- -- right_button_event: std_logic
	-- -- -- -- confirm_button_event: std_logic
	-- -- -- -- cursor_pos: integer
	-- --
	-- -- -- Zapis:
	-- -- -- -- cursor_pos: integer
	-- --
	SET_CURSOR_POSITION: process(Clock100MHz, reset, left_button_event, right_button_event, confirm_button_event, cursor_pos)
	begin
		if (reset = '1') then
			cursor_pos <= 0;
		elsif (rising_edge(Clock100MHz)) then
			if (left_button_event = '1') then
				if NOT(cursor_pos = 0) then
					cursor_pos <= cursor_pos - 1;
				end if;
			end if;
			
			if (right_button_event = '1') then
				if NOT(cursor_pos = 8) then
					cursor_pos <= cursor_pos + 1;
				end if;
			end if;
		end if;
	end process SET_CURSOR_POSITION;
	-- --
	--
	-- Wspolbiezne przypisanie wartosci sygnalow
	reset_button <= Button(1);
	reset <= '1' when reset_counter = "101111101011110000100000000" else '0';
	--
	left_button_event <= '1' when (left_button = '1' AND left_button_buffer = '0') else '0';
	right_button_event <= '1' when (right_button = '1' AND right_button_buffer = '0') else '0';
	confirm_button_event <= '1' when (confirm_button = '1' AND confirm_button_buffer = '0') else '0';
	--
	LED(3) <= left_button;
	LED(2) <= right_button;
	LED(1) <= reset;
	LED(0) <= confirm_button;
	--
	Buzzer <= reset;

end top_arch;

