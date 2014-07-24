----------------------------------------------------------------------------------
-- Company: 			Engs 31 14X
-- Engineer: 			Eric Hansen
-- 
-- Create Date:    	 
-- Design Name: 		
-- Module Name:    		lab4_shell 
-- Project Name: 		Lab4
-- Target Devices: 		Digilent NEXYS3 (Spartan 6)
-- Tool versions: 		ISE Design Suite 14.4
-- Description: 		Stopwatch lab
--				
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
-- Boilerplate: don't change this
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;		-- needed for arithmetic

library UNISIM;					-- needed for the BUFG component
use UNISIM.Vcomponents.ALL;


-- Entity block
-- Change the name of the entity from Lab4_shell to something more descriptive,
-- like Lab4_Stopwatch.

entity Stopwatch is
port (clk		: in std_logic;
	-- control inputs
		button 	: in std_logic;
	--	
	-- multiplexed seven segment display
      segments	: out std_logic_vector(6 downto 0);
      anodes 	: out std_logic_vector(3 downto 0) );
end Stopwatch; 

architecture Behavioral of Stopwatch is

-- COMPONENT DECLARATIONS
-- Multiplexed seven segment display
signal tie_low: std_logic;
component mux7seg is
    Port ( 	clk : in  STD_LOGIC;
           	y0, y1, y2, y3 : in  STD_LOGIC_VECTOR (3 downto 0);
	   	 	bi : in  STD_LOGIC;							
           	seg : out  STD_LOGIC_VECTOR (0 to 6);	
           	an : out  STD_LOGIC_VECTOR (3 downto 0) );			
end component;

-- Debouncer
component debounce is
    Port ( clk 	: in  STD_LOGIC;
           switch 	: in  STD_LOGIC;		-- switch input
           dbswitch : out STD_LOGIC );		-- debounced output
end component;

-- Your component declarations go here


-------------------------------------------------
-- SIGNAL DECLARATIONS 
-- Signals for the clock divider, which divides the 100 MHz clock down to 10 MHz
constant CLOCK_DIVIDER_VALUE: integer := 5;
signal clkdiv: integer := 0;			-- the clock divider counter
signal clk_en: std_logic := '0';		-- terminal count
signal clk10: std_logic;				-- the slower clock

signal button_db : std_logic := '0';	-- debounced button

-- Signal declarations for your code go here

begin
-- Clock buffer for 10 MHz clock
-- The BUFG component puts the slow clock onto the FPGA clocking network
Slow_clock_buffer: BUFG
      port map (I => clk_en,
                O => clk10 );

-- Divide the 100 MHz clock down to 20 MHz, then toggling the 
-- clk_en signal at 20 MHz gives a 10 MHz clock with 50% duty cycle
Clock_divider: process(clk)
begin
	if rising_edge(clk) then
	   	if clkdiv = CLOCK_DIVIDER_VALUE-1 then 
	   		clk_en <= NOT(clk_en);		
			clkdiv <= 0;
		else
			clkdiv <= clkdiv + 1;
		end if;
	end if;
end process Clock_divider;

-- Instantiate the debouncer
debouncer: debounce
    Port map ( clk => clk10,	-- runs off the slow clock
           switch => button,
           dbswitch => button_db );		

-- Instantiate the multiplexed seven segment display
tie_low <= '0';
display: mux7seg
    Port Map ( clk => clk ,	-- runs off the fast master clock
           	y3 => "1000"  ,	-- most significant digit
           	y2 => "0100" ,		-- 	replace these inputs with 
           	y1 => "0010"  ,	-- 	actual signal names
           	y0 => "0001" ,		-- least significant digit
	   		bi => tie_low,						
           	seg => segments,
           	an => anodes );	

--------------------------------------------
-- Your logic goes here
-- Clock your system with the clk10 signal
-- Use 100 Hz slow enable signal to make the counters go at the right speed


		
end Behavioral; 