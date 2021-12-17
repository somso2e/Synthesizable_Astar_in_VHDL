library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

package Priority_Queue is
    --constants:
    constant Map_Width            : integer := 10;
    constant Map_Height           : integer := 10;
    constant inf                  : integer := 63;-- This is a arbitrary value and chosen as such for better performance
    constant Priority_Queue_Limit : integer := 32;-- This is a arbitrary value and chosen as such for better performance
    ---------------------------------------------------------------
    type coordinates is record
        X : integer range 0 to Map_Width - 1;
        Y : integer range 0 to Map_Height - 1;
    end record;
    ---------------------------------------------------------------
    type Node_Items is record
        coords    : coordinates;
        g_score   : integer range 0 to inf;
        f_score   : integer range 0 to inf;
        isBarrier : std_logic;
        Parent    : coordinates;
        In_Queue  : boolean;
    end record;
    ---------------------------------------------------------------
    type Priority_Queue_Nodes is array (0 to Priority_Queue_Limit - 1) of Node_Items;

    type Priority_Queue_Class is record
        count : integer range 0 to Priority_Queue_Limit -1;
        Node  : Priority_Queue_Nodes;
    end record;
    ---------------------------------------------------------------
    function Measure_Distance
    (
        NodeA, NodeB : Node_Items
    ) return integer;
    ---------------------------------------------------------------
    procedure Priority_Queue_Add(

        variable Queue    : inout Priority_Queue_Class;
        variable New_Node : inout Node_Items
    );
    ---------------------------------------------------------------
    procedure Priority_Queue_Remove(

        variable Queue : inout Priority_Queue_Class
    );
    ---------------------------------------------------------------
end package Priority_Queue;

package body Priority_Queue is
    ---------------------------------------------------------------
    -- This function calculates the distance between two Nodes 
    ---------------------------------------------------------------
    function Measure_Distance
    (
        NodeA, NodeB : Node_Items
    )
        return integer is
    begin
        return abs(NodeB.coords.X - NodeA.coords.X) + abs(NodeB.coords.Y - NodeA.coords.Y);

    end function;
    ---------------------------------------------------------------
    --Add a new node to the queue and sort it based on its f score
    ---------------------------------------------------------------
    procedure Priority_Queue_Add(

        variable Queue    : inout Priority_Queue_Class;
        variable New_Node : inout Node_Items
    ) is
        variable temp_Node : Node_Items;
    begin
        New_Node.In_Queue       := true;
        Queue.Node(Queue.count) := New_Node;

        --increment the number of nodes in queue by 1
        Queue.count := Queue.count + 1;
        --Preform a bubble sort  based on F score
        for i in Priority_Queue_Limit - 1 downto 1 loop
            if Queue.Node(i).f_score >= Queue.Node(i - 1).f_score then
                temp_Node         := Queue.Node(i - 1);
                Queue.Node(i - 1) := Queue.Node(i);
                Queue.Node(i)     := temp_Node;
            end if;
        end loop;

    end procedure;
    ---------------------------------------------------------------
    --remove the first node in queue
    ---------------------------------------------------------------
    procedure Priority_Queue_Remove(

        variable Queue : inout Priority_Queue_Class
    )is
    begin
        Queue.Node(Queue.count - 1).coords.X := 0;
        Queue.Node(Queue.count - 1).coords.Y := 0;
        Queue.Node(Queue.count - 1).f_score  := 0;
        Queue.Node(Queue.count - 1).g_score  := 0;
        --decrement the number of nodes in queue by 1
        Queue.count := Queue.count - 1;
    end procedure;
end package body;