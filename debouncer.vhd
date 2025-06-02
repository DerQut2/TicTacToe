----------------------------------------------------------------------------------
-- Autor: 			Marcel Cholodecki
-- Numer albumu: 	275818
-- Projekt:			Gra kolko i krzyzyk
--
-- Modul:			debouncer.vhd
-- Opis:				Debouncer do obslugi przyciskow
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.NUMERIC_STD.ALL;


entity debouncer is
	Port(
		-- Wejscie zegarowe
		Clock100MHz: in std_logic;
		
		-- Wejscie przycisku do obslugi
		button_in: in std_logic;
		
		-- Wyjscie obsluzonego przycisku
		button_out: out std_logic
	);
end debouncer;

architecture debouncer_arch of debouncer is

	-- Stany maszyny stanow
	type STANY_t is (STABILNY, NIESTABILNY, CZEKAJ);
	signal stan: STANY_t := STABILNY;
	signal stan_next: STANY_t := STABILNY;
	
	-- Glowny licznik
	signal DebounceCounter: unsigned (26 downto 0) := "000000000000000000000000000";
	
begin
	
	-- Sekwencyjne ustalanie wartosci obecnego stanu maszyny oraz glownego licznika
	--
	-- -- Odczyt:
	-- -- -- Clock100MHz: std_logic
	-- -- -- button_in: std_logic
	-- -- -- stan_next: STANY_t
	-- -- -- stan: STANY_t
	--
	-- -- Zapis:
	-- -- -- DebounceCounter: std_logic_vector (26 downto 0)
	-- -- -- stan: STANY_t
	--
	SEQ: process(Clock100MHz, button_in, stan, stan_next)
	begin
		if (rising_edge(Clock100MHz)) then
			stan <= stan_next;
			DebounceCounter <= DebounceCounter + 1;

			case stan is
			when STABILNY =>
				if (button_in = '1' OR button_in = 'H') then
					DebounceCounter <= "000000000000000000000000000";
				end if;

			when CZEKAJ =>
				if (DebounceCounter = "000000111101000010010000000") then
					DebounceCounter <= "000000000000000000000000000";
				end if;
				
			when NIESTABILNY =>
				if (DebounceCounter = "101111101011110000100000000") then
					DebounceCounter <= "000000000000000000000000000";
				end if;
				
			end case;
		end if;
	end process SEQ;
	
	-- Kombinacyjne ustalanie przyszlego stanu maszyny
	--
	-- -- Odczyt:
	-- -- -- stan: STANY_t
	-- -- -- DebounceCounter: std_logic_vector (26 downto 0)
	-- -- -- button_in: std_logic
	--
	-- -- Zapis:
	-- -- -- stan_next: STANY_t
	--
	COMB: process(stan, button_in, DebounceCounter)
	begin
		stan_next <= stan;
		case stan is
			when STABILNY =>
				if  (button_in = '1' OR button_in = 'H') then
					stan_next <= CZEKAJ;
				end if;

			when CZEKAJ =>
				if (DebounceCounter = "000000111101000010010000000") then
					if (button_in = '1' OR button_in = 'H') then
						stan_next <= NIESTABILNY;
					else
						stan_next <= STABILNY;
					end if;
				end if;

			when NIESTABILNY =>
				if (DebounceCounter = "101111101011110000100000000") then
					stan_next <= STABILNY;
				end if;
				
			end case;
	end process COMB;
	
	-- Przypisanie wartosci do wyjscia
	button_out <= '1' when (button_in = '1' OR stan = NIESTABILNY) else '0';


end debouncer_arch;

