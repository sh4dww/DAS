----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11.04.2021 01:48:51
-- Design Name: 
-- Module Name: divisorfrecuencia - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity divisorfrecuenciabarra is
  Port ( reset : in std_logic;
         clkFPGA : in std_logic;
         salida : out std_logic);
end divisorfrecuenciabarra;

architecture Behavioral of divisorfrecuenciabarra is
    
    signal clk1hz : std_logic;
    signal cuenta : std_logic_vector(2 downto 0);
    
begin
  process(reset, clkFPGA)
        begin
        if reset = '1' then
            cuenta <=  (others => '0');
            clk1hz <= '0';
        elsif rising_edge(clkFPGA) then
            if cuenta = 7 then
                cuenta <= (others => '0');
                clk1hz <= not (clk1hz);
            else
                cuenta <= cuenta + 1;
            end if;
        
        end if;  
        
  end process;
salida <= clk1hz;
    
end Behavioral;
