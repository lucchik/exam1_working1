
----------------------------------------------------------------------------------
-- Engineer: 			Lucy Chikwetu
-- Create Date:		19:07:21 02/22/2016 
-- Module Name:    	lucyExam 
-- Version:				14
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;

ENTITY exam1 IS
    PORT (	clk : 			IN  STD_LOGIC;
				reset_l : 		IN  STD_LOGIC;
				rxf_l : 			IN  STD_LOGIC;
				oe_l : 			OUT STD_LOGIC;
				rd_l : 			OUT STD_LOGIC;
				d : 				IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
				--Timing Generator pins
				r:					OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
				g:					OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
				b:					OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
				hs:				OUT STD_LOGIC;
				vs:				OUT STD_LOGIC);				
END exam1;

ARCHITECTURE Behavioral OF exam1 IS

TYPE states IS (s0, s1,s2,s3,s4,s4a,s4b,s4c,s5,s6,s7);
SIGNAL state:		states := s0;
SIGNAL nextState:	states := s0;
SIGNAL data1:			STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL data2:			STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL eni1_h:			STD_LOGIC;
SIGNAL eni2_h:			STD_LOGIC;
--Timing Generator pins
SIGNAL hVideo:			STD_LOGIC;
SIGNAL vVideo:			STD_LOGIC;
SIGNAL hCount:			STD_LOGIC_VECTOR(9 DOWNTO 0):="0000000000";
SIGNAL vCount:			STD_LOGIC_VECTOR(9 DOWNTO 0):="0000000000";

--Address Counter
SIGNAL cEN:						STD_LOGIC;
SIGNAL addCounter:			STD_LOGIC_VECTOR(16 DOWNTO 0) := "00000000000000000";

--Block RAM
SIGNAL wea: 					STD_LOGIC_VECTOR(0 DOWNTO 0);
SIGNAL addra: 					STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL dina: 					STD_LOGIC_VECTOR(8 DOWNTO 0);
SIGNAL rstb: 					STD_LOGIC;
SIGNAL addrb: 					STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL doutb: 					STD_LOGIC_VECTOR(8 DOWNTO 0);

COMPONENT dualPort_RAM
  PORT (
    clka: 		IN STD_LOGIC;
    wea: 		IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addra: 		IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    dina: 		IN STD_LOGIC_VECTOR(8 DOWNTO 0);
    clkb: 		IN STD_LOGIC;
    rstb: 		IN STD_LOGIC;
    addrb: 		IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    doutb: 		OUT STD_LOGIC_VECTOR(8 DOWNTO 0)
  );
END COMPONENT;

SIGNAL vgaClk:		STD_LOGIC;
SIGNAL dcmClk:		STD_LOGIC;

--clock Generator
COMPONENT myClockGenerator
PORT
 (-- Clock in ports
  CLK_IN1: 			IN STD_LOGIC;
  -- Clock out ports
  dcmClk: 			OUT STD_LOGIC;
  vgaClk:			OUT STD_LOGIC);
END COMPONENT;


BEGIN

clockManager : myClockGenerator
	PORT MAP
   (-- Clock in ports
    CLK_IN1 => clk,
    -- Clock out ports
    dcmClk => dcmClk,
    vgaClk => vgaClk);

