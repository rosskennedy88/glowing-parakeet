--------------------------------------------------------------------------------
--
--   FileName: VHDL Pong Game        hw_image_generator.vhd
--   Dependencies:     none
--   Design Software:  Quartus II 64-bit Version 12.1 Build 177 SJ Full Version
--
--   HDL CODE IS PROVIDED "AS IS."  DIGI-KEY EXPRESSLY DISCLAIMS ANY
--   WARRANTY OF ANY KIND, WHETHER EXPRESS OR IMPLIED, INCLUDING BUT NOT
--   LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
--   PARTICULAR PURPOSE, OR NON-INFRINGEMENT. IN NO EVENT SHALL DIGI-KEY
--   BE LIABLE FOR ANY INCIDENTAL, SPECIAL, INDIRECT OR CONSEQUENTIAL
--   DAMAGES, LOST PROFITS OR LOST DATA, HARM TO YOUR EQUIPMENT, COST OF
--   PROCUREMENT OF SUBSTITUTE GOODS, TECHNOLOGY OR SERVICES, ANY CLAIMS
--   BY THIRD PARTIES (INCLUDING BUT NOT LIMITED TO ANY DEFENSE THEREOF),
--   ANY CLAIMS FOR INDEMNITY OR CONTRIBUTION, OR OTHER SIMILAR COSTS.
--
--   Version History
--   Version 1.0 05/10/2013 Scott Larson
--     Initial Public Release
--    
--------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;


ENTITY hw_image_generator IS
	
	PORT(
	   CLK_50MHz   :  in    std_logic;
		disp_ena		:	IN		STD_LOGIC;	--display enable ('1' = display time, '0' = blanking time)
		row			:	in		INTEGER;		--row pixel coordinate
		column		:	in		INTEGER;		--column pixel coordinate
		red			:Buffer STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');  --red magnitude output to DAC
		green			:Buffer STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');  --green magnitude output to DAC
		blue			:Buffer STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0'); --blue magnitude output to DAC
		button_1    :  IN    STD_LOGIC; --controls left paddle up movment
		button_2    :  IN    STD_LOGIC;--controls left paddle down movment
		button_3    :  IN    STD_LOGIC;--controls right paddle up movment
		button_4    :  IN    STD_LOGIC;--controls right paddle down movment
		hex_left	:  out std_logic_vector(6 downto 0);
		hex_right	:  out std_logic_vector(6 downto 0);
		SW1 : in std_logic
		);
		
END hw_image_generator;


ARCHITECTURE behavior OF hw_image_generator IS

--paddle constant 
constant paddle_speed : integer := 1;
constant paddle_height : integer := 10;
constant default_ball_speed : integer := 6; --intial ball speed

signal counter : std_logic_vector(26 downto 0);  -- signal that does the counting  
signal CLK_1HZ : std_logic;   -- to drive the LED
-- paddle 1 singals
signal paddle_ah1 : integer range 0 to 1080:= 415;
signal paddle_aw1 : integer range 0 to 1920:= 30;
signal paddle_bh1 : integer range 0 to 1080:= 415;
signal paddle_bw1 : integer range 0 to 1920:= 1840;
--ball signals 
signal ball_pos_w: integer range 0 to 1080:= 525;
signal ball_pos_h: integer range 0 to 1920:= 945;
signal ball_up	  	: std_logic:= '0';
signal ball_right	: std_logic:= '1';
signal ball_speed_h 	: integer range 0 to 19:= default_ball_speed;
signal ball_speed_v	: integer range 0 to 19:= default_ball_speed;
--player score signals
signal right_player_score : std_logic_vector (0 to 6) :="0000001";
signal left_player_score  : std_logic_vector (0 to 6) :="0000001";
--reset signal
signal reset : std_logic; 


BEGIN
	reset <=  SW1;
	PROCESS(disp_ena, row, column)
	BEGIN
	
		IF(disp_ena = '1') THEN		--draw process
		
	
				IF((column >= paddle_ah1 and column < paddle_ah1 + 250) and (row >= paddle_aw1 and row < paddle_aw1 + 40)) THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '0');
				
				elsIF((column >= paddle_bh1 and column < paddle_bh1 + 250) and (row >= paddle_bw1 and row < paddle_bw1 + 40)) THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '0');
					
				elsIF((column >= ball_pos_w and column < ball_pos_w + 30) and (row >= ball_pos_h and row < ball_pos_h + 30)) THEN
				red <= (OTHERS => '0');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '1');
				
		   	ELSE
				red <= (OTHERS => '0');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '0');
	      	END IF;
		      ELSE								--blanking time
			   red <= (OTHERS => '0');
			   green <= (OTHERS => '0');
			   blue <= (OTHERS => '0');
		END IF;
	
	END PROCESS;
	
	
