----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 17.05.2021 14:46:24
-- Design Name: 
-- Module Name: testpfinal - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity testpfinal is
--  Port ( );
end testpfinal;

architecture Behavioral of testpfinal is
component vgacore is
	port
	(
		reset: in std_logic;	
		clk_in: in std_logic;
		hsyncb: buffer std_logic;	
		vsyncb: out std_logic;	
		rgb: out std_logic_vector(11 downto 0);
		PS2CLK: in std_logic; 
        PS2DATA : in std_logic;
        teclapulsada : buffer std_logic_vector(7 downto 0)
	);
end component;

signal x, y, z, clock, data : std_logic;
signal vs : std_logic;
signal rgbvga : std_logic_vector(11 downto 0);
signal tp : std_logic_vector(7 downto 0);

begin


vc : vgacore port map(z, x, y, vs, rgbvga, clock, data, tp);


reset : process
begin
z <= '1';
wait for 40 ns;
z <= '0';
wait;
end process;

reloj: process
begin
x <='0';
wait for 30 ns;
x <='1';
wait for 30 ns;
x <='0';
wait for 30 ns;
x <='1';
wait for 30 ns;
x <='0';
wait for 30 ns;
x <='1';
wait for 30 ns;
x <='0';
wait for 30 ns;
x <='1';
wait for 30 ns;
x <='0';
wait for 30 ns;
x <='1';
end process;

end Behavioral;
