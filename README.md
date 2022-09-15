This is a Synthesizable implementation of [A* search algorithm](https://en.wikipedia.org/wiki/A*_search_algorithm) in VHDL.

The project also includes a python script for generating a random 10x10 map.

## How to use
- Run ```main.py``` and create a random map or one of the presets
- Synthesize ```Astar.vhd``` using ISE 
- Run the testbench ```Astar_TB.vhd``` to solve the maze
- Go back to the Python script to visualize the solution