clock : process(CLK_50MHz,paddle_aw1,paddle_bw1)

begin

	if (clk_50MHz'event and clk_50MHz = '1') then -- rising clock edge
			if counter < "1111010000100100000" then -- binary value is 5 million, 23 bits
				counter <= counter + 1;         
			else                        
				counter <= (others => '0');
			if ((disp_ena = '0')) then
			 if(button_1 = '0') then 
			  if(paddle_ah1 > 30)then -- moves paddle up
						paddle_ah1 <= paddle_ah1 - 25;
						end if;
			elsif(button_2 = '0') then	--moves paddle down
			  if(paddle_ah1 < 800) then				
						paddle_ah1 <= paddle_ah1 + 25;
							end if;		
						end if;
											
			if(button_3 = '0') then 
			  if(paddle_bh1 > 30)then -- moves paddle up
					paddle_bh1 <= paddle_bh1 - 25;
					end if;
			elsif(button_4 = '0') then	--moves paddle down
			   if(paddle_bh1 < 800) then				
					paddle_bh1 <= paddle_bh1 + 25;
			end if;		
	end if;									
		if (reset = '1') then
			left_player_score <= "0000001";
			right_player_score <= "0000001";
		   hex_left <= "0000001";
			hex_right <= "0000001";		
			ball_pos_h <= 945;
			ball_pos_w <= 525;
			ball_speed_h <= default_ball_speed;
			ball_speed_v <= default_ball_speed;
		else

			--If ball travelling right, and not far right
			if (ball_pos_h < 1854  and ball_up = '1') then
				ball_pos_h <= ball_pos_h + ball_speed_v;
				
			--If ball travelling right and at far right
			elsif (ball_up = '1') then
				ball_up <= '0';
				
					--display score for left player			
					if (left_player_score <= "0000001") then    --1
								 hex_left <= "1001111";
								 left_player_score <= "0000010";
								 ball_pos_h<= 945;
					          ball_pos_w <= 525;
								 ball_speed_v <= default_ball_speed;
		                   ball_speed_h <= default_ball_speed; 
								 
					elsif (left_player_score <= "0000010") then    --2
								 hex_left <= "0010010";
								 left_player_score <="0000011";
								 ball_pos_h <= 945;
					          ball_pos_w <= 525;
								 ball_speed_v <= default_ball_speed;
		                   ball_speed_h <= default_ball_speed; 
								 
					elsif (left_player_score <= "0000011") then    --3
							hex_left <= "0000110";
								 left_player_score <="0000100";
								 ball_pos_h <= 945;
					          ball_pos_w <= 525;
								 ball_speed_v <= default_ball_speed;
		                   ball_speed_h <= default_ball_speed; 
								 
					elsif (left_player_score <= "0000100") then    --4
								 hex_left <= "1001100";
								left_player_score <= "0000101";
								ball_pos_h <= 945;
				 	         ball_pos_w <= 525;
								ball_speed_v <= default_ball_speed;
		                  ball_speed_h <= default_ball_speed; 
								
					elsif (left_player_score <= "0000101") then    --5
								 hex_left <= "0100100";
								 left_player_score <= "0000110";
								 ball_pos_h <= 945;
								 ball_pos_w <= 525;
								 ball_speed_v <= default_ball_speed;
		                   ball_speed_h <= default_ball_speed; 
								 
					elsif (left_player_score <= "0000110") then   --6
								 hex_left <= "0100000"; 
								left_player_score <= "0000111";
								ball_pos_h <= 945;
							   ball_pos_w <= 525;
								ball_speed_v <= default_ball_speed;
		                  ball_speed_h <= default_ball_speed; 
								 
	   			elsif (left_player_score <= "0000111") then   --7
								 hex_left <= "0001111";
								  left_player_score <= "0001000";
								  ball_pos_h <= 945;
								  ball_pos_w <= 525;
								 ball_speed_v <= default_ball_speed;
		                   ball_speed_h <= default_ball_speed; 
								 
					elsif (left_player_score <= "0001000") then   --8
								hex_left <= "0000000";
								 left_player_score <= "0001001";
								 ball_pos_h <= 945;
								 ball_pos_w <= 525;
								 ball_speed_v <= default_ball_speed;
		                   ball_speed_h <= default_ball_speed; 
								 
					elsif (left_player_score <= "0001001") then  --9
								 hex_left <= "0000100";
								left_player_score <= "0001001";
								ball_pos_h <= 945;
				            ball_pos_w <= 525;	
								
					--Force a reset by stopping the ball
					ball_speed_h 			<= 0;
					ball_speed_v			<= 0;
			end if;
			
				--Ball travelling left and not at far left
			elsif (ball_pos_h > 30 and ball_up = '0') then
				ball_pos_h <= ball_pos_h - ball_speed_v;
				
			--Ball travelling left and at far left
			elsif (ball_up = '0') then
				ball_up <= '1';
				
					--display score for right player
					if (right_player_score <= "0000001") then    --1
								hex_right <= "1001111";
								right_player_score <= "0000010";
							   ball_pos_h <= 945;
				            ball_pos_w <= 525;
								ball_speed_v <= default_ball_speed;
		                  ball_speed_h <= default_ball_speed; 
								
								 
					elsif (right_player_score = "0000010") then    --2
								hex_right <= "0010010";
								right_player_score <=  "0000011";
								ball_pos_h <= 945;
				            ball_pos_w <= 525;
								ball_speed_v <= default_ball_speed;
		                  ball_speed_h <= default_ball_speed; 
								 
					elsif (right_player_score = "0000011") then    --3
								hex_right <= "0000110";
								right_player_score <= "0000100";
								ball_pos_h <= 945;
				            ball_pos_w <= 525;
								ball_speed_v <= default_ball_speed;
		                  ball_speed_h <= default_ball_speed; 
								 
					elsif (right_player_score <= "0000100") then    --4
								hex_right <= "1001100";
								right_player_score <="0000101";
								ball_pos_h <= 945;
				            ball_pos_w <= 525;
								ball_speed_v <= default_ball_speed;
		                  ball_speed_h <= default_ball_speed; 
								
					elsif (right_player_score <= "0000101") then    --5
								 hex_right <= "0100100";
								 right_player_score <="0000110";
								 ball_pos_h <= 945;
				            ball_pos_w <= 525;
								ball_speed_v <= default_ball_speed;
		                  ball_speed_h <= default_ball_speed; 
								 
					elsif (right_player_score <= "0000110") then   --6
								 hex_right <= "0100000"; 
								right_player_score <="0000111";
								ball_pos_h <= 945;
				            ball_pos_w <= 525;
								ball_speed_v <= default_ball_speed;
		                  ball_speed_h <= default_ball_speed; 
								 
					elsif (right_player_score = "0000111") then   --7
							   hex_right <= "0001111";
								right_player_score <= "0001000";
							   ball_pos_h <= 945;
				            ball_pos_w <= 525;
								ball_speed_v <= default_ball_speed;
		                  ball_speed_h <= default_ball_speed; 
								 
					elsif (right_player_score <= "0001000") then   --8
								hex_right <= "0000000";
								right_player_score <= "0001001";
								ball_pos_h <= 945;
				            ball_pos_w <= 525;
								ball_speed_v <= default_ball_speed;
		                  ball_speed_h <= default_ball_speed; 
								 
					elsif (right_player_score <= "0001001") then  --9
								hex_right <= "0000100";
								right_player_score <="0001001";
								ball_pos_h <= 945;
				            ball_pos_w <= 525;
								
					--Force a reset by stopping the ball
					ball_speed_h 			<= 0;
					ball_speed_v			<= 0;
				
				end if;			
			end if;
			
			--If ball travelling down, and not at bottom boundry
			if (ball_pos_w < 1044 and ball_right = '1') then
				ball_pos_w <= ball_pos_w + ball_speed_h;
				
			--If ball travelling right and at far right
			elsif (ball_right = '1') then
				ball_right	<= '0';		
				
			--If ball travelling up and not at top
			elsif (ball_pos_w > 10 and ball_right = '0') then
				ball_pos_w <= ball_pos_w - ball_speed_h;
				
			--Ball travelling up and at top
			elsif (ball_right = '0') then
				ball_right <= '1';
			end if;
		end if;
		
		--detect collision with left paddle
		if (((ball_pos_w + 30 > paddle_ah1) and (ball_pos_w <  paddle_ah1 + 250)) and (paddle_aw1 + 40 > ball_pos_h)) then
		ball_up <= '1';
		
		--increase ball speed each time a collision occurs on left paddle
		ball_speed_v <= ball_speed_v + 1;
		ball_speed_h <= ball_speed_h + 1; 
		
		--detect collision with right paddle
		elsif (((ball_pos_w + 30 > paddle_bh1) and (ball_pos_w <  paddle_bh1 + 250)) and (paddle_bw1 < (ball_pos_h + 30))) then
			    ball_up <= '0';
		   --increase ball speed each time a collision occurs on right paddle
			ball_speed_v <= ball_speed_v + 1;
			ball_speed_h <= ball_speed_h + 1;
		end if;
		end if;			
	end if;				
end if;

end process clock;

END behavior;
