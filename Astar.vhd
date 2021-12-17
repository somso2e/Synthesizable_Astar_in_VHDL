library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

library work;

use work.Priority_Queue.all;

entity Astar is
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
end Astar;

architecture Behavioral of Astar is
    type state_type is(initialization, algorithm, reconstruct_path, Output_Path);
    signal state : state_type;

    type Nodes_Array is array(0 to Map_Width - 1, 0 to Map_Height - 1) of Node_Items;

    type Path_type is array (0 to inf - 1) of coordinates;
begin

    process (clk, Map_input_Enable, reset)
        variable Node           : Nodes_Array;
        variable Priority_Queue : Priority_Queue_Class;

        --initialization 
        variable x : integer range 0 to Map_Width - 1  := 0;
        variable y : integer range 0 to Map_Height - 1 := 0;
        --Algorithm
        variable current       : Node_Items;
        variable Neighbor      : Node_Items;
        variable temp_g_score  : integer;
        variable Valid_Neighor : boolean := false;
        --Path
        variable Path       : Path_type;
        variable Path_Count : integer range 0 to inf -1:= 0;
    begin
        if rising_edge(clk) then
            --reset some variables to their default value
            if reset = '1' then
                state <= initialization;
                x          := 0;
                y          := 0;
                Path_Count := 0;

            end if;

            case state is
                when initialization =>
                    if Map_input_Enable = '1' then
                        --Map is being downloaded one cell at a time in each clk cycle
                        Node(x, y).coords.X  := x;   -- Record the X coordinates of the cell
                        Node(x, y).coords.Y  := y;   -- Record the Y coordinates of the cell
                        Node(x, y).g_score   := inf; -- Set the default g score at infinity 
                        Node(x, y).f_score   := inf; -- Set the default f score at infinity 
                        Node(x, y).isBarrier := Map_Input;
                        Node(x, y).In_Queue  := false;

                        x := x + 1;
                        if x = Map_Width then
                            x := 0;
                            y := y + 1;
                        end if;
                        -- Program has reached Map_Height which means the Map has been fully downloaded 
                        if y = Map_Height then
                            y := 0;
                            -- Set the default f score and g score of the starting node 
                            Node(Starting_Node_X, Starting_Node_Y).g_score := 0;
                            Node(Starting_Node_X, Starting_Node_Y).f_score := Measure_Distance(Node(Destination_Node_X, Destination_Node_Y), Node(Starting_Node_X, Starting_Node_Y));
                            -- Add the starting node to the priority queue
                            Priority_Queue.count := 0;
                            Priority_Queue_Add(Priority_Queue, Node(Starting_Node_X, Starting_Node_Y));
                            -- The initialization has been over. Continue to the algorithm.
                            state <= algorithm;

                        end if;
                    end if;
                when algorithm =>
                    --Continue until the priority queue is empty or priority queue has reached the set limit
                    if Priority_Queue.count /= 0 or Priority_Queue.count /= Priority_Queue_Limit then
                        

                        -- set current node as the first node stored in prioroty queue
                        current := Priority_Queue.Node(Priority_Queue.count - 1);

                        -- if the coordinates of current match destination, reconstruct path
                        if current.coords.X = Destination_Node_X and current.coords.Y = Destination_Node_Y then
                            -- 
                            state          <= reconstruct_path;
                            Path_Not_Found <= '0';
                        else
                            -- remove current from priority queue
                            Priority_Queue_Remove(Priority_Queue);
                            Node(current.coords.X, current.coords.Y).In_Queue := false;

                            -- for each direction check if the adjacent node is a valid node(not out of bound and not a barrier)
                            for i in 0 to 3 loop

                                if i = 0 then-- Up
                                    if current.coords.Y /= 0 and Node(current.coords.X, current.coords.Y - 1).isBarrier = '0' then
                                        Neighbor      := Node(current.coords.X, current.coords.Y - 1);
                                        Valid_Neighor := true;
                                    else
                                        Valid_Neighor := false;
                                    end if;

                                elsif i = 1 then -- Right
                                    if current.coords.X /= Map_Width - 1 and Node(current.coords.X + 1, current.coords.Y).isBarrier = '0' then
                                        Neighbor      := Node(current.coords.X + 1, current.coords.Y);
                                        Valid_Neighor := true;
                                    else
                                        Valid_Neighor := false;
                                    end if;

                                elsif i = 2 then -- Down
                                    if current.coords.Y /= Map_Height - 1 and Node(current.coords.X, current.coords.Y + 1).isBarrier = '0' then
                                        Neighbor      := Node(current.coords.X, current.coords.Y + 1);
                                        Valid_Neighor := true;
                                    else
                                        Valid_Neighor := false;
                                    end if;

                                elsif i = 3 then --Left
                                    -- If the current node is not on the left most column and the node on its left is not a barrier
                                    if current.coords.X /= 0 and Node(current.coords.X - 1, current.coords.Y).isBarrier = '0' then
                                        Neighbor      := Node(current.coords.X - 1, current.coords.Y);
                                        Valid_Neighor := true;
                                    else
                                        Valid_Neighor := false;
                                    end if;

                                end if;

                                if Valid_Neighor = true then
                                    temp_g_score := current.g_score + 1;

                                    if temp_g_score < Neighbor.g_score then
                                        -- this neighbor is a better path than the previous one
                                        Neighbor.Parent  := current.coords;
                                        Neighbor.g_score := temp_g_score;
                                        Neighbor.f_score := temp_g_score + Measure_Distance(Node(Destination_Node_X, Destination_Node_Y), Neighbor);
                                        --if it already isn't in the priority queue, add it.
                                        if Neighbor.In_Queue = false then
                                            Priority_Queue_Add(Priority_Queue, Neighbor);
                                            Neighbor.In_Queue                          := true;
                                            Node(neighbor.coords.X, neighbor.coords.Y) := Neighbor;
                                        end if;

                                    end if;
                                end if;
                            end loop;
                        end if;
                    else
                        --if priority queue becomes empty or reaches limit, no path exists.(timed out)
                        Path_Not_Found <= '1';
                        state          <= initialization;

                    end if;
                when reconstruct_path =>
                    --trace back to start from destination using the parent of each node
                    Path(Path_Count) := current.coords;
                    if current.coords.X = Starting_Node_X and current.coords.Y = Starting_Node_Y then
                        state <= Output_Path;

                    else
                        current.coords := Node(current.coords.x, current.coords.Y).Parent;
                        Path_Count     := Path_Count + 1;
                    end if;
                when Output_Path =>
                    -- 0 1 2 3
                    -- 1 - U -
                    -- 2 L X R
                    -- 3 - D -
                    if Path_Count = 0 then
                        state     <= initialization;
                        Direction <= 0;

                    else
                        --compare the x and y of each node with its parent and output the direction
                        if Path(Path_Count).Y > Path(Path_Count - 1).Y then
                            Direction <= 1; --UP  
                        elsif Path(Path_Count).X < Path(Path_Count - 1).X then
                            Direction <= 2; -- RIGHT                  
                        elsif Path(Path_Count).Y < Path(Path_Count - 1).Y then
                            Direction <= 3; --DOWN 
                        elsif Path(Path_Count).X > Path(Path_Count - 1).X then
                            Direction <= 4; -- LEFT
                        end if;

                        Path_Count := Path_Count - 1;
                    end if;
            end case;

        end if;
    end process;
end Behavioral;