--Block RAM
RAM : dualPort_RAM
  PORT MAP (
    clka => dcmClk,
    wea => wea,
    addra => addra,
    dina => dina,
    clkb => vgaClk,
    rstb => rstb,
    addrb => addrb,
    doutb => doutb
  );
  
 --*************************************************************************************
 -- Address Counter
 --************************************************************************************
 PROCESS (dcmClk)
 BEGIN 
	IF (dcmClk'EVENT AND dcmClk='1') THEN 
		IF (cEN ='1') THEN
			IF (addCounter = 65536 OR reset_l = '1') THEN 
				addCounter <= (others => '0');
			ELSE 
				addCounter <= addCounter+1;
			END IF;
		END IF;
		IF (reset_l = '0') THEN 
			addra <= "0000000000000000";
		END IF;
		IF (state = s6) THEN
			addra <= addCounter (15 DOWNTO 0)-1;
		END IF;
	END IF;
 END PROCESS;
 --************************************************************************************
 
 --....................................................................................
 -- Memory Writing 
 --....................................................................................
 PROCESS (dcmClk)
 BEGIN 
	IF (dcmClk'EVENT AND dcmClk='1') THEN
		IF (state = s6) THEN
			dina <=data1(0 DOWNTO 0) & data2;
		END IF;
	END IF;
 END PROCESS;
 --....................................................................................
 
--************************************************************************************
  --MEMORY READING 
--************************************************************************************
 PROCESS (vgaClk,reset_l)
 BEGIN 
	IF (vgaClk'EVENT AND vgaClk='1') THEN 
		addrb <= (vCount(7 downto 0)-34) & (hCount(7 downto 0)-143);	
	END IF;
	IF (reset_l = '0') THEN 
		addrb<= "0000000000000000";
	END IF;
END PROCESS;
--*************************************************************************************
 
--------------------------------------------------------------------------------------
-- PROCESS TO IMPLEMENT THE STATE REGISTER
--------------------------------------------------------------------------------------
stateRegister: PROCESS(dcmClk)
BEGIN
	IF (dcmClk'EVENT AND dcmClk = '1') THEN 
		IF (reset_l = '0') THEN
			state <= s0;
		ELSE 
			state <= nextState;
		END IF;
	--address reset
	END IF;
END PROCESS stateRegister;
rstb <= '1' WHEN (reset_l = '0') ELSE '0';
--------------------------------------------------------------------------------------

--************************************************************************************
-- PROCESS TO DETERMINE NEXT STATE 
--************************************************************************************
stateTransition: PROCESS(rxf_l, state)
BEGIN 
	nextState <= state;
	CASE state IS 
		WHEN s0 =>	IF(rxf_l = '0') THEN 
							nextState <= s1;
						ELSE 
							nextState <= s0;
						END IF;
		WHEN s1 =>
			nextState <= s2;
		WHEN s2 =>
			nextState <= s3;
		WHEN s3 =>
			nextState <= s5;
		WHEN s4 =>
			IF (rxf_l = '0') THEN 
				nextState <= s4a;
			ELSE
				nextState <= s4;
			END IF;
		WHEN s5 =>
			IF (rxf_l = '0') THEN
				nextState <= s6;
			ELSE 
				nextState <= s4;
			END IF;
		WHEN s4a =>
			nextState <= s4b;
		WHEN s4b =>
			nextState <= s4c;
		WHEN s4c =>
			nextState <= s6;
		WHEN s6 =>
			nextState <= s7;
		WHEN s7 =>
			nextState <= s0;
	END CASE;
END PROCESS stateTransition;
oe_l <= '0' WHEN (rxf_l='0' AND (state = s2 OR state = s3  OR state = s5 OR state=s4b OR state = s4c)) ELSE '1';
rd_l <= '0' WHEN (rxf_l='0' AND (state = s3 OR state = s5 OR state = s4c)) ELSE '1';
eni1_h <= '1' WHEN (state=s3 OR state = s5 OR state = s4c) ELSE '0'; 
eni2_h <= '1' WHEN (state = s5) ELSE '0';
wea(0) <= '1' WHEN (state = s7) ELSE '0';
cEN <= '1' WHEN (state = s3) ELSE '0';
--************************************************************************************

----------------------------------------------------------------------------------------
---- DATA PATH
----------------------------------------------------------------------------------------
dataPath: PROCESS (dcmClk)
BEGIN
	IF (dcmClk'EVENT AND dcmClk='1') THEN 
		IF ((eni2_h = '1')) THEN
			data2 <= data1;
		END IF;
		IF (eni1_h = '1') THEN
			data1 <= d;
		END IF;
	END IF;
END PROCESS dataPath;
--------------------------------------------------------------------------------------

--************************************************************************************
-- TIMING GENERATOR 
--************************************************************************************

	--------------------------------------------------------------
	--verticalCounter		
	--------------------------------------------------------------
	PROCESS(vgaClk)
	BEGIN 
		IF (vgaClk'event AND vgaClk='1') THEN --vC rising edge 
			IF (hCount = 799) THEN --799
				IF (vCount = 524) THEN --vCount = 524
					vCount <= (others => '0');
				ELSE
					vCount <= vCount + 1;
				END IF; --vCount = 524
			END IF; --799
		END IF; --vC rising edge
	END PROCESS;
	
	PROCESS(vCount)
	BEGIN
	vVideo <= '0';
	IF (vCount >= 34 AND vCount <= 515) THEN
		vVideo <= '1';
	END IF;
	END PROCESS;
	--------------------------------------------------------------
	
	
	--************************************************************
	--	horizontalCounter:	
	--************************************************************
	PROCESS(vgaClk)
	BEGIN
	IF (vgaClk'event AND vgaClk='1') THEN --hC rising edge 
		IF (hCount = 799) THEN
			hCount <= (others => '0');
		ELSE
			hCount <= hCount + 1;
		END IF;
	END IF; --hC rising edge
	END PROCESS;

	PROCESS(hCount)
	BEGIN
	hVideo <= '0';
	IF (hCount>=143 AND hCount<=783) THEN
		hVideo <= '1';
	END IF;
	END PROCESS;
	--************************************************************
	
	
	--------------------------------------------------------------							
	--	syncing:		
	--------------------------------------------------------------		
	PROCESS(vgaClk)
	BEGIN
	IF (vgaClk'event AND vgaClk = '1') THEN --syncing rising edge
		IF (hCount<=95) THEN --**
			hs <= '0';
		ELSE 
			hs <= '1';
		END IF; --**
		IF (vCount <=1) THEN --++
			vs <= '0';
		ELSE 
			vs <= '1';
		END IF; --++	
	END IF; --syncing rising edge
	END PROCESS;
	--------------------------------------------------------------


	--************************************************************
	--	rgb:		
	--************************************************************
	PROCESS(vgaClk)
	BEGIN 
	IF (vgaClk'event AND vgaClk='1') THEN --rising edge 
		IF (hVideo = '1' AND vVideo = '1') THEN
			r <= doutb(2 DOWNTO 0);
			g <= doutb(5 DOWNTO 3);
			b <= doutb(8 DOWNTO 6);
		ELSE 
			r <= "000";
			g <= "000";
			b <= "000";
		END IF;
	END IF; --rising edge
	END PROCESS;
	--************************************************************


--************************************************************************************
-- END OF TIMING GENERATOR
--************************************************************************************

END Behavioral;

