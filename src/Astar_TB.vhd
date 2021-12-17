library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.all;
use ieee.std_logic_unsigned.all;

use STD.textio.all;
use ieee.std_logic_textio.all;

library work;
use work.Priority_Queue.all;

entity Astar_TB is
end Astar_TB;

architecture behavior of Astar_TB is

   -- Component Declaration for the Unit Under Test (UUT)

   component Astar
      port (
         Map_Input          : in std_logic;
         clk                : in std_logic;
         Destination_Node_X : in integer range 0 to Map_Width - 1;
         Destination_Node_Y : in integer range 0 to Map_Height - 1;
         Starting_Node_X    : in integer range 0 to Map_Width - 1;
         Starting_Node_Y    : in integer range 0 to Map_Height - 1;
         Direction          : out integer range 0 to 4;
         Path_Not_Found     : out std_logic;
         Map_input_Enable   : in std_logic;
         reset              : in std_logic
      );
   end component;
   --Inputs
   signal Map_Input          : std_logic := '0';
   signal clk                : std_logic := '0';
   signal Destination_Node_X : integer   := 0;
   signal Destination_Node_Y : integer   := 0;
   signal Starting_Node_X    : integer   := 0;
   signal Starting_Node_Y    : integer   := 0;
   signal Map_input_Enable   : std_logic := '0';
   signal reset              : std_logic := '0';

   --Outputs
   signal Direction      : integer;
   signal Path_Not_Found : std_logic;

   -- Clock period definitions
   constant clk_period : time := 100 ns;

begin

   -- Instantiate the Unit Under Test (UUT)
   uut : Astar port map(
      Map_Input          => Map_Input,
      clk                => clk,
      Destination_Node_X => Destination_Node_X,
      Destination_Node_Y => Destination_Node_Y,
      Starting_Node_X    => Starting_Node_X,
      Starting_Node_Y    => Starting_Node_Y,
      Direction          => Direction,
      Path_Not_Found     => Path_Not_Found,
      Map_input_Enable   => Map_input_Enable,
      reset              => reset
   );

   -- Clock process definitions
   clk_process : process
   begin
      clk <= '1';
      wait for clk_period/2;
      clk <= '0';
      wait for clk_period/2;
   end process;

   process is
      file Map_File           : text open read_mode is "Map.txt";
      file Direction_File     : text open write_mode is "Direction.txt";
      file Node_Data_File     : text open write_mode is "Node_Data.txt";
      variable Map_Line       : line;
      variable Direction_Line : line;
      variable Node_Data_Line : line;
      variable Temp_Map_Node  : std_logic;
   begin
      
      Starting_Node_X    <= 0;
      Starting_Node_Y    <= 0;

      Destination_Node_X <= 9;
      Destination_Node_Y <= 9;
      wait for clk_period;
      -- export some crucial nodes for later use in the python script
      --0
      write(Node_Data_Line, Starting_Node_X);
      writeline(Node_Data_File, Node_Data_Line);
      --1
      write(Node_Data_Line, Starting_Node_Y);
      writeline(Node_Data_File, Node_Data_Line);
      --2
      write(Node_Data_Line, Destination_Node_X);
      writeline(Node_Data_File, Node_Data_Line);
      --3
      write(Node_Data_Line, Destination_Node_Y);
      writeline(Node_Data_File, Node_Data_Line);
      --4
      write(Node_Data_Line, Map_Width);
      writeline(Node_Data_File, Node_Data_Line);
      --5
      write(Node_Data_Line, Map_Height);
      writeline(Node_Data_File, Node_Data_Line);

      --import the map from file
      Map_input_Enable   <= '1';
      while not endfile(Map_File) loop
         readline(Map_File, Map_Line);
         read(Map_Line, Temp_Map_Node);
         Map_Input <= Temp_Map_Node;
         wait for clk_period;
      end loop;
      report "1";

      Map_input_Enable <= '0';
      wait for clk_period;

      wait until Direction /= 0;
      wait for clk_period;
      --record directions and export it in to a file
      while Direction /= 0 loop        
         write(Direction_Line, Direction);
         writeline(Direction_File, Direction_Line);
         wait for clk_period;
      end loop;
   end process;
end;
