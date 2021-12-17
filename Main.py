# This is a very simple program to generate Map for the VHDL program 
# and generate the Path made by the VHDL program.
import os
import numpy
from numpy import random
from shutil import copyfile


Map_Width = 10
Map_Height = 10

Directory = os.path.realpath(
    os.path.join(os.getcwd(), os.path.dirname(__file__)))
Map_Path = os.path.join(Directory, "Map.txt")

while (1):
    Map_Choice = input(
        " 1-Preset Map #1\n 2-Preset Map #2\n 3-Randomly Generated Map\n")

    if Map_Choice == '1':
        # preset 1
        copyfile(os.path.join(Directory, "Map_Preset1.txt"), Map_Path)

    elif Map_Choice == '2':
        # preset 2
        copyfile(os.path.join(Directory, "Map_Preset2.txt"), Map_Path)
    else:
        Map_file = open(Map_Path, "w")

        # generate a random map
        Generated_Map = random.randint(6, size=(Map_Width, Map_Height))
        for i in range(Map_Width):
            for j in range(Map_Height):

                if Generated_Map[i, j] != 1:
                    Generated_Map[i, j] = 0
                Map_file.write(str(Generated_Map[i, j])+"\n")
        Map_file.close()

    # draw map
    Map_file = open(Map_Path, "r")
    Map_List = Map_file.readlines()
    k = 0

    for i in range(Map_Width):
        for j in range(Map_Height):
            print(Map_List[k][0]+" ", end='')
            k += 1
        print("")

    Draw_path = input("\nPress P when VHDL simulation has been finished to draw Path...\n" +
                      "Or press Enter to return to home\n")
    if Draw_path == 'p':
        Node_Data_File = open(os.path.join(Directory, "Node_Data.txt"), "r")
        Node_Data = Node_Data_File.readlines()
        # import some node data from the VHDL code output
        Starting_Node_X = int(Node_Data[0])
        Starting_Node_Y = int(Node_Data[1])
        Destination_Node_X = int(Node_Data[2])
        Destination_Node_Y = int(Node_Data[3])
        Map_Width = int(Node_Data[4])
        Map_Height = int(Node_Data[5])

        # save the map in to an array
        Map_file = open(os.path.join(Directory, "Map.txt"), "r")
        Map_List = Map_file.readlines()

        k = 0
        Map = numpy.zeros((Map_Width, Map_Height), dtype=str)
        for i in range(Map_Width):
            for j in range(Map_Height):

                Map[i, j] = (Map_List[k][0])
                k += 1

        # import  directions from file
        Direction_File = open(os.path.join(Directory, "Direction.txt"), "r")

        Direction_List = Direction_File.readlines()

        x = Starting_Node_X
        y = Starting_Node_Y
        Map[y, x] = 'X'
        # draw the path
        for i in range(len(Direction_List)):
            temp = int(Direction_List[i][0])

            if temp == 1:  # UP
                y -= 1
            elif temp == 2:  # RIGHT
                x += 1
            elif temp == 3:  # DOWN
                y += 1
            elif temp == 4:  # LEFT
                x -= 1
            Map[y, x] = 'X'
        # print map with path
        for i in range(Map_Width):
            for j in range(Map_Height):
                print(Map[i, j]+" ", end='')
            print("")
        input("Press enter to return to home.")
    elif Draw_path == '\n':
        print('')

    print(chr(27) + "[2J")
