library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity vgacore is
	port
	(
		reset: in std_logic;	
		clk_in: in std_logic;
		hsyncb: buffer std_logic;	
		vsyncb: out std_logic;	
		rgb: out std_logic_vector(11 downto 0);
		PS2CLK: in std_logic; 
        PS2DATA : in std_logic;
        --tecla_pulsada : buffer std_logic_vector(7 downto 0);
	--estado_actual : out std_logic_vector(2 downto 0);
	   seg : out std_logic_vector(6 downto 0)
	   --reb  : out std_logic
	);
end vgacore;

architecture vgacore_arch of vgacore is

component divisorfrecuencia is
  Port ( reset : in std_logic;
         clkFPGA : in std_logic;
         salida : out std_logic);
end component;

component interfazteclado is
  Port ( PS2CLK, reset : in std_logic; 
         PS2DATA : in std_logic; 
         teclanueva : out std_logic; 
         tecla : out std_logic_vector(7 downto 0);
         clk : in std_logic ); 
end component;

component divisorfrecuenciabarra is
  Port ( reset : in std_logic;
         clkFPGA : in std_logic;
         salida : out std_logic);
end component;

component divisorfrecuenciapelota is
  Port ( reset : in std_logic;
         clkFPGA : in std_logic;
         salida : out std_logic);
end component;

signal hcnt: std_logic_vector(8 downto 0);	
signal vcnt: std_logic_vector(9 downto 0);	

signal clock: std_logic;  --este es el pixel_clock

signal teclapulsada : std_logic_vector(7 downto 0);

signal CLK_BARRA : std_logic;
signal CLK_PELOTA : std_logic;
 
type ESTADOS_BARRA is (S0, S1, S2);
signal ESTADO_BARRA, SIG_ESTADO_BARRA: ESTADOS_BARRA; 

 
type ESTADOS_PELOTA is (E0, E1, E2, E3, E4, E5, E6, E7);
signal ESTADO_PELOTA, SIG_ESTADO_PELOTA: ESTADOS_PELOTA; 

constant N : std_logic_vector(8 downto 0) := "000000101"; --cambio posicion barra
constant M : std_logic_vector(8 downto 0) := "000000010"; --cambio posicion pelota
constant P : std_logic_vector(9 downto 0) := "0000000010";
signal px : std_logic_vector(8 downto 0) := "010001100"; --posicion barra
signal px_pelota : std_logic_vector(8 downto 0); --posicion pelota
signal py_pelota : std_logic_vector(9 downto 0); --posicion pelota

signal display_barra, display_marco, display_pelota : std_logic;

signal reset_teclado : std_logic;

signal tn : std_logic;

signal rebotes : std_logic_vector(2 downto 0);

signal rebote : std_logic;

begin

reloj: divisorfrecuencia port map(reset => reset, clkFPGA => clk_in, salida => clock); --instancia del divisor de frecuencia para el reloj de pixel (clock)
teclado : interfazteclado port map(PS2CLK => PS2CLK, reset => reset_teclado, PS2DATA => PS2DATA, teclanueva => tn, tecla => teclapulsada, clk => clk_in); --instacia del interfaz de teclado
reloj_barra : divisorfrecuenciabarra port map(reset => reset, clkFPGA => clk_in, salida => CLK_BARRA); --instacia del reloj de la barra
reloj_pelota : divisorfrecuenciapelota port map(reset => reset, clkFPGA => clk_in, salida => CLK_PELOTA); --instancia del reloj de la pelota

