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
	signal cursor_pos: unsigned (3 downto 0) := (others => '0');
	-- --
	--
	-- -- Obsluga sygnalu reset
	signal reset: std_logic := '0';
	signal reset_counter: unsigned (26 downto 0) := (others => '0');
	
	-- Skopiowany kod
	signal clk50: std_logic := '0';
	signal clk25: std_logic := '0';
	signal hs : unsigned (9 downto 0);
	signal vs : unsigned (9 downto 0);
	signal hs_out: std_logic := '0';
	signal vs_out: std_logic := '0';
	signal red: std_logic := '0';
	signal blue: std_logic := '0';
	signal green: std_logic := '0';
	
	
	
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
	-- -- -- -- cursor_pos: unsigned (3 downto 0)
	-- --
	-- -- -- Zapis:
	-- -- -- -- cursor_pos: unsigned (3 downto 0)
	-- --
	SET_CURSOR_POSITION: process(Clock100MHz, reset, left_button_event, right_button_event, confirm_button_event, cursor_pos)
	begin
		if (reset = '1') then
			cursor_pos <= "0000";
		elsif (rising_edge(Clock100MHz)) then
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
	LED(0) <= left_button;
	LED(1) <= right_button;
	LED(2) <= reset_button;
	LED(3) <= confirm_button;
	--
	Buzzer <= reset;
	
	-- generate a 50Mhz clock
 
	process (Clock100MHz)
	 
	begin
	 
		if Clock100MHz'event and Clock100MHz='1' then
		 
		if (clk50 = '0') then             
		 
		clk50 <= '1';
		 
		else
		 
		clk50 <= '0';
		 
		end if;
		 
		end if;
	 
	end process;
	
	process (clk50)
	 
	begin
	 
		if clk50'event and clk50='1' then
		 
		if (clk25 = '0') then             
		 
		clk25 <= '1';
		 
		else
		 
		clk25 <= '0';
		 
		end if;
		 
		end if;
	 
	end process;
	
	process (clk25)
 
	begin
 
		if clk25'event and clk25 = '1' then
		 
		if hs = "0011001000" and vs >= "0011001000" and vs <= "0011111010" then ---horizantal and vertical line display constraint
		 
		red <= '1' ;
		 
		blue <= '0';
		 
		green <= '0' ;
		 
		elsif hs = "0011001000" and vs >= "0100101100" and vs <= "0101000101" then
		 
		red <= '1' ;
		 
		blue <= '0';
		 
		green <= '0' ;
		 
		elsif hs = "0011111010" and vs >= "0011001000" and vs <= "0011100001" then
		 
		red <= '1' ;
		 
		blue <= '0';
		 
		green <= '0' ;
		 
		elsif hs = "0011111010" and vs >= "0101000101" and vs <= "0101011110" then
		 
		red <= '1' ;
		 
		blue <= '0';
		 
		green <= '0' ;
		 
		elsif hs = "0100000100" and vs >= "0011001000" and vs <= "0011111010" then
		 
		red <= '1' ;
		 
		blue <= '0';
		 
		green <= '0' ;
		 
		elsif hs = "0100000100" and vs >= "0100101100" and vs <= "0101011110" then
		 
		red <= '1' ;
		 
		blue <= '0';
		 
		green <= '0' ;
		 
		elsif hs = "0100110110" and vs >= "0011001000" and vs <= "0011111010" then
		 
		red <= '1' ;
		 
		blue <= '0';
		 
		green <= '0' ;
		 
		elsif hs = "0100110110" and vs >= "0100101100" and vs <= "0101011110" then
		 
		red <= '1' ;
		 
		blue <= '0';
		 
		green <= '0' ;
		 
		elsif hs = "0101000000" and vs >= "0011001000" and vs <= "0011111010" then
		 
		red <= '1' ;
		 
		blue <= '0';
		 
		green <= '0' ;
		 
		elsif hs = "0101000000" and vs >= "0100101100" and vs <= "0101011110" then
		 
		red <= '1' ;
		 
		blue <= '0';
		 
		green <= '0' ;
		 
		elsif hs = "0101110010" and vs >= "0011001000" and vs <= "0011111010" then
		 
		red <= '1' ;
		 
		blue <= '0';
		 
		green <= '0' ;
		 
		elsif hs = "0101111110" and vs >= "0100101100" and vs <= "0101011110" then
		 
		red <= '1' ;
		 
		blue <= '0';
		 
		green <= '0' ;
		 
		elsif hs = "0110101110" and vs >= "0100101100" and vs <= "0101011110" then
		 
		red <= '1' ;
		 
		blue <= '0';
		 
		green <= '0' ;
		 
		elsif hs = "0110010101" and vs >= "0011001000" and vs <= "0011111010" then
		 
		red <= '1' ;
		 
		blue <= '0';
		 
		green <= '0' ;
		 
		elsif hs = "0110111000" and vs >= "0011001000" and vs <= "0011111010" then
		 
		red <= '1' ;
		 
		blue <= '0';
		 
		green <= '0' ;
		 
		elsif hs = "0111010001" and vs >= "0100101100" and vs <= "0101011110" then
		 
		red <= '1' ;
		 
		blue <= '0';
		 
		green <= '0' ;
		 
		elsif hs = "0111110100" and vs >= "0011001000" and vs <= "0011111010" then
		 
		red <= '1' ;
		 
		blue <= '0';
		 
		green <= '0' ;
		 
		elsif hs = "1000001101" and vs >= "0100101100" and vs <= "0101011110" then
		 
		red <= '1' ;
		 
		blue <= '0';
		 
		green <= '0' ;
		 
		elsif hs = "1000110000" and vs >= "0011001000" and vs <= "0011111010" then
		 
		red <= '1' ;
		 
		blue <= '0';
		 
		green <= '0' ;
		 
		elsif hs = "1001100010" and vs >= "0011001000" and vs <= "0011111010" then
		 
		red <= '1' ;
		 
		blue <= '0';
		 
		green <= '0' ;
		 
		elsif hs = "1000110000" and vs >= "0100101100" and vs <= "0101011110" then
		 
		red <= '1' ;
		 
		blue <= '0';
		 
		green <= '0' ;
		 
		elsif hs = "1001100010" and vs >= "0100101100" and vs <= "0101011110" then
		 
		red <= '1' ;
		 
		blue <= '0';
		 
		green <= '0' ;
		 
		elsif hs = "1001101100" and vs >= "0100101100" and vs <= "0101011110" then
		 
		red <= '1' ;
		 
		blue <= '0';
		 
		green <= '0' ;
		 
		elsif hs = "1010011110" and vs >= "0100101100" and vs <= "0101011110" then
		 
		red <= '1' ;
		 
		blue <= '0';
		 
		green <= '0' ;
		 
		--------------------------------------------------------------------------------
		 
		else                     ----------blank signal display
		 
		red <= '0' ;
		 
		blue <= '0';
		 
		green <= '0' ;
		 
		end if;
		 
		if (hs > "0000000000" )
		 
		and (hs < "0001100001" ) -- 96+1   -----horizontal tracing
		 
		then
		 
		hs_out <= '0';
		 
		else
		 
		hs_out <= '1';
		 
		end if;
		 
		if (vs > "0000000000" )
		 
		and (vs < "0000000011" ) -- 2+1   ------vertical tracing
		 
		then
		 
		vs_out <= '0';
		 
		else
		 
		vs_out <= '1';
		 
		end if;
		 
		hs <= hs + 1 ;
		 
		if (hs= "1100100000") then     ----incremental of horizontal line
		 
		vs <= vs + 1;       ----incremental of vertical line
		 
		hs <= "0000000000";
		 
		end if;
		 
		if (vs= "1000001001") then                
		 
		vs <= "0000000000";
		 
		end if;
		 
		end if;
		 
		end process;
		
		VGA_R <= red;
		VGA_B <= blue;
		VGA_G <= green;
		-- -- Linie synchronizacji
		VGA_HS <= hs_out;
		VGA_VS <= vs_out;
	
	
	



end top_arch;

