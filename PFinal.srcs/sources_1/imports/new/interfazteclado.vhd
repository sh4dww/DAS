----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 19.04.2021 13:54:03
-- Design Name: 
-- Module Name: interfazteclado - Behavioral
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
use IEEE.std_logic_unsigned.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;



entity interfazteclado is
  Port ( PS2CLK, reset : in std_logic; 
         PS2DATA : in std_logic; 
         teclanueva : out std_logic; 
         tecla : out std_logic_vector(7 downto 0);
         clk : in std_logic ); 
end interfazteclado;

architecture Behavioral of interfazteclado is


signal cuenta : std_logic_vector(4 downto 0);
signal codigos : std_logic_vector(21 downto 0);

begin

process(PS2CLK, reset)

begin
if reset = '1' then
    codigos <= (others => '0');
elsif PS2CLK'event and PS2CLK='0' then
    codigos <= PS2DATA & codigos(21 downto 1);
end if;

end process;

process(PS2CLK, reset, clk)
begin
if reset = '1' then
    cuenta <= "00000";
    tecla <= (others => '0'); ----------!!!!!!!!!!
elsif clk'event and clk='1' then

    if PS2CLK = '0' then
        cuenta <= "00000";
    elsif cuenta /= 22 then
        cuenta <= cuenta + 1;
    end if;

    if cuenta = 22 then
        tecla <= codigos(19 downto 12);    
    end if;
end if;
    
end process;

process
begin
if codigos(8 downto 1) = x"F0" then
    teclanueva <= '1';
else
    teclanueva <= '0';
end if;
end process;


end Behavioral;