A: process(clock,reset)
begin
	-- reset asynchronously clears pixel counter
	if reset='1' then
		hcnt <= "000000000";
	-- horiz. pixel counter increments on rising edge of dot clock
	elsif (clock'event and clock='1') then
		-- horiz. pixel counter rolls-over after 381 pixels
		if hcnt<380 then
			hcnt <= hcnt + 1;
		else
			hcnt <= "000000000";
		end if;
	end if;
end process;


B: process(hsyncb,reset)
begin
	-- reset asynchronously clears line counter
	if reset='1' then
		vcnt <= "0000000000";
	-- vert. line counter increments after every horiz. line
	elsif (hsyncb'event and hsyncb='1') then
		-- vert. line counter rolls-over after 528 lines
		if vcnt<527 then
			vcnt <= vcnt + 1;
		else
			vcnt <= "0000000000";
		end if;
	end if;
end process;


C: process(clock,reset)
begin
	-- reset asynchronously sets horizontal sync to inactive
	if reset='1' then
		hsyncb <= '1';
	-- horizontal sync is recomputed on the rising edge of every dot clock
	elsif (clock'event and clock='1') then
		-- horiz. sync is low in this interval to signal start of a new line
		if (hcnt>=291 and hcnt<337) then
			hsyncb <= '0';
		else
			hsyncb <= '1';
		end if;
	end if;
end process;

D: process(hsyncb,reset)
begin
	-- reset asynchronously sets vertical sync to inactive
	if reset='1' then
		vsyncb <= '1';
	-- vertical sync is recomputed at the end of every line of pixels
	elsif (hsyncb'event and hsyncb='1') then
		-- vert. sync is low in this interval to signal start of a new frame
		if (vcnt>=490 and vcnt<492) then
			vsyncb <= '0';
		else
			vsyncb <= '1';
		end if;
	end if;
end process;

-- A partir de aqui implementar los m?dulos que faltan, necesarios para dibujar en el monitor

dibujar_marco: process
begin
	if hcnt >= 15 and hcnt < 25 and vcnt >= 25 and vcnt < 475 then --borde izquierdo
	       display_marco <= '1';
	elsif hcnt >= 15 and hcnt < 275 and vcnt >= 0 and vcnt < 25 then --borde de arriba
			display_marco <= '1';
	elsif hcnt >= 265 and hcnt < 275 and vcnt >= 25 and vcnt < 475 then --borde derecho
			display_marco <= '1';
	elsif hcnt >= 15 and hcnt < 275 and vcnt >= 450 and vcnt < 475 then --borde de abajo
		display_marco <= '1';
	else 
	   display_marco <= '0';
		--rgb <= "000000000000";  	
	end if;
end process;


dibujar_barra: process --proceso para dibujar la barra
begin
    if hcnt >= px - 40 and hcnt < px + 40 and vcnt >= 440 and vcnt < 450 then
        display_barra <= '1';
    else
	   display_barra <= '0';
    end if;
end process dibujar_barra;

dibujar_pelota: process --proceso para dibujar la pelota
begin
    if hcnt >= px_pelota - 2 and hcnt < px_pelota + 2  and vcnt >= py_pelota - 2 and vcnt < py_pelota + 2 then
        display_pelota <= '1';
    else
        display_pelota <= '0';
    end if;
end process dibujar_pelota;

dibujar : process --dar los valores de rgb
begin
if display_marco = '1' then
    rgb <= "000011110000";
elsif display_barra = '1' then   
    rgb <= "000000001111"; 
elsif display_pelota = '1' then
    rgb <= "111100000000";     
else
    rgb <= "000000000000";  	
end if;

end process dibujar;

SINCRONO_BARRA: process(clk_in,reset)
begin
if reset ='1' then
    ESTADO_BARRA<=S0;
elsif clk_in'event and clk_in='1' then
    ESTADO_BARRA<= SIG_ESTADO_BARRA;
end if;
end process SINCRONO_BARRA;

fsm_barra : process(ESTADO_BARRA, teclapulsada, tn) --maquina de estados para controlar la barra
begin
case ESTADO_BARRA is
when S0 => --barra quieta
    if (teclapulsada = x"6B") then 
        SIG_ESTADO_BARRA<=S1;
    elsif (teclapulsada = x"74") then 
        SIG_ESTADO_BARRA<=S2;
    else
        SIG_ESTADO_BARRA<=S0;
    end if;
when S1 => --mover a la izquierda
    if (teclapulsada = x"6B") then
        SIG_ESTADO_BARRA<=S1;
    else
        SIG_ESTADO_BARRA<=S0;
   end if;
when S2 => --mover a la derecha
if  (teclapulsada = x"74") then
       SIG_ESTADO_BARRA<=S2;
   else
        SIG_ESTADO_BARRA<=S0;
end if;
end case;
end process;

refrescar_barra: process(ESTADO_BARRA, CLK_BARRA, reset) --proceso de refresco de la barra
begin
if reset = '1' then 
    px <= "010001100"; --140
    reset_teclado <= '1';
elsif CLK_BARRA'event and CLK_BARRA = '1' then
case ESTADO_BARRA is
when S0 =>
    px <= px;
    reset_teclado <= '0';
when S1 =>
    if px - N >= 40 + 25  then
        px <= px - N;
    else
        px <= px;
    end if;
    reset_teclado <= '1';
when S2 =>
    if px + N < 270 - 40 then
        px <= px  + N;
    else
        px <= px;
    end if;
    reset_teclado <= '1';
end case;
end if;
end process refrescar_barra;

SINCRONO_PELOTA: process(clk_in,reset)
begin
if reset ='1' then
    ESTADO_PELOTA<=E0;
elsif clk_in'event and clk_in='1' then
    ESTADO_PELOTA<= SIG_ESTADO_PELOTA;
end if;
end process SINCRONO_PELOTA;

fsm_pelota: process(ESTADO_PELOTA, px_pelota, py_pelota) --maquina de estados para controlar la pelota
begin
case ESTADO_PELOTA is
when E0 => --de arriba a derecha
    if(px_pelota < 265 and  py_pelota < 450) then 
        SIG_ESTADO_PELOTA <= E0;
    elsif(px_pelota >= 265) then
        SIG_ESTADO_PELOTA <= E1;
    elsif py_pelota >= 450 then --cambio de sentido
        SIG_ESTADO_PELOTA <= E6;
    end if;
when E1 => --de derecha a abajo
    if(px_pelota >= 25 and py_pelota < 450 and rebote = '0') then 
        SIG_ESTADO_PELOTA <= E1;
    elsif py_pelota >= 450 or rebote = '1' then
        SIG_ESTADO_PELOTA <= E2;
    elsif px_pelota < 25 then 
        SIG_ESTADO_PELOTA <= E7;
    end if;
when E2 => --de abajo a izquierda
    if(px_pelota >= 25  and py_pelota >= 25) then 
        SIG_ESTADO_PELOTA <= E2;
    elsif(px_pelota < 25) then 
        SIG_ESTADO_PELOTA <= E3;
    elsif (py_pelota < 25) then --cambio de sentido
        SIG_ESTADO_PELOTA <= E4;
    end if;
when E3 => --de izquierda a arriba
    if(py_pelota >= 25 and px_pelota < 265) then 
        SIG_ESTADO_PELOTA <= E3;
    elsif(py_pelota < 25) then
        SIG_ESTADO_PELOTA <= E0;
    elsif px_pelota >= 265 then --cambio de sentido
        SIG_ESTADO_PELOTA <= E5;
    end if;
when E4 => --de arriba a izquierda
    if(py_pelota < 450 and px_pelota >= 25) then 
        SIG_ESTADO_PELOTA <= E4;
    elsif(py_pelota >= 450) then --cambio de sentido
        SIG_ESTADO_PELOTA <= E2;
    elsif px_pelota < 25 then
        SIG_ESTADO_PELOTA <= E7;
    end if;     
when E5 => --de derecha a arriba
    if(py_pelota >= 25 and px_pelota >= 25) then 
        SIG_ESTADO_PELOTA <= E5;
    elsif(py_pelota < 25) then 
        SIG_ESTADO_PELOTA <= E4;
    elsif px_pelota < 25 then --cambio de sentido
        SIG_ESTADO_PELOTA <= E3;
    end if;      
when E6 => --de abajo a derecha
    if(py_pelota >= 25 and px_pelota < 265) then 
        SIG_ESTADO_PELOTA <= E6;
    elsif(py_pelota < 25) then --cambio de sentido
        SIG_ESTADO_PELOTA <= E0;
    elsif px_pelota > 265 then
        SIG_ESTADO_PELOTA <= E5;
    end if;
when E7 => --de izquierda a abajo
    if(py_pelota < 450 and px_pelota < 265) and rebote = '0' then 
        SIG_ESTADO_PELOTA <= E7;
    elsif(py_pelota >= 450) or rebote = '1' then
        SIG_ESTADO_PELOTA <= E6;
    elsif px_pelota >= 265 then --cambio de sentido
        SIG_ESTADO_PELOTA <= E1;
    end if;
end case;
end process fsm_pelota;

refresco_pelota: process(reset, CLK_PELOTA)
begin
if reset = '1' then
    px_pelota <= "010001100"; --140
    py_pelota <= "0000011110";--30  
    rebotes <= "000";
    rebote <= '0';
elsif CLK_PELOTA'EVENT AND CLK_PELOTA = '1' then
case ESTADO_PELOTA is
when E0 =>
    px_pelota <= px_pelota + M;  
    py_pelota <= py_pelota + P;  
when E1 =>
    if (px_pelota + M + 2 <= px + 40 and px_pelota - M - 2 >= px - 40) and (py_pelota + 2 = 440) then
        rebotes <= rebotes + 1;
        rebote <= '1';
    else
        px_pelota <= px_pelota - M;  
        py_pelota <= py_pelota + P;
    end if;
when E2 =>
    px_pelota <= px_pelota - M;  
    py_pelota <= py_pelota - P;  
    rebote <= '0';
when E3 =>
    px_pelota <= px_pelota + M;  
    py_pelota <= py_pelota - P;  
when E4 =>
    px_pelota <= px_pelota - M;  
    py_pelota <= py_pelota + P;  
when E5 =>
    px_pelota <= px_pelota - M;  
    py_pelota <= py_pelota - P;  
when E6 =>
    px_pelota <= px_pelota + M;  
    py_pelota <= py_pelota - P;
    rebote <= '0';  
when E7 =>
    if (px_pelota + M + 2 <= px + 40 and px_pelota - M - 2 >= px - 40) and (py_pelota + 2 = 440) then
        rebote <= '1';  
        rebotes <= rebotes + 1;
    else 
        px_pelota <= px_pelota + M;  
        py_pelota <= py_pelota + P;  
    end if;
end case;
end if;
end process refresco_pelota;

salida_display: process(rebotes) --salida display 7 segmentos
begin
case rebotes is
	 when "000" =>
		seg <= B"1000000";
	 when "001" =>
		seg <=  B"1111001";
	 when "010" =>
		seg <= B"0100100";
	 when "011" =>
		seg <= B"0110000";
	 when "100" =>
		seg <= B"0011001";
	 when "101" =>
		seg <= B"0010010";
	 when "110" =>
		seg <= B"0000010";
	 when "111" =>
		seg <= B"1111000";
	end case; 
end process salida_display;

end vgacore_arch;

